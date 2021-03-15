import 'dart:async';
import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/remarks/remark_filter.dart';
import 'package:click_campus_admin/views/students/student_remark_filter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../state_helper.dart';

class StudentRemarkMain extends StatefulWidget {
  final String studentId;

  StudentRemarkMain(this.studentId);

  @override
  State<StatefulWidget> createState() {
    return _StudentRemarkMainState();
  }
}

class _StudentRemarkMainState extends State<StudentRemarkMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _remarkData = [];

  List<dynamic> _remarkTypeList = [];
  Map<String, dynamic> _selectedRemarkType;

  void _getRemarks() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var mActiveSession = await SessionDbProvider().getActiveSession();

    if (mActiveSession == null || mActiveSession.sessionId == null) {
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }
    var requestBody;
    if (_selectedRemarkType == null || _selectedRemarkType["id"] == 0) {
      requestBody = {
        'active_session': sessionToken,
        'session_id': mActiveSession.sessionId.toString(),
        'stucare_id': widget.studentId,
        'page_number': "0",
        'limit': "100",
      };
    } else {
      requestBody = {
        'active_session': sessionToken,
        'session_id': mActiveSession.sessionId.toString(),
        'stucare_id': widget.studentId,
        'page_number': "0",
        'limit': "100",
        'remark_type_id': _selectedRemarkType["id"].toString(),
      };
    }
    var modulesResponse =
        await http.post(GConstants.getAdminRemarksRoute(await AppData().getSchoolUrl()), body: requestBody);

    debugPrint("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);

      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          _remarkData = modulesResponseObject['data'];
          if (_remarkData.length == 0) {
            showSnackBar("No Remark Found", color: Colors.indigo);
          }
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["error"]);
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

  void _getRemarkType() async {
    String sessionToken = await AppData().getSessionToken();
    var allClassesResponse = await http.post(GConstants.getRemarkTypeRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    debugPrint("${allClassesResponse.request} : ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("success")) {
        if (allClassesObject["success"] == true) {
          _remarkTypeList = allClassesObject['data'];
          _remarkTypeList.add({"remark": "All Remarks", "id": 0});
          setState(() {});
          return null;
        } else {
          showSnackBar(allClassesObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
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
        _getRemarks();
        _getRemarkType();
      });
    }

    return Scaffold(
      key: _scaffoldState,

      body: Column(
        children: <Widget>[
          Container(
            height: 60,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(4),
                          child: Text("FILTER", style: TextStyle(fontSize: 16)),
                        ),
                        Icon(
                          Icons.filter_alt_outlined,
                          color: Colors.indigo,
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => StudentRemarkFilter(_remarkTypeList, _selectedRemarkType),
                    ).then((onValue) {
                      if (onValue != null) {
                        _selectedRemarkType = onValue[0];
                        _getRemarks();
                      }
                    });
                  },
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemBuilder: (context, index) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  /*navigateToModule(ViewRemark( _remarkData[index]['student_name'],
                      "${_remarkData[index]['class']} - ${_remarkData[index]['section']}",
                      _remarkData[index]['description'],
                      _remarkData[index]['remark'],
                      _remarkData[index]['visibility'],
                      _remarkData[index]['category'],
                      _remarkData[index]['creator']
                  ));*/
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: _remarkData[index]['category'] == 1 ? Color(0xff509F54) : Color(0xffBD4530),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.account_circle,
                                size: 40,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: <Widget>[
                                  Text(_remarkData[index]['student_name'].toString(),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                                  Text("${_remarkData[index]['class']} - ${_remarkData[index]['section']}",
                                      style: TextStyle(color: Colors.white, fontSize: 13)),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: IconButton(
                                      icon: Icon(
                                        _remarkData[index]['category'] == 1
                                            ? Icons.thumb_up_outlined
                                            : Icons.thumb_down_outlined,
                                        size: 35,
                                        color: _remarkData[index]['category'] == 1 ? Colors.indigo : Colors.indigo,
                                      ),
                                      highlightColor: Colors.grey,
                                      onPressed: () {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 4),
                          child: Container(
                            color: Colors.white12,
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 2, // 20%
                                  child: Container(
                                    child: Text(_remarkData[index]['description'],
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          child: Container(
                            height: 1,
                            color: Colors.black12,
                          ),
                        ),
                        Container(
                          color: Colors.white12,
                          height: 40,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 2, // 60%
                                child: Container(
                                  child: Text(
                                    "${_remarkData[index]['created_date']} at ${_remarkData[index]['created_time']}",
                                    style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xffCACFCA)),
                                  ),
                                ),
                              ),
                              Spacer(),
                              SizedBox(width: 24, height: 24, child: Image.asset('assets/images/ic_teacher.jpg')),
                              Text(
                                _remarkData[index]['creator'],
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    elevation: 4,
                  ),
                ),
              );
            },
            itemCount: _remarkData.length,
          ))
        ],
      ),
    );
  }

  void navigateToModule(Widget module) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => module),
    );
  }
}
