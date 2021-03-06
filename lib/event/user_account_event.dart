import 'package:wallet_exe/data/model/UserAccount.dart';
import 'package:wallet_exe/event/base_event.dart';

class LoginEvent extends BaseEvent {
  String email;
  String password;

  LoginEvent(this.email, this.password);
}

class CreateUserEvent extends BaseEvent {
  String name;
  String email;
  String password;

  CreateUserEvent(this.name, this.email, this.password);
}

class ChangePasswordEvent extends BaseEvent {
  String oldPassword;
  String password;

  ChangePasswordEvent(this.oldPassword, this.password);
}

class AddUserEvent extends BaseEvent {
  UserAccount userAccount;

  AddUserEvent(this.userAccount);
}

class UpdateUserEvent extends BaseEvent {
  UserAccount userAccount;

  UpdateUserEvent(this.userAccount);
}

class GetUserEvent extends BaseEvent {
  UserAccount userAccount;

  GetUserEvent(this.userAccount);
}

class GetCurrentUserEvent extends BaseEvent {
  GetCurrentUserEvent();
}

class DeleteCurrentUserEvent extends BaseEvent {
  DeleteCurrentUserEvent();
}

class DeleteAccountUserEvent extends BaseEvent {
  String password;

  DeleteAccountUserEvent(this.password);
}

class GetTimePushNotiEvent extends BaseEvent {
  GetTimePushNotiEvent();
}

class SaveTimePushNotiEvent extends BaseEvent {
  int hours;
  int minute;
  SaveTimePushNotiEvent({required this.hours, required this.minute});
}
