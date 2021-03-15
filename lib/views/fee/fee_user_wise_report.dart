import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/fee/payments/fee_user_wise_report_details.dart';
import 'package:click_campus_admin/views/fee/user_wise_filter.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class FeeUserWiseReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateFeeUserWiseReport();
  }
}

class StateFeeUserWiseReport extends State<FeeUserWiseReport> with StateHelper{
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _duesData = [];
  List<dynamic> _userList = [];
  Map<String, dynamic> _selectedUser;

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


  void _getFilterData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var from_date = DateFormat().addPattern("yyyy-MM-dd").format(dateFrom);
    var to_date = DateFormat().addPattern("yyyy-MM-dd").format(dateTo);

    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    var apiResponse = await http.post(
        GConstants.getUserWiseFeesFilterRoute(await AppData().getSchoolUrl()),
        body: {
          'session_id': activeSession.sessionId.toString(),
          'active_session': sessionToken,
          'from_date':from_date,
          'to_date':to_date,
        });

    log("${apiResponse.request} : ${apiResponse.body}");


    if (apiResponse.statusCode == 200) {
      hideProgressDialog();
      Map jsonObject = json.decode(apiResponse.body);
      if (jsonObject.containsKey("success")) {
        if (jsonObject["success"] == true) {
          _userList = jsonObject['data'];
          setState(() {});
          //_getData();
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
        title: Text("User Wise Report"),
        /*actions: <Widget>[
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
        ],*/
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
                      _getFilterData();
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
                padding: EdgeInsets.all(4),
                separatorBuilder: (context, position) {
                  return Container(
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  return _userList.length>0?
                  getListItem(index)
                      :Container(
                    child: Text("No data available for selected date"),
                  );
                },
                itemCount: _userList.length,
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

  Widget getListItem(int index){
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: ListTile(
        leading: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _userList[index]['img'] != null
                  ? NetworkImage(
                  _userList[index]['img'] ?? '')
                  : AssetImage("assets/profile.png"),
              fit: BoxFit.cover,
            ),
            borderRadius:
            BorderRadius.all(Radius.circular(25.0)),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          ),
        ),
        title: Text(_userList[index]["name"]),
        subtitle: Text(
          "${_userList[index]['paying_date']}",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(fontSize: 12),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:<Widget>[
              RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(
                    text: '₹ ${_userList[index]['total_collection'].toString()}',
                    style: TextStyle(
                        color: Colors.green.shade700, fontSize: 16, fontWeight: FontWeight.normal),
                    children: <TextSpan>[],
                  )
              ),
              SizedBox(width: 10,),
              Icon(Icons.arrow_forward_ios_outlined, color: Colors.black26,size: 16,)
            ],
          ),
        ),
        onTap: () {
          var from_date = DateFormat().addPattern("yyyy-MM-dd").format(dateFrom);
          var to_date = DateFormat().addPattern("yyyy-MM-dd").format(dateTo);

          Navigator.push(context, MaterialPageRoute(
              builder: (BuildContext context) {
                return FeeUserWiseReportDetails(_userList[index]["user_id"].toString(), from_date, to_date);
              }));
        },
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
    for(final item in _userList){

      int amount = item["total_collection"];
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
