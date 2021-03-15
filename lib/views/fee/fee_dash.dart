import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/fee/payments/fee_head_wise_report.dart';
import 'package:click_campus_admin/views/fee/report_list.dart';
import 'package:click_campus_admin/views/fee/student_ledger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../state_helper.dart';
import 'dash_card.dart';
import 'fee_day_wise_report.dart';
import 'fee_head_wise.dart';
import 'fee_student_head_wise.dart';
import 'fee_user_wise_report.dart';

class FeeDash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FeeDashState();
  }
}

class FeeDashState extends State<FeeDash> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _transactionsData = [];
  List<dynamic> _collectionData = [];
  Map<String, dynamic> _empData;

  void _getData() async {
    showProgressDialog();
    int loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getFeeDashDataRoute(await AppData().getSchoolUrl()),
        body: {
          'login_id': loginId.toString(),
          'active_session': sessionToken,
        });

    log("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _transactionsData = modulesResponseObject['transactions'];
          _collectionData = modulesResponseObject['collection'];
          _empData = modulesResponseObject['employee'][0];
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

    final _media = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldState,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
              child: Container(
            color: Colors.grey.shade50,
            height: _media.height / 2.5,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 32, bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Colors.deepPurpleAccent, Colors.purple]),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      height: _media.longestSide <= 775
                          ? _media.height / 4
                          : _media.height / 4.3,
                      child: _collectionData.length > 0
                          ? DashCard(_collectionData)
                          : Container(
                              height: 0,
                            ),
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 12)),
                ),
                Positioned(
                  top: 80,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _empData != null
                                ? (_empData['emp_photo'] != null
                                    ? NetworkImage(_empData['emp_photo'])
                                    : AssetImage("assets/profile.png"))
                                : AssetImage("assets/profile.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              _empData != null ? _empData['name'] : '',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              DateFormat()
                                  .addPattern("dd MMMM")
                                  .format(DateTime.now())
                                  .toString(),
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          )
                        ],
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ),
              ],
            ),
          )),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: const EdgeInsets.all(4.0),
                    childAspectRatio: 4,
                    children: [
                      GestureDetector(
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  color: Colors.grey.shade100),
                              child: Image(
                                  image:
                                      AssetImage("assets/fee_dash/ic_day.png")),
                            ),
                            Text("Day Wise",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return FeeDayWise();
                          }));
                        },
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                                return FeeHeadWiseReport();
                              }));

                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  color: Colors.grey.shade100),
                              child: Image(
                                  image:
                                      AssetImage("assets/fee_dash/ic_head.png")),
                            ),
                            Text("Head Wise",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  color: Colors.grey.shade100),
                              child: Image(
                                  image: AssetImage(
                                      "assets/fee_dash/ic_user.png")),
                            ),
                            Text("User Wise Collection",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return FeeUserWiseReport();
                          }));
                        },
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                                return FeeStudentHeadWise();
                              }));

                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  color: Colors.grey.shade100),
                              child: Image(
                                  image: AssetImage(
                                      "assets/fee_dash/ic_student.png")),
                            ),
                            Text("Student Head Wise",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  color: Colors.grey.shade100),
                              child: Image(
                                  image: AssetImage(
                                      "assets/fee_dash/ic_ledger.png")),
                            ),
                            Text("Student Ledger",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return StudentLedger();
                          }));
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                                return ReportList();
                              }));
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  color: Colors.grey.shade100),
                              child: Image(
                                  image:
                                      AssetImage("assets/fee_dash/ic_more.png")),
                            ),
                            Text("More Reports",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      )
                    ]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Recent Transactions",
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: ListTile(
                  leading: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            _transactionsData[index]['photo_student'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    child: Align(
                      child: (!_transactionsData[index]['green_badge'] &&
                              !_transactionsData[index]['is_ever_late'])
                          ? Container(
                              height: 0,
                            )
                          : Container(
                              decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: (_transactionsData[index]
                                              ['is_ever_late'] ==
                                          true)
                                      ? Colors.red
                                      : Colors.green),
                              height: 16,
                              width: 16,
                            ),
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                  title: Text(_transactionsData[index]['student_name']),
                  subtitle: Text(
                    "Class : ${_transactionsData[index]['class']} - ${_transactionsData[index]['section']} | S.R.No : ${_transactionsData[index]['s_r_no']}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        text: '₹ ${_transactionsData[index]['paid_amt']}',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  '\n${_transactionsData[index]['paying_mode'].toString().toUpperCase()}',
                              style: TextStyle(
                                  color: Colors.indigo, fontSize: 10)),
                        ],
                      )),
                  onTap: () {},
                ),
              );
            }, childCount: _transactionsData.length),
          )
        ],
      ),
    );
  }
}
