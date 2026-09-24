import 'dart:convert';

import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/localBackup.dart';
import 'package:budget/struct/syncClient.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/progressBar.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:budget/struct/randomConstants.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:path/path.dart' as p;

Future<String?> importDBFileFromDevice(BuildContext context) async {
  try {
    await FilePicker.platform.clearTemporaryFiles();
  } catch (_) {}

  // For some reason, iOS does not let us select SQL files if we limit
  FilePickerResult? result = getPlatform() == PlatformOS.isIOS
      ? await FilePicker.platform.pickFiles(withData: true)
      : await FilePicker.platform.pickFiles(
          allowedExtensions: ['sql', 'sqlite'],
          type: FileType.custom,
          withData: true,
        );
  if (result == null || result.files.isEmpty) {
    openSnackbar(SnackbarMessage(
      title: "error-importing".tr(),
      description: "no-file-selected".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.warning_outlined
          : Icons.warning_rounded,
    ));
    return null;
  }

  await cancelAndPreventSyncOperation();

  Uint8List? fileBytes = result.files.single.bytes;
  if (fileBytes == null && result.files.single.path != null) {
    fileBytes = await File(result.files.single.path!).readAsBytes();
  }

  if (fileBytes == null || fileBytes.isEmpty) {
    openSnackbar(SnackbarMessage(
      title: "error-importing".tr(),
      description: "no-file-selected".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.warning_outlined
          : Icons.warning_rounded,
    ));
    return null;
  }

  if (kIsWeb) {
    await overwriteDefaultDB(fileBytes);
  } else {
    await database.close();
    await overwriteDefaultDB(fileBytes);
    database = await constructDb("db");
  }
  await resetLanguageToSystem(context);
  await updateSettings("databaseJustImported", true,
      pagesNeedingRefresh: [], updateGlobalState: false);
  await updateSettings(hasPromptedBackupSetupSetting, true,
      pagesNeedingRefresh: [], updateGlobalState: false);
  if (!kIsWeb) {
    await initializeSettings();
    appStateKey.currentState?.refreshAppState();
    refreshPageFrameworks();
  }
  return result.files.single.name;
}

Future importDB(BuildContext context, {ignoreOverwriteWarning = false}) async {
  dynamic result = ignoreOverwriteWarning == true
      ? true
      : await openPopup(
          context,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
          title: "data-overwrite-warning".tr(),
          description: "data-overwrite-warning-description".tr(),
          onCancel: () {
            Navigator.pop(context, false);
          },
          onCancelLabel: "cancel".tr(),
          onSubmit: () {
            Navigator.pop(context, true);
          },
          onSubmitLabel: "ok".tr(),
        );
  if (result == true) {
    await openPopup(
      context,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.file_open_outlined
          : Icons.file_open_rounded,
      title: "select-backup-file".tr(),
      description: "select-backup-file-description".tr(),
      onSubmit: () {
        Navigator.pop(context);
      },
      onSubmitLabel: "ok".tr(),
    );
    await openLoadingPopupTryCatch(
      () async {
        return await importDBFileFromDevice(context);
      },
      onSuccess: (result) {},
    );
  }
}

class ImportDB extends StatelessWidget {
  const ImportDB({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      onTap: () async {
        await importDB(context);
      },
      title: "import-data-file".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.download_outlined
          : Icons.download_rounded,
    );
  }
}
