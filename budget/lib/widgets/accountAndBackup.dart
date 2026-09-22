import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

dynamic googleUser;

Future<bool> signInGoogle(
    {Function()? next,
    BuildContext? context,
    bool? waitForCompletion,
    bool? drivePermissions,
    bool? gMailPermissions,
    bool? drivePermissionsAttachments,
    bool? silentSignIn}) async {
  if (next != null) next();
  return false;
}

Future<bool> testIfHasGmailAccess() async => false;

Future<bool> signOutGoogle() async {
  googleUser = null;
  updateSettings("currentUserEmail", "", updateGlobalState: true);
  updateSettings("hasSignedIn", false, updateGlobalState: false);
  return true;
}

Future<bool> refreshGoogleSignIn() async => false;

Future<bool> signInAndSync(BuildContext context,
    {required dynamic Function() next}) async {
  next();
  return false;
}

Future<void> createBackupInBackground(context) async {}
Future<void> createBackup(context,
    {bool? silentBackup,
    bool deleteOldBackups = false,
    String? clientIDForSync}) async {}
Future<void> deleteRecentBackups(context, amountToKeep,
    {bool? silentDelete}) async {}
Future<void> chooseBackup(context,
    {bool isManaging = false,
    bool isClientSync = false,
    bool hideDownloadButton = false}) async {}

class GoogleAccountLoginButton extends StatelessWidget {
  const GoogleAccountLoginButton(
      {super.key,
      this.navigationSidebarButton = false,
      this.onTap,
      this.isButtonSelected = false,
      this.isOutlinedButton = true,
      this.forceButtonName});
  final bool navigationSidebarButton;
  final Function? onTap;
  final bool isButtonSelected;
  final bool isOutlinedButton;
  final String? forceButtonName;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class BackupManagement extends StatelessWidget {
  const BackupManagement(
      {super.key,
      required this.isManaging,
      required this.isClientSync,
      this.hideDownloadButton = false});
  final bool isManaging;
  final bool isClientSync;
  final bool hideDownloadButton;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

bool openDatabaseCorruptedPopup(BuildContext context) => false;

bool openBackupReminderPopupCheck(BuildContext context) => false;
