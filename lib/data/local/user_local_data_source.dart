import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_exe/data/local/key_shared_preferences.dart';
import 'package:wallet_exe/data/model/User.dart';

class UserLocalDataSource {
  static final UserLocalDataSource _instance = UserLocalDataSource._internal();

  static late SharedPreferences _preferences;

  factory UserLocalDataSource() {
    return _instance;
  }

  UserLocalDataSource._internal();

  static Future<void> initData() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<bool> saveUserCurrent(UserModel? user) async {
    if (user == null) return false;
    return await _preferences.setString(
        KEY_SP_CURRENT_USER, jsonEncode(user.toMap()));
  }

  Future<bool> logout() async {
    return await _preferences.remove(KEY_SP_CURRENT_USER);
  }

  UserModel? getUserCurrent() {
    String? userString = _preferences.getString(KEY_SP_CURRENT_USER);
    return userString != null
        ? UserModel.fromMap(jsonDecode(userString))
        : null;
  }

  Future<bool> saveTheme(int index) async {
    return await _preferences.setInt(KEY_SP_INDEX_THEME, index);
  }

  int? getThemeIndexCurrent() {
    return _preferences.getInt(KEY_SP_INDEX_THEME);
  }

  TimeOfDay getTimeOfDay() {
    final hours = _preferences.getInt(KEY_SP_TIME_PUSH_NOTI_HOURS);
    final minute = _preferences.getInt(KEY_SP_TIME_PUSH_NOTI_MINUTE);
    return hours == null || minute == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: hours, minute: minute);
  }

  void saveTimeOfDay({required int hours, required int minute}) async {
    await _preferences.setInt(KEY_SP_TIME_PUSH_NOTI_HOURS, hours);
    await _preferences.setInt(KEY_SP_TIME_PUSH_NOTI_MINUTE, minute);
  }
}
