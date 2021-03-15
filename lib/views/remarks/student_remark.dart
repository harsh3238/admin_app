import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/views/remarks/add_staff_remark.dart';
import 'package:click_campus_admin/views/remarks/add_student_remark.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/remarks/remark_filter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentRemark extends StatefulWidget {

   @override
  State<StatefulWidget> createState() {
    return _StudentRemarkState();
  }
}

class _StudentRemarkState extends State<StudentRemark> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _remarkData = [];

  List<dynamic> _remarkTypeList = [];
  Map<String, dynamic> _selectedRemarkType;
  int filterClassId, filterSectionId;
  String approvalStatus="";

  void _getRemarks() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    int stucareId = await AppData().getUserLoginId();

    if (activeSession == null || activeSession.sessionId == null) {
      StateHelper().showShortToast(context, "Please Select Active Session");
    }

    Map<String, String> requestBody = {
      'active_session': sessionToken,
      'session_id': activeSession.sessionId.toString(),
      'remark_for':'student'
    };

    if(_selectedRemarkType!=null && _selectedRemarkType["id"]!=0 ) {
      requestBody.putIfAbsent('remark_type_id', () => _selectedRemarkType["id"].toString());
    }

    if(filterClassId!=null ) {
      requestBody.putIfAbsent('class_id', () => filterClassId.toString());
    }

    if(filterSectionId!=null ) {
      requestBody.putIfAbsent('section_id', () => filterSectionId.toString());
    }

    log("${requestBody}");

    var modulesResponse =
        await http.post(GConstants.getAdminRemarksRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);

      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          if(modulesResponseObject.containsKey("remark_approval")){
            approvalStatus = modulesResponseObject['remark_approval'];
          }
          _remarkData = modulesResponseObject['data'];
          if (_remarkData.length == 0) {
            showSnackBar("No Remark Found", color: Colors.indigo);
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

  void _getAllClassesAndSections() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var allClassesResponse = await http.post(
        GConstants.getAllClassesAndSectionRoute(await AppData().getSchoolUrl()),
        body: {
          'active_session': sessionToken,
        });

    log("${allClassesResponse.request} : ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> classes = allClassesObject['data']['class'];
          List<dynamic> sections = allClassesObject['data']['sections'];
          await DbClassSection().insertClassesSections(classes, sections);
          hideProgressDialog();
          _getRemarks();
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(allClassesObject["message"]);
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
        _getRemarkType();
        _getAllClassesAndSections();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(title: Text("Remarks"), actions: <Widget>[
        FlatButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>RemarkFilter(
                    _remarkTypeList, _selectedRemarkType, filterClassId, filterSectionId),
                //RemarkFilter(_remarkTypeList,_selectedRemarkType, _selectedClass, _selectedSection),
              ).then((onValue) {
                if(onValue!=null){
                  _selectedRemarkType = onValue[0];
                  filterClassId = onValue[1];
                  filterSectionId = onValue[2];
                  _getRemarks();
                }
              });
            },
            child: Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToModule(AddStudentRemark());
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
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
                  padding: const EdgeInsets.only(left:4.0, right: 4, top: 4),
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
                              _remarkData[index]['photo_student']!=null &&_remarkData[index]['photo_student']!=""?
                              CachedNetworkImage(
                                width: 40.0,
                                height: 40.0,
                                imageUrl: _remarkData[index]
                                ['photo_student'],
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                placeholder: (context, url) => Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        image: new ExactAssetImage(
                                            'assets/images/ic_profile.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ):
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
                            height: 40,
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
                        Visibility(
                          visible: approvalStatus=="required"&&_remarkData[index]['visibility']==1?true:false,
                          child: _getActionButtons(_remarkData[index]['remark_id']!=null?_remarkData[index]['remark_id'].toString():"",
                              _remarkData[index]['visibility'],_remarkData[index]['status']),
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

  Widget _getActionButtons(String remarkId, int visibility, String status) {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 15.0, bottom: 15),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 20.0, left: 20.0),
              child: Container(
                  height: 35,
                  child: new RaisedButton(
                    child: new Text(status!="pending" && status=="approved" ?"Approved":"Approve"),
                    textColor: Colors.white,
                    color: status!="pending" && status=="approved" ?Color(0xff509F54):Colors.black26,
                    onPressed: () async {
                      if(status=="pending"){
                        _changeRemarkStatus("approved", remarkId);
                      }

                    },
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 20.0, left: 20.0),
              child: Container(
                  height: 35,
                  child: new RaisedButton(
                    child: new Text(status!="pending" && status=="disapproved" ?"Disapproved":"Disapprove"),
                    textColor: Colors.white,
                    color: status!="pending" && status=="disapproved" ?Color(0xffBD4530):Colors.black26,
                    onPressed: () {
                      if(status=="pending"){
                        _changeRemarkStatus("disapproved", remarkId);
                      }
                    },
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
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

  void _changeRemarkStatus(String status, String remarkId) async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();

    Map<String, String> requestBody = {
      'active_session': sessionToken,
      'session_id': activeSession.sessionId.toString(),
      'remark_id': remarkId ,
      'remark_status':status   //approved, disapproved
    };

    debugPrint("${requestBody}");
    modulesResponse =
    await http.post(GConstants.getChangeRemarkStatusRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          hideProgressDialog();
          setState(() {
          });
          _getRemarks();
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

}
