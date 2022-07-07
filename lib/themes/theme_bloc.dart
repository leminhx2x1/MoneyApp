import 'package:wallet_exe/data/repository/theme_repository.dart';
import 'package:wallet_exe/themes/theme.dart';
import 'package:rxdart/rxdart.dart';

class ThemeBloc {
  final _theme = BehaviorSubject<AppTheme?>();

  final ThemeRepository _themeRepository = ThemeRepositoryImpl();

  Function(AppTheme?) get inTheme => _theme.sink.add;

  Stream<AppTheme?> get outTheme => _theme.stream;

  saveTheme(int index) {
    _themeRepository.saveIndexTheme(index);
  }

  getTheme() {
    final index = _themeRepository.getCurrentTheme();
    inTheme(index == null ? myThemes[0] : myThemes[index]);
  }

  ThemeBloc() {
    print(' — — — -APP BLOC INIT — — — — ');
  }

  dispose() {
    print(' — — — — -APP BLOC DISPOSE — — — — — -');
    _theme.close();
  }
}
