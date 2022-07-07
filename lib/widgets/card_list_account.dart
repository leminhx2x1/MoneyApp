import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/enums/account_type.dart';
import 'package:wallet_exe/widgets/item_account.dart';

class CardListAccount extends StatefulWidget {
  CardListAccount({Key? key}) : super(key: key);

  @override
  _CardListAccountState createState() => _CardListAccountState();
}

class _CardListAccountState extends State<CardListAccount> {
  late AccountBloc bloc;

  _createListAccountTile(List<Account> listAccount) {
    List<Widget> list = [];
    for (int i = 0; i < listAccount.length; i++) {
      list.add(ItemAccount(listAccount[i]));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
     bloc = context.read<AccountBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Account>?>(
        stream: bloc.accountListStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  width: 100,
                  height: 50,
                  child: Text('Bạn chưa tạo tài khoản nào'),
                ),
              );
            case ConnectionState.none:

            case ConnectionState.active:
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: ExpansionTile(
                        title: Text(
                          "Đang sử dụng (" +
                              AccountTable.getTotalByType(
                                  snapshot.data!, AccountType.SPENDING) +
                              " đ)",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        initiallyExpanded: true,
                        children: _createListAccountTile(snapshot.data!
                            .where(
                                (item) => (item.type == AccountType.SPENDING))
                            .toList()),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ExpansionTile(
                        title: Text(
                          "Tài khoản tiết kiệm (" +
                              AccountTable.getTotalByType(
                                  snapshot.data!, AccountType.SAVING) +
                              " đ)",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        initiallyExpanded: false,
                        children: _createListAccountTile(snapshot.data!
                            .where((item) => (item.type == AccountType.SAVING))
                            .toList()),
                      ),
                    )
                  ],
                ),
              );

            default:
              return Center(
                child: Container(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              );
          }
        });
    //       ,
    // );
  }
}
