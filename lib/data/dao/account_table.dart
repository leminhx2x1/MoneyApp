import 'package:wallet_exe/utils/text_input_formater.dart';

import '../model/Account.dart';
import 'package:sqflite/sqflite.dart';
import '../../enums/account_type.dart';

import '../database_helper.dart';

class AccountTable {
  final tableName = 'account';
  final id = 'id_account';
  final name = 'account_name';
  final userId = 'user_id';

  //final int idAppAccount; //TO DO
  final balance = 'balance';
  final type = 'type';
  final icon = 'icon';
  final img = 'img';

  void onCreate(Database db, int version) {
    db.execute('''
    CREATE TABLE account (
      id_account INTEGER PRIMARY KEY,
      account_name TEXT NOT NULL UNIQUE,
      user_id INTEGER NOT NULL,
      balance INTEGER NOT NULL,
      type INTEGER NOT NULL,
      icon INTEGER NOT NULL,
      img TEXT NOT NULL)
    ''');
  }

  Future<void> initAccountData(int? userId) {
    final Database db = DatabaseHelper.instance.database!;
    db.execute(
        'INSERT INTO account VALUES (0,"Ví",$userId,0,0,0,"assets/logo.png")');
    db.execute(
        'INSERT INTO account VALUES (1,"ATM",$userId,0,0,0,"assets/credit.png")');
    return db.execute(
        'INSERT INTO account VALUES (2,"MOMO",$userId,0,0,0,"assets/e-wallet.png")');
  }

  Future<List<String?>> getAllAccountName() async {
    final Database db = DatabaseHelper.instance.database!;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    List<String?> result = List.generate(maps.length, (index) {
      return Account.fromMap(maps[index]).name;
    });

    result.insert(0, "Tất cả");
    return result;
  }

  Future<int> insert(Account account) async {
    // Get a reference to the database.
    final Database db = DatabaseHelper.instance.database!;

    // Insert the Account into the correct table.
    return db.insert(tableName, account.toMap());
  }

  Future<void> deleteAccount(Account account) async {
    final Database db = DatabaseHelper.instance.database!;
    await db.delete(tableName, where: '$id = ?', whereArgs: [account.id]);
  }

  Future<void> updateAccount(Account account) async {
    final Database db = DatabaseHelper.instance.database!;
    await db.update(tableName, account.toMap(),
        where: '$id = ?', whereArgs: [account.id]);
  }

  Future<String> getTotalBalance() async {
    final Database db = DatabaseHelper.instance.database!;
    String rawQuery = 'SELECT SUM(balance) FROM $tableName';

    final List<Map<String, dynamic>> map = await db.rawQuery(rawQuery);
    return map[0].values.toString();
  }

  Future<String> getUsingBalance() async {
    final Database db = DatabaseHelper.instance.database!;
    String rawQuery = 'SELECT SUM(balance) FROM $tableName WHERE';

    final List<Map<String, dynamic>> map = await db.rawQuery(rawQuery);
    return map[0].values.toString();
  }

  Future<List<Account>> getAllAccount() async {
    final Database db = DatabaseHelper.instance.database!;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // List<Account> accounts = List<Account>();
    // accounts = maps.map( (f) {
    //   accounts.add(Account.fromMap(f));
    // });

    return List.generate(maps.length, (index) {
      return Account.fromMap(maps[index]);
    });
  }

  static String getTotalByType(List<Account> list, AccountType type) {
    var sum = 0;
    list.forEach((item) {
      if (item.type!.value == type.value) sum += item.balance!;
    });
    if (sum == 0) return "0";
    return textToCurrency(sum.toString());
  }
}
