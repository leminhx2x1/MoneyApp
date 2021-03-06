import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/data/remote/firebase_util.dart';
import 'package:wallet_exe/data/repo/constrant_document.dart';
import 'package:wallet_exe/data/repo/state_data.dart';

class CategoryRemoteDataSource {
  static final _instance = CategoryRemoteDataSource._internal();

  factory CategoryRemoteDataSource() => _instance;

  CategoryRemoteDataSource._internal();

  Future<StateData> getAllCategory(String? userId) async {
    try {
      final querySnapShot =
          await fireStore.collection(_getCollection(userId)).get();
      final categories = <Category>[];
      querySnapShot.docs.forEach((item) {
        categories.add(Category.fromMap(item.data()));
      });
      return StateData.success(categories);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> addCategory(String? userId, Category category) async {
    try {
      var document = fireStore
          .collection('$USER_COLLECTION/$userId/$CATEGORY_COLLECTION')
          .doc();
      category.id = document.id;
      await document.set(category.toMap());
      return StateData.success(category);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> updateCategory(String? userId, Category category) async {
    try {
      await fireStore
          .collection(_getCollection(userId))
          .doc(category.id)
          .update(category.toMap());
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> registerCategory(String userId) async {
    var categories = getData().map((e) => Category.fromMap(e));
    try {
      categories.forEach((element) async => await addCategory(userId, element));
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  Future<StateData> deleteCategory(String? userId, String? categoryId) async {
    try {
      final batch = fireStore.batch();
      final transactionCollection =
          fireStore.collection(getCollectionTransaction(userId));
      final queryTransactionSnapshot = await transactionCollection
          .where(TransactionTable().idCategory, isEqualTo: categoryId)
          .get();
      queryTransactionSnapshot.docs.forEach((element) {
        batch.delete(transactionCollection.doc(element.id));
      });
      batch
          .delete(fireStore.collection(getCollectionCategory(userId)).doc(categoryId));
      await batch.commit();
      return StateData.success(true);
    } catch (e) {
      return StateData.error(e as Exception);
    }
  }

  String _getCollection(String? userId) =>
      '$USER_COLLECTION/$userId/$CATEGORY_COLLECTION';

  List<Map<String, dynamic>> getData() {
    return [
      {"color": 1, "name": "nh?? c???a", "type": 1, "icon": 59530},
      {"color": 1, "name": "con c??i", "type": 1, "icon": 60225},
      {"color": 1, "name": "qu???n ??o", "type": 1, "icon": 58164},
      {"color": 1, "name": "gi???i tr??", "type": 1, "icon": 58162},
      {"color": 1, "name": "du l???ch", "type": 1, "icon": 57749},
      {"color": 1, "name": "di chuy???n", "type": 1, "icon": 58673},
      {"color": 1, "name": "??i???n n?????c", "type": 1, "icon": 58940},
      {"color": 1, "name": "l??m ?????p", "type": 1, "icon": 59516},
      {"color": 1, "name": "??n u???ng", "type": 1, "icon": 58746},
      {"color": 1, "name": "l??nh l????ng", "type": 0, "icon": 57895},
      {"color": 1, "name": "???????c cho/t???ng", "type": 0, "icon": 59638}
    ];
  }
}
