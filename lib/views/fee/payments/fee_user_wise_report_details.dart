import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/fee/user_wise_filter.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class FeeUserWiseReportDetails extends StatefulWidget {
  String userId;
  String fromDate, toDate;

  FeeUserWiseReportDetails(this.userId, this.fromDate, this.toDate);

  @override
  State<StatefulWidget> createState() {
    return StateFeeUserWiseReportDetails();
  }
}

class StateFeeUserWiseReportDetails extends State<FeeUserWiseReportDetails> with StateHelper{
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _duesData = [];

  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  List<Map<String, String>> contentData = [
    {"name": "User : "},
    {"cash": "Cash : "},
    {"cheque": "Cheque : "},
    {"dd": "DD : "},
    {"pos": "POS : "},
    {"bank": "Bank : "},
    {"online": "Online : "},
    {"total": "Total : "},
  ];

  void _getData() async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();

    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    if (widget.userId != null) {
      modulesResponse = await http.post(
          GConstants.getUserWiseFeesRoute(await AppData().getSchoolUrl()),
          body: {
            'session_id': activeSession.sessionId.toString(),
            'from_date':widget.fromDate,
            'to_date':widget.toDate,
            'user_id': widget.userId,
            'active_session': sessionToken,
          });
    } else {
      var requestBody = {
        'session_id': activeSession.sessionId.toString(),
        'to_date':widget.toDate,
        'user_id': widget.userId,
        'active_session': sessionToken,
      };

      log("${requestBody}");
      modulesResponse = await http.post(
          GConstants.getUserWiseFeesRoute(await AppData().getSchoolUrl())
          , body: requestBody);
      debugPrint("${requestBody}");
    }


    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          _duesData = modulesResponseObject['data'];
          if(_duesData.length==0){
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
      appBar: AppBar(
        title: Text("User Wise Report Details"),
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: <Widget>[
            Expanded(
              child: _duesData.length>0?
              ListView.separated(
                padding: EdgeInsets.all(4),
                separatorBuilder: (context, position) {
                  return Container(
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child:
                    Card(
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
                                    _duesData[index]["fee_header_name"]!=null?
                                    "FEE HEAD: "+_duesData[index]["fee_header_name"].toString().toUpperCase():"Fee Head: Not Available",
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
                itemCount: _duesData.length,
              ):Container(
                child: Center(child: Text("No data available for selected date")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:0.0, right:0.0),
              child: Card(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Grand Total: "+getTotalAmount(),
                              style:
                              TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            )

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
          return _buildItemRow(d[theKey], _duesData[index][theKey]);
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

  String getTotalAmount() {
    double totalAmount=0;
    for(final item in _duesData){

      double amount = double.parse(item["total"].toString());
      if(amount!=null){
        totalAmount= totalAmount+amount;
      }

    }
    return totalAmount.toString();
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
