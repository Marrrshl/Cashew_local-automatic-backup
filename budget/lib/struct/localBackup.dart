import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget/widgets/restartApp.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String localBackupDirectorySetting = "localBackupDirectory";
const String localBackupRetentionSetting = "localBackupRetention";
const String hasPromptedBackupSetupSetting = "hasPromptedBackupSetup";
const String localBackupFileName = "cashew-latest.sql";

const MethodChannel _storageChannel = MethodChannel('com.budget.cashewfork/storage');

Timer? _backupTimer;
bool _backupInProgress = false;
bool startupBackupCheckComplete = false;
bool _canPerformBackup = false;
bool _userHasMadeEditInThisSession = false;

void markUserMadeEdit() {
  if (startupBackupCheckComplete) {
    _userHasMadeEditInThisSession = true;
  }
}

String _trOrFallback(String key, String fallback) {
  String result = key.tr();
  if (result == key || result.trim().isEmpty) {
    return fallback;
  }
  return result;
}

enum StartupSyncStatus {
  idle,
  success,
  noPath,
  noFile,
  permissionError,
  error,
}

StartupSyncStatus startupSyncStatus = StartupSyncStatus.idle;
String? startupSyncErrorMessage;

int getLocalBackupRetention() {
  dynamic val = appStateSettings[localBackupRetentionSetting];
  if (val is int) {
    if (val < 1) return 1;
    if (val > 20) return 20;
    return val;
  }
  return 10;
}

Future<bool> setLocalBackupRetention(int retention) async {
  int clamped = retention.clamp(1, 20);
  await updateSettings(
    localBackupRetentionSetting,
    clamped,
    updateGlobalState: true,
  );
  return true;
}

String? getLocalBackupDirectory() {
  dynamic value = appStateSettings[localBackupDirectorySetting];
  if (value == null) {
    try {
      final storedSettings = sharedPreferences.getString("userSettings");
      if (storedSettings != null) {
        value = (jsonDecode(storedSettings)
            as Map<String, dynamic>)[localBackupDirectorySetting];
      }
    } catch (_) {}
  }
  return value is String && value.isNotEmpty ? value : null;
}

Future<bool> setLocalBackupDirectory(String? directory) async {
  await updateSettings(
    localBackupDirectorySetting,
    directory,
    updateGlobalState: true,
  );
  return directory != null;
}

Future<String?> chooseLocalBackupDirectory() async {
  if (kIsWeb) return null;
  if (Platform.isAndroid) {
    try {
      final String? uri = await _storageChannel.invokeMethod<String>('pickDirectory');
      return uri;
    } catch (e) {
      print("Error picking directory via SAF: $e");
      return null;
    }
  } else {
    return await FilePicker.platform.getDirectoryPath();
  }
}

Future<bool> configureLocalBackupDirectory(BuildContext context) async {
  final directory = await chooseLocalBackupDirectory();
  if (directory == null || directory.isEmpty) return false;
  await setLocalBackupDirectory(directory);
  openSnackbar(SnackbarMessage(
    title: _trOrFallback("backup-folder-saved", "Backup folder saved"),
    description: directory,
    icon: appStateSettings["outlinedIcons"]
        ? Icons.folder_outlined
        : Icons.folder_rounded,
  ));
  return true;
}

Future<void> clearLocalBackupDirectory() async {
  final directory = getLocalBackupDirectory();
  if (directory != null && Platform.isAndroid && directory.startsWith("content://")) {
    try {
      await _storageChannel.invokeMethod('releasePersistedUriPermission', {
        'treeUri': directory,
      });
    } catch (_) {}
  }
  await setLocalBackupDirectory(null);
  openSnackbar(SnackbarMessage(
    title: _trOrFallback("backup-folder-removed", "Backup folder removed"),
    description: _trOrFallback("no-backup-folder-saved-description", "You may work with older data because no backup folder is selected."),
    icon: appStateSettings["outlinedIcons"]
        ? Icons.folder_off_outlined
        : Icons.folder_off_rounded,
  ));
}

Future<bool> restoreLocalBackupBeforeDatabase() async {
  if (kIsWeb) return false;
  startupBackupCheckComplete = false;
  _userHasMadeEditInThisSession = false;

  final directory = getLocalBackupDirectory();
  if (directory == null) {
    startupSyncStatus = StartupSyncStatus.noPath;
    return false;
  }

  print("Startup check: Checking for local backup at $directory...");

  Uint8List? fileBytes;
  try {
    if (Platform.isAndroid && directory.startsWith("content://")) {
      fileBytes = await _storageChannel.invokeMethod<Uint8List>('readBackupFile', {
        'treeUri': directory,
        'fileName': localBackupFileName,
      });
    } else {
      final file = File(p.join(directory, localBackupFileName));
      if (await file.exists()) {
        fileBytes = await file.readAsBytes();
      }
    }
  } catch (e) {
    print("Startup check: Exception reading backup file: $e");
    startupSyncStatus = StartupSyncStatus.error;
    startupSyncErrorMessage = e.toString();
    return false;
  }

  if (fileBytes == null || fileBytes.isEmpty) {
    print("Startup check: No backup file found.");
    startupSyncStatus = StartupSyncStatus.noFile;
    return false;
  }

  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, "db.sqlite"));
    await dbFile.writeAsBytes(fileBytes, flush: true);
    print("Startup check: Successfully imported $localBackupFileName (${fileBytes.length} bytes).");

    final storedSettingsRaw = sharedPreferences.getString("userSettings");
    if (storedSettingsRaw != null) {
      final settings = jsonDecode(storedSettingsRaw) as Map<String, dynamic>;
      settings["databaseJustImported"] = true;
      await sharedPreferences.setString("userSettings", jsonEncode(settings));
    }

    startupSyncStatus = StartupSyncStatus.success;
    return true;
  } catch (e) {
    print("Startup check: Error writing backup to db.sqlite: $e");
    startupSyncStatus = StartupSyncStatus.error;
    startupSyncErrorMessage = e.toString();
    return false;
  }
}

