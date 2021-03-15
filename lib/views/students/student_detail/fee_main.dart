import 'dart:convert';

import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FeeMain extends StatefulWidget {
  final String studentId;

  FeeMain(this.studentId);

  @override
  State<StatefulWidget> createState() {
    return _FeeMainState();
  }
}

class _FeeMainState extends State<FeeMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  int activeTab = 0;
  var today = DateFormat().addPattern("dd, MMM yyyy").format(DateTime.now());
  List<dynamic> _duesData = [];
  List<dynamic> _feesData = [];
  bool isNoData = false;
  String feesDue="Not Available";

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
        _getFeesData();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
          child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Image.asset(
                            "assets/fees.jpg",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 20,
                          ),
                          Container(
                            color: Colors.blue.shade50,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Container(
                                      height: 25,
                                      width: (MediaQuery.of(context).size.width/2)-15,
                                      child: FlatButton(
                                        onPressed: () {
                                          setState(() {
                                            activeTab = 0;
                                            _feesData.clear();
                                            isNoData=false;
                                            _getFeesData();
                                          });
                                        },
                                        color: (activeTab == 0)
                                            ? Colors.blue
                                            : Colors.white,
                                        child: Text(
                                          "Fees",
                                          style: TextStyle(
                                              color: (activeTab == 0)
                                                  ? Colors.white
                                                  : Colors.grey.shade700),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Container(
                                      height: 25,
                                      width: (MediaQuery.of(context).size.width/2)-15,
                                      child: FlatButton(
                                        onPressed: () {
                                          setState(() {
                                            activeTab = 1;
                                            _duesData.clear();
                                            isNoData=false;
                                            _getDuesData();
                                          });
                                        },
                                        color: (activeTab == 1)
                                            ? Colors.blue
                                            : Colors.white,
                                        child: Text(
                                          "Dues",
                                          style: TextStyle(
                                              color: (activeTab == 1)
                                                  ? Colors.white
                                                  : Colors.grey.shade700),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40)),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Positioned(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Material(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              child: Container(
                                height: 40,
                                decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Payment History ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: today.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        bottom: 40,
                      ),
                      Positioned(
                        top: 30,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                           /* Text("Due Fee",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),*/
                            Text("₹ "+feesDue,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                    fontSize: 30)),
                            Text("Due Fee",
                                style: TextStyle(color: Colors.indigo))
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              color: Colors.blue.shade50,
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SingleChildScrollView(
              child: activeTab == 0 ? _buildFeesList() : _buildDuesList(),
            )
          ]))
        ],
      )),
    );
  }

  Widget _buildDuesList() {
    return Container(
        child: _duesData.length > 0
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _duesData.length,
                itemBuilder: (BuildContext context, int index) {
                  Map mode = _duesData[index]["fee_mode"];
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(mode['fee_mode_name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                      fontSize: 12)),
                              Text(mode['due_date'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: 12))
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          Column(
                            children: <Widget>[
                              Text("₹ " + _duesData[index]['amount'].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      fontSize: 12)),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.end,
                          )
                        ],
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                    elevation: 0,
                  );
                })
            :  Container(height: 200, child: Center(child: isNoData?Text("No Data Available"):CircularProgressIndicator())));
  }

  Widget _buildFeesList() {
    return Container(
        child: _feesData.length > 0
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _feesData.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: (){

                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                    "Receipt No. :" +
                                        _feesData[index]['rec_no_label']
                                            .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 12)),
                                Text(_feesData[index]['mode'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                        fontSize: 12)),
                                Text(_feesData[index]['paying_date'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 12))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                            Column(
                              children: <Widget>[
                                Text("₹ " + _feesData[index]['paid_amt'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 12)),
                                Text(_feesData[index]['receipt_type'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontSize: 12))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.end,
                            )
                          ],
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      ),
                      elevation: 0,
                    ),
                  );
                })
            :  Container(height: 200, child: Center(child: isNoData?Text("No Data Available"):CircularProgressIndicator())));
  }

  void _getFeesData() async {
     String sessionToken = await AppData().getSessionToken();
     if(activeSession==null || activeSession.sessionId==null){
       StateHelper().showShortToast(context, "Please Select Active Session");
       return;
     }

    var requestBody = {
      'session_id': activeSession.sessionId.toString(),
      'stucare_id': widget.studentId,
      'active_session': sessionToken,
    };
    var modulesResponse =
        await http.post(GConstants.getFeeDataRoute(await AppData().getSchoolUrl()), body: requestBody);

    debugPrint("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          feesDue = modulesResponseObject["feedue"].toString();
          _feesData = modulesResponseObject['data'];

          if (_feesData!=null && _feesData.length> 0) {
            isNoData=false;
          }else{
            _feesData =[];
            isNoData = true;
            //StateHelper().showShortToast(context, "No Data Available");
          }
          setState(() {});
          return null;
        } else {
          isNoData=true;
          setState(() {});
          showSnackBar(modulesResponseObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
    }
  }

  void _getDuesData() async {
    String sessionToken = await AppData().getSessionToken();
    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    var requestBody = {
      'session_id': activeSession.sessionId.toString(),
      'stucare_id': widget.studentId,
      'active_session': sessionToken,
    };
    var modulesResponse =
        await http.post(GConstants.getDuesDataRoute(await AppData().getSchoolUrl()), body: requestBody);

    debugPrint("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {

          _duesData = modulesResponseObject['data'];
          if (_duesData!=null && _duesData.length> 0) {
            isNoData=false;
          }else{
            _duesData = [];
            isNoData = true;
            //StateHelper().showShortToast(context, "No Data Available");
          }
          setState(() {});
          return null;
        } else {
          isNoData=true;
          setState(() {});
          showSnackBar(modulesResponseObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
    }
  }
}
