import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:wallet_exe/data/dao/category_table.dart';
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/data/remote/firebase_util.dart';
import 'package:wallet_exe/data/repo/constrant_document.dart';
import 'package:wallet_exe/data/repo/state_data.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/widgets/item_spend_chart_circle.dart';

class TransactionRemoteDataSource {
  static final _instance = TransactionRemoteDataSource._internal();

  factory TransactionRemoteDataSource() {
    return _instance;
  }

  TransactionRemoteDataSource._internal();

  Future<StateData> getAllTransaction(String? userId) async {
    try {
      final transactions = <Transaction>[];
      final querySnapShot =
          await fireStore.collection(getCollectionTransaction(userId)).get();

      for (var doc in querySnapShot.docs) {
        final categoryMap = await fireStore
            .collection(getCollectionCategory(userId))
            .doc(doc[TransactionTable().idCategory])
            .get();
        final accountMap = await fireStore
            .collection(getCollectionAccount(userId))
            .doc(doc[AccountTable().id])
            .get();
        final Map<String, dynamic> map = new Map();
        map.addAll(doc.data());
        map[CategoryTable().tableName] = categoryMap.data();
        map[AccountTable().tableName] = accountMap.data();
        transactions.add(Transaction.fromMap(map));
      }
      return StateData.success(transactions);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> getTransactionsByType(
      String? userId, TransactionType type) async {
    final stateData = await getAllTransaction(userId);
    if (stateData.data == null) return stateData;

    final categorySpends = (stateData.data as List<Transaction>)
        .where((transaction) => transaction.category!.transactionType == type)
        .toList()
        .map((transaction) => CategorySpend(
            transaction.category!.name, transaction.amount, transaction.date))
        .toList();
    return StateData.success(categorySpends);
  }

  Future<StateData> addTransaction(
      String? userId, Transaction transaction) async {
    try {
      if (transaction.account == null) throw ("Account not null");
      final wallet = transaction.account!;
      final batch = fireStore.batch();
      final transactionDoc =
          fireStore.collection(getCollectionTransaction(userId)).doc();
      final walletDoc =
          fireStore.collection(getCollectionAccount(userId)).doc(wallet.id);
      transaction.id = transactionDoc.id;
      batch.set(transactionDoc, transaction.toMap());
      batch.update(walletDoc, wallet.toMap());
      await batch.commit();
      return StateData.success(transaction);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> editTransaction(
      String? userId, Transaction transaction, Account? oldAccount) async {
    try {
      if (transaction.account == null) throw ("Account not null");
      final wallet = transaction.account!;
      final batch = fireStore.batch();
      final transactionDocument = fireStore
          .collection(getCollectionTransaction(userId))
          .doc(transaction.id);
      batch.update(transactionDocument, transaction.toMap());
      final walletDocument =
          fireStore.collection(getCollectionAccount(userId)).doc(wallet.id);
      final oldWalletDocument = oldAccount?.id != null
          ? fireStore
              .collection(getCollectionAccount(userId))
              .doc(oldAccount?.id)
          : null;
      if (oldWalletDocument != null)
        batch.update(oldWalletDocument, oldAccount!.toMap());

      batch.update(walletDocument, wallet.toMap());
      await batch.commit();
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> deleteTransaction(
      String? userId, String? transactionId, Account account) async {
    try {
      final batch = fireStore.batch();
      final transactionDocument = fireStore
          .collection(getCollectionTransaction(userId))
          .doc(transactionId);
      batch.delete(transactionDocument);
      final accountDocument =
          fireStore.collection(getCollectionAccount(userId)).doc(account.id);
      batch.update(accountDocument, account.toMap());
      await batch.commit();
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }
}
