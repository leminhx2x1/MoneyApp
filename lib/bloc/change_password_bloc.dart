import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:wallet_exe/data/repository/user_repository.dart';
import 'package:wallet_exe/event/base_event.dart';
import 'package:wallet_exe/event/user_account_event.dart';
import 'base_bloc.dart';

class ChangePasswordBloc extends BaseBloc {
  final UserRepository _userRepository = UserRepositoryImpl();

  StreamController<bool?> _streamChangePasswordSuccess =
      BehaviorSubject<bool?>();

  Stream<bool?> get changePasswordSuccess =>
      _streamChangePasswordSuccess.stream;

  _updatePassword(String oldPassword, String password) async {
    final state = await _userRepository.changePassword(oldPassword,password);
    state.isHasData
        ? _streamChangePasswordSuccess.sink.add(true)
        : errorStreamControler.sink.add(state.e);
  }

  void dispatchEvent(BaseEvent event) {
    if (event is ChangePasswordEvent) {
      _updatePassword(event.oldPassword, event.password);
    }
  }

  @override
  void dispose() {
    _streamChangePasswordSuccess.close();
    super.dispose();
  }
}
