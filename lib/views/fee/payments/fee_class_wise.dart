import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeClassWise extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateFeeClassWise();
  }
}

class StateFeeClassWise extends State<FeeClassWise> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  child: Theme(
                      data: Theme.of(context)
                          .copyWith(brightness: Brightness.dark),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                        items: [1, 2, 3, 4]
                            .map((b) => DropdownMenuItem<String>(
                                  child: Text(
                                    "Class $b",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: "Class 1",
                                ))
                            .toList(),
                        onChanged: (b) {},
                        hint: Text(
                          'Select Class',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ))),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Theme(
                      data: Theme.of(context)
                          .copyWith(brightness: Brightness.dark),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                        items: [1, 2, 3, 4]
                            .map((b) => DropdownMenuItem<String>(
                                  child: Text(
                                    "Section $b",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: "Class 1",
                                ))
                            .toList(),
                        onChanged: (b) {},
                        hint: Text(
                          'Select Section',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ))),
                ),
                FlatButton(
                  child: Text(
                    "GO",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  shape: CircleBorder(side: BorderSide(color: Colors.white54)),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            color: Colors.indigo,
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: theInfoTable(),
            ),
          ),
          Container(
            color: Colors.indigo,
            padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
            child: Align(
              child: RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(
                    text: '₹ 546436554',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    children: <TextSpan>[
                      TextSpan(
                          text: '\nCollective Total',
                          style: TextStyle(color: Colors.white, fontSize: 9)),
                    ],
                  )),
              alignment: Alignment.centerRight,
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  Widget theInfoTable() => Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
        },
        children: <TableRow>[]..addAll([
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14
          ].map<TableRow>((b) {
            return _buildItemRow(b);
          })),
      );

  TableRow _buildItemRow(int index) {
    return TableRow(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (index == 0) ? Colors.white : Colors.transparent,
          child: Text(
            (index == 0) ? "Date" : "09 Apr",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (index == 0) ? Colors.white : Colors.transparent,
          child: Text(
            (index == 0) ? "Student" : "Abhishek Sharma",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (index == 0) ? Colors.white : Colors.transparent,
          child: Text(
            (index == 0) ? "Month" : "April + May + April",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (index == 0) ? Colors.white : Colors.transparent,
          child: Text(
            (index == 0) ? "Amount" : "23432",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
