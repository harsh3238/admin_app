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

class FeeHeadWiseReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateFeeHeadWiseReport();
  }
}

class StateFeeHeadWiseReport extends State<FeeHeadWiseReport> with StateHelper{
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _duesData = [];
  List<dynamic> _userList = [];
  Map<String, dynamic> _selectedUser;

  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  List<Map<String, String>> contentData = [
   // {"name": "User : "},
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

    var from_date = DateFormat().addPattern("yyyy-MM-dd").format(dateFrom);
    var to_date = DateFormat().addPattern("yyyy-MM-dd").format(dateTo);

    if (_selectedUser != null) {
      modulesResponse = await http.post(
          GConstants.getUserWiseFeesRoute(await AppData().getSchoolUrl()),
          body: {
            'session_id': activeSession.sessionId.toString(),
            'from_date':from_date,
            'to_date':to_date,
            'user_id': _selectedUser["id"].toString(),
            'active_session': sessionToken,
          });
    } else {
      var requestBody = {
        'session_id': activeSession.sessionId.toString(),
        'from_date':from_date,
        'to_date':to_date,
        'active_session': sessionToken,
      };
      modulesResponse = await http.post(
          GConstants.getUserWiseFeesRoute(await AppData().getSchoolUrl()),
          body: requestBody);
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

  void _getFilterData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    var apiResponse = await http.post(
        GConstants.getDayWiseFeesFilterRoute(await AppData().getSchoolUrl()),
        body: {
          'session_id': activeSession.sessionId.toString(),
          'active_session': sessionToken,
        });

    log("${apiResponse.request} ; ${apiResponse.body}");


    if (apiResponse.statusCode == 200) {
      hideProgressDialog();
      Map jsonObject = json.decode(apiResponse.body);
      if (jsonObject.containsKey("success")) {
        if (jsonObject["success"] == true) {
          _userList = jsonObject['users'];
          _getData();
          //List<dynamic> sections = jsonObject['data']['sections'];
          //await DbClassSection().insertClassesSections(classes, sections);
          return null;
        } else {
          return null;
        }
      }
    }else{
      hideProgressDialog();

    }
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
        _getFilterData();
      });
    }


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
                    UserWiseFilter(_userList,_selectedUser),
              ).then((onValue) {
                if(onValue!=null){
                  _selectedUser = onValue[0];
                  _getData();
                }

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
                  GestureDetector(
                    onTap: (){
                      _getData();
                    },
                    child: FlatButton(
                      child: Text(
                        "GO",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      shape:
                          CircleBorder(side: BorderSide(color: Colors.white54)),
                    ),
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
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  return _duesData.length>0?
                  GestureDetector(
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
                  ):Container(
                    child: Text("No data available for selected date"),
                  );
                },
                itemCount: _duesData.length,
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

      //
      double amount = double.parse(item["total"]);
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
