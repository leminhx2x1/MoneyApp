import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/item_spend_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CardSpendChart extends StatefulWidget {
  final showDetail;

  CardSpendChart({this.showDetail = false});

  @override
  _CardSpendChartState createState() => _CardSpendChartState();
}

class _CardSpendChartState extends State<CardSpendChart> {
  DateTime selectedDate = DateTime.now();
  late TransactionBloc _bloc;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  _getTitle() {
    String end = (this.selectedDate.year == DateTime.now().year)
        ? 'nay'
        : this.selectedDate.year.toString();
    return 'Chi tiêu năm ' + end;
  }

  @override
  void initState() {
    super.initState();
    _bloc = context.read<TransactionBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey
            : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: StreamBuilder<List<Transaction?>?>(
          stream: _bloc.transactionListStream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(_getTitle(),
                              style: Theme.of(context).textTheme.headline6),
                          RaisedButton(
                            onPressed: () => _selectDate(context),
                            child: Row(
                              children: <Widget>[
                                Text('Chọn năm'),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(Icons.create, size: 20),
                              ],
                            ),
                            color: Theme.of(context).accentColor,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('(Đơn vị: Nghìn)'),
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: SpendChart(_getData(snapshot.data ?? [])),
                      ),
                      widget.showDetail
                          ? _detailContent(_getTotal(snapshot.data ?? []))
                          : SizedBox(
                              height: 10,
                            )
                    ]);
              case ConnectionState.waiting:
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(_getTitle(),
                              style: Theme.of(context).textTheme.headline6),
                          RaisedButton(
                            onPressed: () => _selectDate(context),
                            child: Row(
                              children: <Widget>[
                                Text('Chọn năm'),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(Icons.create, size: 20),
                              ],
                            ),
                            color: Theme.of(context).accentColor,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('(Đơn vị: Nghìn)'),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          child: SpendChart(_getData([])),
                        ),
                      ),
                      widget.showDetail
                          ? _detailContent(_getTotal([]))
                          : SizedBox(
                              height: 10,
                            )
                    ]);
              default:
                return Container();
            }
          }),
    );
  }

  int _getTotal(List<Transaction?> list) {
    int total = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i]!.date!.year == selectedDate.year &&
          list[i]!.category!.transactionType == TransactionType.EXPENSE) {
        total += list[i]!.amount!;
      }
    }
    return total;
  }

  List<charts.Series<MoneySpend, String>> _getData(List<Transaction?> list) {
    List<int> totalByMonth = List<int>.filled(12, 0, growable: true);
    list.sort((a, b) {
      return a!.date!.compareTo(b!.date!);
    });
    list
        .where((item) => (item!.category!.transactionType!.name ==
                TransactionType.EXPENSE.name &&
            item.date!.year == selectedDate.year))
        .toList()
        .forEach((item) {
      totalByMonth[item!.date!.month - 1] += (item.amount! / 1000).round();
    });

    var data = List.generate(totalByMonth.length, (index) {
      return MoneySpend(index + 1, totalByMonth[index]);
    });

    return [
      new charts.Series<MoneySpend, String>(
        id: 'MoneySpend',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (MoneySpend spend, _) => spend.month.toString(),
        measureFn: (MoneySpend spend, _) => spend.money,
        data: data,
      )
    ];
  }

  Widget _detailContent(int totalYear) {
    return Padding(
      padding: EdgeInsets.only(right: 20, left: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Trung bình tháng:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(textToCurrency(
                  (totalYear / 12).round().toString()) +
                  ' đ'),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Tổng chi:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(textToCurrency(totalYear.toString()) + ' đ'),
            ],
          ),
        ],
      ),
    );
  }
}
