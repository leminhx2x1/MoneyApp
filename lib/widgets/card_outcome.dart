import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/src/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wallet_exe/bloc/category_spend_bloc.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/event/category_spend_event.dart';
import 'package:wallet_exe/widgets/item_spend_chart_circle.dart';

class CardOutcomeChart extends StatefulWidget {
  CardOutcomeChart({Key? key}) : super(key: key);

  @override
  _CardOutcomeChartState createState() => _CardOutcomeChartState();
}

class _CardOutcomeChartState extends State<CardOutcomeChart> {
  List _option = <String>[
    "Hôm nay",
    "Tuần này",
    "Tháng này",
    "Năm nay",
    "Tất cả"
  ];
  List<DropdownMenuItem<String>>? _dropDownMenuItems;
  String? _currentOption;
  late CategorySpendBloc _categorySpendsBloc;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentOption = "Tháng này";
    super.initState();
    _categorySpendsBloc = context.read<CategorySpendBloc>();
    _categorySpendsBloc.event
        .add(GetCategorySpendByTransactionTypeEvent(TransactionType.EXPENSE));
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = [];
    for (String option in _option as List<String>) {
      items.add(DropdownMenuItem(value: option, child: Text(option)));
    }
    return items;
  }

  void changedDropDownItem(String? selectedOption) {
    setState(() {
      _currentOption = selectedOption;
    });
  }

  List<CategorySpend> _applyFilter(List<CategorySpend> list) {
    List<CategorySpend> result = [];
    final dateTimeCurrent = DateTime.now();
    for (int i = 0; i < list.length; i++) {
      final categorySpendDate = list[i].date;
      switch (_currentOption) {
        case "Hôm nay":
          {
            if (categorySpendDate!.year == dateTimeCurrent.year &&
                categorySpendDate.month == dateTimeCurrent.month &&
                categorySpendDate.day == dateTimeCurrent.day) {
              result.add(list[i]);
            }
            break;
          }
        case "Tuần này":
          {
            if (dateTimeCurrent
                .subtract(new Duration(days: 7))
                .isBefore(categorySpendDate!)) {
              result.add(list[i]);
            }
            break;
          }
        case "Tháng này":
          {
            if (categorySpendDate!.year == dateTimeCurrent.year &&
                categorySpendDate.month == dateTimeCurrent.month) {
              result.add(list[i]);
            }
            break;
          }
        case "Năm nay":
          {
            if (categorySpendDate!.year == dateTimeCurrent.year) {
              result.add(list[i]);
            }
            break;
          }
        default:
          {
            result.add(list[i]);
            break;
          }
      }
    }
    final categoryNames = Set();
    final data = <CategorySpend>[];
    List.generate(
        result.length, (index) => categoryNames.add(result[index].category));
    categoryNames.forEach((name) {
      int sum = 0;
      result.forEach((item) {
        if (item.category == name) {
          sum += item.money!;
        }
      });
      data.add(CategorySpend(name, (sum / 1000).round(), DateTime.now()));
    });
    return data;
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
      child: StreamBuilder(
        stream: _categorySpendsBloc.categoryStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Biểu đồ chi',
                        style: Theme.of(context).textTheme.headline6),
                    DropdownButton(
                      value: _currentOption,
                      items: _dropDownMenuItems,
                      onChanged: changedDropDownItem,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 280,
                  width: 400,
                  child: snapshot.data.isNotEmpty
                      ? SpendChartCircle(
                          _createData(_applyFilter(snapshot.data)))
                      : Center(
                          child: Text(
                            ' Không có khoản tiêu thụ trong tháng',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ),
                Text(snapshot.data.isNotEmpty ? 'Đơn vị: nghìn' : ''),
              ],
            );
          }
          return Container(
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Container(
                height: 320,
                width: double.infinity,
                child: SpendChartCircle(
                  _createData(
                    [
                      CategorySpend("loading", 1000000, DateTime.now(),
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static List<charts.Series<CategorySpend, String>> _createData(
      List<CategorySpend> list) {
    final List<Color> colors = [
      // Color(0x7adfeeee),
      // Color(0xffffd54f),
      // Color(0xff80deea),
      // Color(0xffef9a9a),
      // Color(0xeec5c68a),
      // Color(0xfff8bbd0),
      // Color(0xffbbdefb),
      Colors.red,
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.purpleAccent,
      Colors.amberAccent,
      Colors.teal.shade500,
      Colors.teal.shade200,
      Colors.black54,
    ];

    List<CategorySpend> data = [];
    CategorySpend last =
        CategorySpend("khác", 0, DateTime.now(), color: colors[7]);
    for (int i = 0; i < list.length; i++) {
      if (data.length < 6) {
        data.add(list[i]);
        data[i].color = colors[i];
      } else if (data.length == 6) {
        last.money = (last.money ?? 0) + list[i].money!;
        if (i == list.length - 1) {
          data.add(last);
        }
      }
    }

    return [
      new charts.Series<CategorySpend, String>(
        id: 'CategorySpend',
        domainFn: (CategorySpend spend, _) => spend.category ?? '',
        measureFn: (CategorySpend spend, _) => spend.money,
        colorFn: (CategorySpend spend, _) =>
            charts.ColorUtil.fromDartColor(spend.color),
        labelAccessorFn: (CategorySpend spend, _) => spend.money.toString(),
        data: data,
      )
    ];
  }
}

class CategoryItem extends StatelessWidget {
  final CategorySpend _item;

  const CategoryItem(this._item);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 10,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(color: _item.color),
          ),
        ),
        Text(_item.category!),
      ],
    );
  }
}
