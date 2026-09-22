import 'package:budget/database/tables.dart';

Future<bool> shareBudget(Budget? budgetToShare, context) async => false;
Future<bool> removedSharedFromBudget(Budget sharedBudget,
        {bool removeFromServer = true}) async =>
    false;
Future<bool> leaveSharedBudget(Budget sharedBudget) async => false;
Future<bool> addMemberToBudget(
        String sharedKey, String member, Budget budget) async =>
    false;
Future<bool> removeMemberFromBudget(
        String sharedKey, String member, Budget budget) async =>
    false;
Future<dynamic> getMembersFromBudget(String sharedKey, Budget budget) async =>
    false;
Future<bool> compareSharedToCurrentBudgets(
        List<dynamic> budgetSnapshot) async =>
    false;
Future<bool> getCloudBudgets() async => false;
Future<int> downloadTransactionsFromBudgets(
        dynamic db, List<dynamic> snapshots) async =>
    0;
Future<bool> sendTransactionSet(Transaction transaction, Budget budget) async =>
    false;
Future<bool> sendTransactionAdd(Transaction transaction, Budget budget) async =>
    false;
Future<bool> sendTransactionDelete(
        Transaction transaction, Budget budget) async =>
    false;
Future<void> syncPendingQueueOnServer() async {}
