import 'package:flutter/material.dart';

List<String> recentCapturedNotifications = [];

Future<void> initNotificationScanning() async {}
Future<bool> requestReadNotificationPermission() async => false;
Future<bool> queueTransactionFromMessage(String messageString,
        {bool willPushRoute = true, DateTime? dateTime}) async =>
    false;
String getNotificationMessage(dynamic event) => "";

class InitializeNotificationService extends StatelessWidget {
  const InitializeNotificationService({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}

double? getTransactionAmountFromEmail(
        String message, String? before, String? after) =>
    null;
String? getTransactionTitleFromEmail(
        String message, String? before, String? after) =>
    null;

class AutoTransactionsPageEmail extends StatelessWidget {
  const AutoTransactionsPageEmail({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class AutoTransactionsPageNotifications extends StatelessWidget {
  const AutoTransactionsPageNotifications({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class GmailApiScreen extends StatelessWidget {
  const GmailApiScreen({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class EmailsList extends StatelessWidget {
  const EmailsList(
      {super.key,
      required this.messagesList,
      this.backgroundColor,
      this.onTap});
  final List<String> messagesList;
  final Color? backgroundColor;
  final Function? onTap;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

Future<void> parseEmailsInBackground(context,
    {bool sayUpdates = false, bool forceParse = false}) async {}
String getEmailMessage(dynamic messageData) => "";
