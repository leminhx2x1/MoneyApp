import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/card_list_account.dart';

class AccountFragment extends StatefulWidget {
  AccountFragment({Key? key}) : super(key: key);

  @override
  _AccountFragmentState createState() => _AccountFragmentState();
}

class _AccountFragmentState extends State<AccountFragment> {
  late AccountBloc _accountBloc;

  @override
  void initState() {
    _accountBloc = context.read<AccountBloc>();
    _accountBloc.event.add(GetAllBalanceEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blueGrey
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: StreamBuilder<int?>(
                stream: _accountBloc.balance,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(
                          'Tổng: ' +
                              textToCurrency(snapshot.data!.toString()) +
                              'đ',
                          style: Theme.of(context).textTheme.headline6,
                        )
                      : SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(),
                        );
                }),
          ),
          SizedBox(
            height: 15,
          ),
          CardListAccount(),
        ],
      ),
    );
  }
}
