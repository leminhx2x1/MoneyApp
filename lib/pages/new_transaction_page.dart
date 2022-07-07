import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/src/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/bloc/category_spend_bloc.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/data/model/SpendLimit.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/event/category_spend_event.dart';
import 'package:wallet_exe/event/spend_limit_event.dart';
import 'package:wallet_exe/event/transaction_event.dart';
import 'package:wallet_exe/pages/account_page.dart';
import 'package:wallet_exe/pages/category_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';

class NewTransactionPage extends StatefulWidget {
  NewTransactionPage({Key? key}) : super(key: key);

  @override
  _NewTransactionPageState createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  var _balanceController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _formBalanceKey = GlobalKey<FormState>();
  late TransactionBloc _bloc;
  late AccountBloc _blocAccount;

  Category? _category;
  Account? _account;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<TransactionBloc>();
    _blocAccount = context.read<AccountBloc>();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null && time != _selectedTime) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  _getDate() {
    DateTime date = _selectedDate;
    String wd =
        date.weekday == 7 ? "Chủ Nhật" : "Thứ " + (date.weekday + 1).toString();
    String datePart = date.day.toString() +
        "/" +
        date.month.toString() +
        "/" +
        date.year.toString();
    return wd + " - " + datePart;
  }

  _getTime() {
    TimeOfDay time = _selectedTime;
    String formatTime = time.minute < 10 ? '0' : '';
    return time.hour.toString() + ":" + formatTime + time.minute.toString();
  }

  _getCurrencyColor() {
    if (this._category == null) return Colors.red;
    return (this._category!.transactionType == TransactionType.EXPENSE)
        ? Colors.red
        : Colors.green;
  }

  void _submit() {
    if (!this._formBalanceKey.currentState!.validate()) {
      return;
    }
    if (_account == null) return;
    if (_category == null) return;

    DateTime saveTime = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    Transaction transaction = Transaction(
        this._account,
        this._category,
        currencyToInt(this._balanceController.text),
        saveTime,
        this._descriptionController.text);

    if (this._category!.transactionType == TransactionType.EXPENSE)
      this._account!.balance = (this._account!.balance ?? 0) -
          currencyToInt(this._balanceController.text);
    if (this._category!.transactionType == TransactionType.INCOME)
      this._account!.balance = (this._account!.balance ?? 0) +
          currencyToInt(this._balanceController.text);
    _bloc.event.add(AddTransactionEvent(transaction));
    _reloadData();
    Navigator.pop(context);
  }

  _reloadData() {
    _blocAccount.initData();
    _blocAccount.event.add(GetAllBalanceEvent());
    context.read<SpendLimitBloc>()
      ..initData()
      ..resetSpendLimitStream()
      ..reloadTotalTransactionBySpendLimit();
    context.read<CategorySpendBloc>()
      ..event
          .add(GetCategorySpendByTransactionTypeEvent(TransactionType.EXPENSE))
      ..setStreamData(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giao dịch mới'),
      ),
      body: SingleChildScrollView(
          child: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blueGrey
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Số tiền',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Form(
                          key: _formBalanceKey,
                          child: TextFormField(
                            validator: (String? value) {
                              if (value!.trim() == "")
                                return 'Số tiền phải lớn hơn 0';
                              return currencyToInt(value) <= 0
                                  ? 'Số tiền phải lớn hơn 0'
                                  : null;
                            },
                            controller: _balanceController,
                            textAlign: TextAlign.end,
                            inputFormatters: [CurrencyTextFormatter()],
                            style: TextStyle(
                                color: _getCurrencyColor(),
                                fontSize: 32,
                                fontWeight: FontWeight.w900),
                            keyboardType: TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            autofocus: true,
                            decoration: InputDecoration(
                              suffixText: 'đ',
                              suffixStyle:
                                  Theme.of(context).textTheme.headline5,
                              prefix: Icon(
                                Icons.monetization_on,
                                color: Theme.of(context).accentColor,
                                size: 26,
                              ),
                              hintText: '0',
                              hintStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blueGrey
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: InkWell(
                      onTap: () async {
                        final category = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategoryPage()),
                        );
                        setState(() {
                          _category = category;
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            child: Icon(
                              _category == null
                                  ? Icons.category
                                  : _category!.icon,
                              size: 28,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              _category == null
                                  ? 'Chọn hạng mục'
                                  : _category!.name!,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            child: Icon(
                              Icons.subject,
                              size: 28,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: this._descriptionController,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Diễn giải',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 50,
                          child: Icon(
                            Icons.calendar_today,
                            size: 28,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: Text(
                              _getDate(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: Text(
                            _getTime(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: InkWell(
                      onTap: () async {
                        final account = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountPage()),
                        );
                        setState(() {
                          _account = account;
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 50,
                            child: _account == null
                                ? Icon(
                                    Icons.account_balance_wallet,
                                    size: 28,
                                  )
                                : Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Image.asset(_account!.img!),
                                  ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              _account == null
                                  ? 'Chọn tài khoản'
                                  : _account!.name!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.save,
                        size: 28,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Ghi',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                ),
                onPressed: _submit,
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      )),
    );
  }
}