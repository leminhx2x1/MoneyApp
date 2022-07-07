import 'package:flutter/material.dart';
import 'package:wallet_exe/data/local/user_local_data_source.dart';
import 'package:wallet_exe/data/model/User.dart';
import 'package:wallet_exe/data/remote/user_remote_data_source.dart';
import 'package:wallet_exe/data/repo/state_data.dart';

abstract class UserRepository {
  Future<StateData> createAccount(String name, String email, String password);

  Future<StateData> getUserByEmailAndPassword(String email, String password);

  UserModel? getCurrentUser();

  Future<bool> deleteCurrentUser();

  Future<bool> saveIndexTheme(int index);

  Future<StateData> changePassword(String oldPassword, String password);

  Future<StateData> deleteAccount(String password);

  TimeOfDay getTimePushNoti();

  Future<void> saveTimeOfDay({required int hours, required int minute});
}

class UserRepositoryImpl implements UserRepository {
  static final _instance = UserRepositoryImpl._internal();

  final UserRemoteDataSource _userRemoteDataSource = UserRemoteDataSource();
  final UserLocalDataSource _localDataSource = UserLocalDataSource();

  factory UserRepositoryImpl() {
    return _instance;
  }

  UserRepositoryImpl._internal();

  @override
  Future<StateData> createAccount(
    String name,
    String email,
    String password,
  ) async {
    var stateData =
        await _userRemoteDataSource.createUser(name, email, password);
    if (stateData.data != null)
      _localDataSource.saveUserCurrent(stateData.data);
    return stateData;
  }

  @override
  UserModel? getCurrentUser() {
    return _localDataSource.getUserCurrent();
  }

  @override
  Future<StateData> getUserByEmailAndPassword(
      String email, String password) async {
    final stateData =
        await _userRemoteDataSource.getUserByEmailAndPassword(email, password);
    if (stateData.data != null) {
      await _localDataSource.saveUserCurrent(stateData.data);
    }
    return stateData;
  }

  @override
  Future<bool> deleteCurrentUser() async {
    return await _localDataSource.logout();
  }

  @override
  Future<bool> saveIndexTheme(int index) async {
    return await _localDataSource.saveTheme(index);
  }

  @override
  Future<StateData> changePassword(String oldPassword, String password) async {
    return await _userRemoteDataSource.changePassword(oldPassword, password);
  }

  @override
  Future<StateData> deleteAccount(String password) async {
    final state = await _userRemoteDataSource.deleteAccount(password);
    if (state.isHasData) {
      await deleteCurrentUser();
    }
    return state;
  }

  @override
  TimeOfDay getTimePushNoti() {
    return _localDataSource.getTimeOfDay();
  }

  @override
  Future<void> saveTimeOfDay({required int hours, required int minute}) async {
    return _localDataSource.saveTimeOfDay(hours: hours, minute: minute);
  }
}
