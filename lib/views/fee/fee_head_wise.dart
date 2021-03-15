import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'day_wise_filter.dart';
import 'head_wise_filter.dart';

class FeeHeadWise extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateFeeHeadWise();
  }
}

class StateFeeHeadWise extends State<FeeHeadWise> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  List<Map<String, String>> contentData = [
    {"student_fname": "Student Name : "},
    {"s_r_no": "S.R.No. : "},
    {"class": "Class : "},
    {"term": "Term : "},
    {"amount": "Amount : "},
    {"date_paied": "Date Paid : "},
    {"deposited_by": "Deposited By : "},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Head Wise Report"),
        actions: <Widget>[
          GestureDetector(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text("FILTER", style: TextStyle(fontSize: 16)),
                ),
                ImageIcon(
                  AssetImage("assets/sort.png"),
                  size: 18,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    HeadWiseFilter(),
              ).then((onValue) {

              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: _InputDropdown(
                      labelText: "From",
                      valueText: DateFormat.yMMMd().format(dateFrom),
                      valueStyle: Theme.of(context)
                          .textTheme
                          .subhead
                          .apply(color: Colors.white),
                      onPressed: () async {
                        DateTime firstDate =
                            DateTime.now().subtract(Duration(minutes: 10));
                        final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: dateFrom,
                          firstDate: firstDate,
                          lastDate: DateTime.now().add(Duration(days: 30)),
                        );
                        if (picked != null)
                          setState(() {
                            dateFrom = picked;
                          });
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _InputDropdown(
                      labelText: "To",
                      valueText: DateFormat.yMMMd().format(dateTo),
                      valueStyle: Theme.of(context).textTheme.subhead.apply(
                            color: Colors.white,
                          ),
                      onPressed: () async {
                        DateTime initalDate =
                            DateTime.now().subtract(Duration(minutes: 10));
                        final DateTime picked = await showDatePicker(
                          context: context,
                          initialDate: dateTo,
                          firstDate: initalDate,
                          lastDate: DateTime.now().add(Duration(days: 30)),
                        );
                        if (picked != null)
                          setState(() {
                            dateTo = picked;
                          });
                      },
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      "GO",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    shape:
                        CircleBorder(side: BorderSide(color: Colors.white54)),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              color: Colors.indigo,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(8),
                separatorBuilder: (context, position) {
                  return Container(
                    height: 8,
                  );
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "Receipt No. ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            width: double.infinity,
                            color: Colors.indigo,
                          ),
                          contentTable(index)
                        ],
                      ),
                    ),
                  );
                },
                itemCount: 20,
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }

  Widget contentTable(index) => Padding(
    padding: EdgeInsets.all(0),
    child: Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
      },
      children: <TableRow>[]
        ..addAll(contentData.map<TableRow>((Map<String, String> d) {
          var theKey = d.keys.toList()[0];
          return _buildItemRow(d[theKey], "data");
        })),
    ),
  );

  TableRow _buildItemRow(String left, String right) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(right,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown(
      {Key key,
      this.child,
      this.labelText,
      this.valueText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.transparent)),
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
