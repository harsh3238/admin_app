import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/fee/payments/student_headwise_filter.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class CancelledReceiptReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateCancelledReceiptReport();
  }
}

class StateCancelledReceiptReport extends State<CancelledReceiptReport> with StateHelper{
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  List<dynamic> _receiptData = [];

  List<Map<String, String>> contentData = [
    {"s_r_no": "S.R.No. : "},
    {"student_name": "Student Name : "},
    {"class_name": "Class : "},
    {"section_name": "Section : "},
    {"paid_amt": "Amount : "},
    {"mode": "Mode : "},
    {"reason": "Reason : "},
    {"paying_date": "Paying Date : "},
  ];


  void _getData() async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();
    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    var from_date = DateFormat().addPattern("yyyy-MM-dd").format(dateFrom);
    var to_date = DateFormat().addPattern("yyyy-MM-dd").format(dateTo);

    Map requestBody = {
      'session_id': activeSession.sessionId.toString(),
      'from_date': from_date,
      'to_date': to_date,
      'active_session': sessionToken,
      'page_no': '0',
      'limit': '100',
    };


    modulesResponse =
    await http.post(GConstants.getCancelledReceiptsRoute(await AppData().getSchoolUrl()), body: requestBody);
    debugPrint("${requestBody}");

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          _receiptData = modulesResponseObject['data'];
          if(_receiptData.length==0){
            StateHelper().showShortToast(context, "No Data Available");
          }
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
    }
    hideProgressDialog();
  }


  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }


  @override
  Widget build(BuildContext context) {

    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        activeSession = await SessionDbProvider().getActiveSession();
        _getData();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Cancelled Receipt Report"),

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
                          firstDate: DateTime.now().subtract(Duration(days: 360)),
                          lastDate: DateTime.now(),
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
                          firstDate: DateTime.now().subtract(Duration(days: 360)),
                          lastDate: DateTime.now(),
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
                    onPressed: () {
                      _getData();
                    },
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
                                    "Receipt No. "+_receiptData[index]['rec_no'].toString(),
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
                itemCount: _receiptData.length,
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
          return _buildItemRow(d[theKey], _receiptData[index][theKey].toString());
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
