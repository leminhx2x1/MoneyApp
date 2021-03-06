import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/remote/firebase_util.dart';
import 'package:wallet_exe/data/repo/constrant_document.dart';
import 'package:wallet_exe/data/repo/state_data.dart';

class AccountRemoteDataSource {
  static final _instance = AccountRemoteDataSource._internal();

  factory AccountRemoteDataSource() {
    return _instance;
  }

  AccountRemoteDataSource._internal();

  Future<StateData> getAllAccount(String? userId) async {
    try {
      final querySnapshot = await fireStore
          .collection('$USER_COLLECTION/$userId/$WALLET_COLLECTION')
          .get();
      List<Account> accounts = List.generate(querySnapshot.docs.length,
          (index) => Account.fromMap(querySnapshot.docs[index].data()));
      return StateData.success(accounts);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> addAccount(String? userId, Account account) async {
    try {
      var documentReference = fireStore
          .collection('$USER_COLLECTION/$userId/$WALLET_COLLECTION')
          .doc();
      account.id = documentReference.id;
      await documentReference.set(account.toMap());
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> updateAccount(String? userId, Account account) async {
    try {
      await fireStore
          .collection('$USER_COLLECTION/$userId/$WALLET_COLLECTION')
          .doc(account.id)
          .update(account.toMap());
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> deleteAccount(String? userId, Account account) async {
    try {
      final batch = fireStore.batch();
      final transactionCollection =
          fireStore.collection(getCollectionTransaction(userId));
      final walletDocument =
          fireStore.collection(getCollectionAccount(userId)).doc(account.id);
      final querySnapShot = await transactionCollection
          .where(TransactionTable().idAccount, isEqualTo: account.id)
          .get();
      querySnapShot.docs.forEach((element) {
        batch.delete(transactionCollection.doc(element.id));
      });
      batch.delete(walletDocument);
      await batch.commit();
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }
}