Future<void> initializeLocalBackups(BuildContext context) async {
  if (kIsWeb || startupBackupCheckComplete) return;
  startupBackupCheckComplete = true;

  print("Initializing Local Backups. Startup Status: $startupSyncStatus");

  bool hasOnboarded = appStateSettings["hasOnboarded"] == true;
  bool hasPrompted = appStateSettings[hasPromptedBackupSetupSetting] == true;

  if (hasOnboarded && !hasPrompted) {
    await showBackupFolderSetupDialog(context);
    _canPerformBackup = true;
    return;
  }

  if (hasOnboarded && startupSyncStatus != StartupSyncStatus.success) {
    openSnackbar(SnackbarMessage(
      title: _trOrFallback("working-with-old-data", "Working with Old Data"),
      description: startupSyncStatus == StartupSyncStatus.noPath
          ? _trOrFallback("no-backup-folder-saved-description", "You may work with older data because no backup folder is selected.")
          : (startupSyncStatus == StartupSyncStatus.noFile
              ? _trOrFallback("no-backup-file-found-description", "You may work with older data because no backup file was found in the saved directory.")
              : (startupSyncErrorMessage ?? _trOrFallback("error-loading-backup", "Error loading backup file"))),
      icon: Icons.warning_rounded,
      timeout: const Duration(milliseconds: 8000),
    ));
  }

  _canPerformBackup = true;
  print(">>> Automatic backups enabled <<<");
}

Future<void> showBackupFolderSetupDialog(BuildContext context) async {
  int retentionCount = getLocalBackupRetention();
  bool? completed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BackupSetupDialog(initialRetentionCount: retentionCount);
    },
  );

  await updateSettings(hasPromptedBackupSetupSetting, true, updateGlobalState: false);

  if (completed == true) {
    bool loaded = await loadLatestLocalBackup(context);
    if (!loaded) {
      openSnackbar(SnackbarMessage(
        title: _trOrFallback("working-with-old-data", "Working with Old Data"),
        description: _trOrFallback("no-backup-file-found-description", "You may work with older data because no backup file was found in the saved directory."),
        icon: Icons.warning_rounded,
        timeout: const Duration(milliseconds: 8000),
      ));
    }
  } else {
    openSnackbar(SnackbarMessage(
      title: _trOrFallback("working-with-old-data", "Working with Old Data"),
      description: _trOrFallback("no-backup-folder-saved-description", "You may work with older data because no backup folder is selected."),
      icon: Icons.warning_rounded,
      timeout: const Duration(milliseconds: 8000),
    ));
  }
}

class BackupSetupDialog extends StatefulWidget {
  final int initialRetentionCount;
  const BackupSetupDialog({super.key, required this.initialRetentionCount});

  @override
  State<BackupSetupDialog> createState() => _BackupSetupDialogState();
}

class _BackupSetupDialogState extends State<BackupSetupDialog> {
  late int retentionCount;

