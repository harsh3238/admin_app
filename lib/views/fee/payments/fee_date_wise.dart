import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeDateWise extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateFeeDateWise();
  }
}

class StateFeeDateWise extends State<FeeDateWise> {
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
                  shape: CircleBorder(side: BorderSide(color: Colors.white54)),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            color: Colors.indigo,
          ),
          Container(
            child: Row(
              children: <Widget>[
                Text(
                  "Ref. ID",
                  style: TextStyle(color: Colors.indigo),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Date",
                  style: TextStyle(color: Colors.indigo),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Amount",
                  style: TextStyle(color: Colors.indigo),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
            color: Colors.white,
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Row(
                  children: <Widget>[
                    Text(
                      "123",
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "10 Apr 2019",
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(
                          text: '₹ 2343',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(
                                text: '\nCash',
                                style: TextStyle(
                                    color: Colors.indigo, fontSize: 10)),
                          ],
                        ))
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                );
              },
              itemCount: 24,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
          Container(
            color: Colors.indigo,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: <Widget>[
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: '₹ 56547',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Cash',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: '₹ 665654',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Cheque',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: '₹ 5465645',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Online',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: '₹ 546436554',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nCollective Total',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    ))
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
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
