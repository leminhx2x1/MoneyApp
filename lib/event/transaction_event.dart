import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/event/base_event.dart';

class AddTransactionEvent extends BaseEvent {
  Transaction transaction;

  AddTransactionEvent(this.transaction);
}

class DeleteTransactionEvent extends BaseEvent {
  Transaction? transaction;
  Account? account;

  DeleteTransactionEvent(this.transaction, this.account);
}

class UpdateTransactionEvent extends BaseEvent {
  Transaction transaction;
  Account? oldWallet;

  UpdateTransactionEvent(this.transaction, {this.oldWallet});
}