  @override
  void initState() {
    super.initState();
    retentionCount = widget.initialRetentionCount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    appStateSettings["outlinedIcons"]
                        ? Icons.folder_open_outlined
                        : Icons.folder_open_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _trOrFallback("choose-backup-folder", "Choose a backup folder"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _trOrFallback("choose-backup-folder-description", "Choose where automatic backups are saved. The newest file is loaded when the app starts.").tr(namedArgs: {
                      "count": retentionCount.toString(),
                    }),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _trOrFallback("number-of-backups", "Number of backups to keep"),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: retentionCount > 1
                            ? () => setState(() => retentionCount--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          retentionCount.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: retentionCount < 20
                            ? () => setState(() => retentionCount++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final directory = await chooseLocalBackupDirectory();
                      if (directory == null || directory.isEmpty) return;
                      await setLocalBackupRetention(retentionCount);
                      await setLocalBackupDirectory(directory);
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    icon: const Icon(Icons.folder_open),
                    label: Text(_trOrFallback("choose-folder", "Choose folder")),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: 6,
            end: 6,
            child: IconButton(
              tooltip: _trOrFallback("close", "Close"),
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> loadLatestLocalBackup(BuildContext context) async {
  if (kIsWeb) return false;
  _userHasMadeEditInThisSession = false;
  final directory = getLocalBackupDirectory();
  if (directory == null) return false;

  Uint8List? fileBytes;
  try {
    if (Platform.isAndroid && directory.startsWith("content://")) {
      fileBytes = await _storageChannel.invokeMethod<Uint8List>('readBackupFile', {
        'treeUri': directory,
        'fileName': localBackupFileName,
      });
    } else {
      final file = File(p.join(directory, localBackupFileName));
      if (await file.exists()) {
        fileBytes = await file.readAsBytes();
      }
    }
  } catch (e) {
    print("Error reading backup file: $e");
    return false;
  }

  if (fileBytes == null || fileBytes.isEmpty) return false;

  try {
    await database.close();
    await overwriteDefaultDB(fileBytes);

    database = await constructDb("db");

    await updateSettings(
      "databaseJustImported",
      true,
      pagesNeedingRefresh: [],
      updateGlobalState: false,
    );

    await initializeSettings();

    startupSyncStatus = StartupSyncStatus.success;
    startupBackupCheckComplete = false;
    RestartApp.restartApp(context);

    return true;
  } catch (error) {
    debugPrint("Local backup restore failed: $error");
    return false;
  }
}

Future<void> checkBackupStatusOnResume(BuildContext context) async {
  if (kIsWeb || !_canPerformBackup) return;
  final directory = getLocalBackupDirectory();
  if (directory == null) return;

  bool exists = false;
  try {
    if (Platform.isAndroid && directory.startsWith("content://")) {
      exists = await _storageChannel.invokeMethod<bool>('checkBackupFileExists', {
        'treeUri': directory,
        'fileName': localBackupFileName,
      }) ?? false;
    } else {
      final file = File(p.join(directory, localBackupFileName));
      exists = await file.exists();
    }
  } catch (e) {
    print("Error checking backup status on resume: $e");
    exists = false;
  }

  if (!exists) {
    startupSyncStatus = StartupSyncStatus.noFile;
    openSnackbar(SnackbarMessage(
      title: _trOrFallback("working-with-old-data", "Working with Old Data"),
      description: _trOrFallback("no-backup-file-found-description", "You may work with older data because no backup file was found in the saved directory."),
      icon: Icons.warning_rounded,
      timeout: const Duration(milliseconds: 8000),
    ));
  } else {
    startupSyncStatus = StartupSyncStatus.success;
  }
}

void scheduleAutomaticLocalBackup({bool isUserEdit = false}) {
  if (isUserEdit && startupBackupCheckComplete) {
    _userHasMadeEditInThisSession = true;
  }

  if (kIsWeb || !_canPerformBackup || !_userHasMadeEditInThisSession) return;
  final directory = getLocalBackupDirectory();
  if (directory == null) return;

  _backupTimer?.cancel();
  _backupTimer = Timer(const Duration(milliseconds: 2000), () {
    writeAutomaticLocalBackup();
  });
}

Future<bool> writeAutomaticLocalBackup() async {
  if (kIsWeb || _backupInProgress || !_canPerformBackup || !_userHasMadeEditInThisSession) return false;
  final directory = getLocalBackupDirectory();
  if (directory == null) return false;

  _backupInProgress = true;
  try {
    await backupSettings();

    try {
      await database.customStatement('PRAGMA wal_checkpoint(FULL);');
    } catch (e) {
      print("Error during database checkpoint before backup: $e");
    }

    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, 'db.sqlite');
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) return false;

    final bytes = await dbFile.readAsBytes();
    if (bytes.isEmpty) return false;

    final retentionCount = getLocalBackupRetention();

    bool success = false;
    if (Platform.isAndroid && directory.startsWith("content://")) {
      final bool? result = await _storageChannel.invokeMethod<bool>('writeBackupAndRotate', {
        'treeUri': directory,
        'bytes': bytes,
        'fileName': localBackupFileName,
        'retentionCount': retentionCount,
      });
      success = result == true;
    } else {
      final folder = Directory(directory);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final latestFile = File(p.join(directory, localBackupFileName));
      final timestamp = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());
      final rotatedFile = File(p.join(directory, "cashew-backup-$timestamp.sql"));

      if (await latestFile.exists()) {
        await latestFile.rename(rotatedFile.path);
      }

      await latestFile.writeAsBytes(bytes, flush: true);

      final files = (await folder.list().toList())
          .whereType<File>()
          .where((f) => p.basename(f.path).startsWith("cashew-backup-") && f.path.endsWith(".sql"))
          .toList();

      files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

      if (files.length > retentionCount) {
        final toDelete = files.take(files.length - retentionCount);
        for (final f in toDelete) {
          await f.delete();
        }
      }
      success = true;
    }

    if (success) {
      _userHasMadeEditInThisSession = false;
    }
    return success;
  } catch (error) {
    print("Automatic local backup failed! Error: $error");
    return false;
  } finally {
    _backupInProgress = false;
  }
}
