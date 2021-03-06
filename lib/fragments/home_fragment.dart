import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/src/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/card_balance.dart';
import 'package:wallet_exe/widgets/card_maximum_spend.dart';
import 'package:wallet_exe/widgets/card_spend_chart.dart';

class HomeFragment extends StatefulWidget {
  HomeFragment({Key? key}) : super(key: key);

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  late AccountBloc _accountBloc;
  int? _balanceTotal = 0;

  // get total balance
  int getTotalBalance(List<Account> accounts) {
    int totalBalance = 0;
    for (Account account in accounts) {
      totalBalance += account.balance!;
    }
    return totalBalance;
  }

  @override
  void initState() {
    super.initState();
    _accountBloc = context.read<AccountBloc>()..initData();
    context.read<AccountBloc>().initData();
    context.read<TransactionBloc>().initData();
    context.read<CategoryBloc>().initData();
    context.read<SpendLimitBloc>().initData();
    _accountBloc.event.add(GetAllBalanceEvent());
  }

  _balanceDetailNav() {
    Navigator.pushNamed(context, '/balance_detail_page');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: InkWell(
                      onTap: _balanceDetailNav,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Theme.of(context).accentColor,
                            child: Icon(
                              Icons.attach_money,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          StreamBuilder<int?>(
                              stream: _accountBloc.balance,
                              builder: (context, snapshot) {
                                return Text(
                                  textToCurrency(
                                      (snapshot.data ?? 0).toString()),
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor),
                                );
                              }),
                          Icon(
                            Icons.navigate_next,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Cardbalance(),
          SizedBox(
            height: 15,
          ),
          CardMaximunSpend(),
          SizedBox(
            height: 15,
          ),
          CardSpendChart(),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
