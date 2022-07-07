import 'dart:async';
import 'dart:ffi';

import 'package:rxdart/subjects.dart';
import 'package:wallet_exe/bloc/base_bloc.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/data/repository/transaction_repository.dart';
import 'package:wallet_exe/event/transaction_event.dart';
import 'package:wallet_exe/event/base_event.dart';

class TransactionBloc extends BaseBloc {
  TransactionRepository _transactionRepository = TransactionRepositoryIml();

  StreamController<List<Transaction?>?> _transactionListStreamController =
      BehaviorSubject<List<Transaction>?>();

  Stream<List<Transaction?>?> get transactionListStream =>
      _transactionListStreamController.stream;

  List<Transaction?>? _transactionListData = [];

  List<Transaction?>? get transactionListData => _transactionListData;

  Stream<void> get updateTransactionSuccess =>
      _transactionListStreamController.stream;

  StreamController<void> _updateTransactionSuccess = BehaviorSubject<void>();

  initData() async {
    final stateData = await _transactionRepository.getAllTransaction();
    if (stateData.data != null) {
      _transactionListData = stateData.data;
      _transactionListStreamController.sink.add(_transactionListData);
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
    print('transaction bloc init');
  }

  getAllTransaction() async {
    final stateData = await _transactionRepository.getAllTransaction();
    if (stateData.data != null) {
      _transactionListData = stateData.data;
      _transactionListStreamController.sink.add(_transactionListData);
      _transactionListStreamController.sink.add(_transactionListData);
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
  }

  _addTransaction(Transaction transaction) async {
    final stateData = await _transactionRepository.addTransaction(transaction);
    if (stateData.data != null) {
      _transactionListData?.add(stateData.data);
      _transactionListStreamController.sink.add(_transactionListData);
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
  }

  _deleteTransaction(Transaction transaction, Account wallet) async {
    final stateData =
        await _transactionRepository.deleteTransaction(transaction.id, wallet);

    if (stateData.isHasData) {
      _transactionListData?.removeWhere((item) => transaction.id == item?.id);
      _transactionListStreamController.sink.add(_transactionListData);
      _updateTransactionSuccess.sink.add(Void);
      _updateTransactionSuccess.sink.add(null);
    } else {
      errorStreamControler.sink.add(stateData.e);
    }
  }

  _updateTransaction(Transaction transaction, Account? oldWallet) async {
    int index = _transactionListData!.indexWhere((item) {
      return item!.id == transaction.id;
    });
    final statData =
        await _transactionRepository.updateTransaction(transaction, oldWallet);
    if (statData.data ?? false) {
      _transactionListData![index] = transaction;
      _transactionListStreamController.sink.add(_transactionListData);
    } else {
      errorStreamControler.sink.add(statData.e);
    }
  }

  void dispatchEvent(BaseEvent event) {
    if (event is AddTransactionEvent) {
      Transaction transaction = Transaction.copyOf(event.transaction);
      _addTransaction(transaction);
    } else if (event is DeleteTransactionEvent) {
      if (event.account == null || event.transaction == null) return;
      Transaction transaction = Transaction.copyOf(event.transaction!);

      _deleteTransaction(transaction, event.account!);
    } else if (event is UpdateTransactionEvent) {
      Transaction transaction = Transaction.copyOf(event.transaction);
      _updateTransaction(transaction, event.oldWallet);
    }
  }

  @override
  void dispose() {
    _transactionListStreamController.close();
    super.dispose();
  }
}
