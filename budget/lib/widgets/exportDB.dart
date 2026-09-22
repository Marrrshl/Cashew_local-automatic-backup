import 'package:budget/database/tables.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/util/saveFile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/struct/localBackup.dart';

Future saveDBFileToDevice({
  required BuildContext boxContext,
  required String fileName,
  String? customDirectory,
}) async {
  try {
    await backupSettings();
  } catch (e) {
    print("Error creating settings entry in the db: " + e.toString());
  }

  DBFileInfo currentDBFileInfo = await getCurrentDBFileInfo();

  List<int> dataStore = [];
  await for (var data in currentDBFileInfo.mediaStream) {
    dataStore.insertAll(dataStore.length, data);
  }

  return await saveFile(
    boxContext: boxContext,
    dataStore: dataStore,
    dataString: null,
    fileName: fileName,
    successMessage: "backup-saved-success".tr(),
    errorMessage: "error-saving".tr(),
    customDirectory: customDirectory,
  );
}

Future exportDB({required BuildContext boxContext}) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory == null) return;
  await openLoadingPopupTryCatch(() async {
    const String fileName = localBackupFileName;
    await saveDBFileToDevice(
        boxContext: boxContext,
        fileName: fileName,
        customDirectory: selectedDirectory);
  });
}

class LocalBackupDirectory extends StatelessWidget {
  const LocalBackupDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    final directory = getLocalBackupDirectory();
    return Column(
      children: [
        SettingsContainer(
          onTap: () async {
            await configureLocalBackupDirectory(context);
          },
          title: "backup-folder".tr(),
          description: directory ?? "no-folder-selected".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.folder_open_outlined
              : Icons.folder_open_rounded,
          afterWidget: directory != null
              ? IconButton(
                  tooltip: "clear-selection".tr(),
                  icon: Icon(
                    appStateSettings["outlinedIcons"]
                        ? Icons.close_outlined
                        : Icons.close_rounded,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: () async {
                    await clearLocalBackupDirectory();
                  },
                )
              : null,
        ),
        SettingsContainer(
          title: "number-of-backups".tr(),
          description: getLocalBackupRetention().toString(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.history_outlined
              : Icons.history_rounded,
          onTap: () {
            int retentionCount = getLocalBackupRetention();
            openBottomSheet(
              context,
              PopupFramework(
                title: "number-of-backups".tr(),
                child: StatefulBuilder(builder: (context, setDialogState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: retentionCount > 1
                            ? () {
                                setDialogState(() => retentionCount--);
                                setLocalBackupRetention(retentionCount);
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          retentionCount.toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: retentionCount < 20
                            ? () {
                                setDialogState(() => retentionCount++);
                                setLocalBackupRetention(retentionCount);
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ExportDB extends StatelessWidget {
  const ExportDB({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (boxContext) {
      return SettingsContainer(
        onTap: () async {
          await exportDB(boxContext: boxContext);
        },
        title: "export-data-file".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.upload_outlined
            : Icons.upload_rounded,
      );
    });
  }
}
