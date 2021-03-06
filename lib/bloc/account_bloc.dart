import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:wallet_exe/bloc/base_bloc.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/repository/account_repository.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/event/base_event.dart';

class AccountBloc extends BaseBloc {
  final AccountRepository _accountRepository = AccountRepositoryImpl();

  StreamController<List<Account>?> _accountListStreamController =
      BehaviorSubject<List<Account>?>();

  Stream<List<Account>?> get accountListStream =>
      _accountListStreamController.stream;

  StreamController<int?> _balanceController = BehaviorSubject<int?>();

  Stream<int?> get balance => _balanceController.stream;
  List<Account>? _accountListData = [];

  List<Account>? get accountListData => _accountListData;

  initData() async {
    final stateData = await _accountRepository.getAllAccount();
    _accountListData = stateData.data;
    if (_accountListData == null) return;
    _accountListStreamController.sink.add(_accountListData);
  }

  _addAccount(Account account) async {
    final stateData = await _accountRepository.createAccount(account);
    if (stateData.data ?? false) {
      _accountListData!.add(account);
      _accountListStreamController.sink.add(_accountListData);
      _getAllBalance();
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
  }

  _deleteAccount(Account account) async {
    final stateData = await _accountRepository.deleteAccount(account);
    if (stateData.data ?? false) {
      _accountListData?.removeWhere((item) => item.id == account.id);
      _accountListStreamController.sink.add(_accountListData);
      _getAllBalance();
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
  }

  _updateAccount(Account account) async {
    var index = _accountListData!.indexWhere((item) => item.id == account.id);
    if (index == -1) return;
    final stateData = await _accountRepository.updateAccount(account);
    if (stateData.data ?? false) {
      _accountListData![index] = account;
      _accountListStreamController.sink.add(_accountListData);
      _getAllBalance();
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
  }

  _getAllBalance() async {
    final stateData = await _accountRepository.getAllBalance();
    if (stateData.data != null) {
      _balanceController.sink.add(stateData.data);
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
  }

  void dispatchEvent(BaseEvent event) {
    if (event is AddAccountEvent) {
      Account account = Account.copyOf(event.account);
      _addAccount(account);
    } else if (event is DeleteAccountEvent) {
      Account account = Account.copyOf(event.account);
      _deleteAccount(account);
    } else if (event is UpdateAccountEvent) {
      Account account = Account.copyOf(event.account!);
      _updateAccount(account);
    } else if (event is GetAllBalanceEvent) {
      _getAllBalance();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _accountListStreamController.close();
    _balanceController.close();
    super.dispose();
  }
}
