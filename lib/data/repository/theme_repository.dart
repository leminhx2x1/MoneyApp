import 'package:wallet_exe/data/local/user_local_data_source.dart';
import 'package:wallet_exe/data/model/User.dart';
import 'package:wallet_exe/data/remote/user_remote_data_source.dart';
import 'package:wallet_exe/data/repo/state_data.dart';

abstract class ThemeRepository {
  Future<bool> saveIndexTheme(int index);

  int? getCurrentTheme();
}

class ThemeRepositoryImpl implements ThemeRepository {
  static final _instance = ThemeRepositoryImpl._internal();

  final UserLocalDataSource _localDataSource = UserLocalDataSource();

  factory ThemeRepositoryImpl() {
    return _instance;
  }

  ThemeRepositoryImpl._internal();

  @override
  Future<bool> saveIndexTheme(int index) async {
    return await _localDataSource.saveTheme(index);
  }

  @override
  int? getCurrentTheme() {
    return _localDataSource.getThemeIndexCurrent();
  }
}
