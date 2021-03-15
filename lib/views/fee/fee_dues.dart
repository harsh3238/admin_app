import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';
import 'dues/dues_filter_admin.dart';
import 'dues_filter.dart';

class FeeDues extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateFeeDues();
  }
}

class StateFeeDues extends State<FeeDues> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _duesData = [];

  List<dynamic> _modeList = [];
  List<dynamic> _classList = [];
  List<dynamic> _sectionList = [];
  List<dynamic> _reportTypeList = [];

  Map<String, dynamic> _filteredReportType;
  int _filterClassId, _filterSectionId, _filteredModeId;


  void _getReportTypes() async {
    _reportTypeList.add({'key': 'with_arrear', 'value': 'With Arrear'});
    _reportTypeList.add({'key': 'with_transport', 'value': 'With Transport'});
    _reportTypeList.add({'key': 'with_transport_arrear', 'value': 'With Transport And Arrear'});
    setState(() {});
  }

  void _getData() async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();

    Map requestBody = {
      'active_session': sessionToken,
      'session_id': activeSession.sessionId.toString(),
    };

    if (_filteredModeId!=null) {
      requestBody.putIfAbsent('mode_id', () => _filteredModeId.toString());
    }

    if (_filterClassId!=null) {
      requestBody.putIfAbsent('class_id', () => _filterClassId.toString());
    }

    if (_filterSectionId!=null) {
      requestBody.putIfAbsent('section_id', () => _filterSectionId.toString());
    }

    if (_filteredReportType!=null) {
      requestBody.putIfAbsent('report_type', () => _filteredReportType['key']);
    }

    log("${requestBody}");

    modulesResponse = await http.post(GConstants.getAdminFeeDuesRoute(await AppData().getSchoolUrl()),
        body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          _duesData = modulesResponseObject['data'];
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

    var allClassesResponse = await http.post(
        GConstants.getAdminFeeDuesFilterRoute(await AppData().getSchoolUrl()),
        body: {
          'active_session': sessionToken,
          'session_id': activeSession.sessionId.toString(),
        });

    log("${allClassesResponse.request} ; ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      hideProgressDialog();
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("success")) {
        if (allClassesObject["success"] == true) {
          _classList = allClassesObject['data']['classes'];
          _sectionList = allClassesObject['data']['sections'];
          _modeList = allClassesObject['data']['modes'];
          //_getData();
        } else{
          StateHelper().showShortToast(context, "Unable to get filter data");
        }
      }
    }else{
      hideProgressDialog();
      StateHelper().showShortToast(context, "Unable to get filter data");
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
        _getReportTypes();
        _getFilterData();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Month's Dues"),
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
                    DuesFilterAdmin(_modeList, _classList, _sectionList, _reportTypeList,
                        _filteredModeId, _filterClassId, _filterSectionId, _filteredReportType),
              ).then((onValue) {
                if(onValue!=null){
                  _filteredModeId = onValue[0];
                  _filterClassId = onValue[1];
                  _filterSectionId = onValue[2];
                  _filteredReportType = onValue[3];
                  _getData();
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: _duesData.length > 0
            ? CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: ListTile(
                          leading: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: _duesData[index]['photo_student'] != null
                                    ? NetworkImage(
                                        _duesData[index]['photo_student'] ?? '')
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
                          title: Text(_duesData[index]['student_name']),
                          subtitle: Text(
                            "Class : ${_duesData[index]['class_name']} - ${_duesData[index]['section_name']} | S.R.No : ${_duesData[index]['s_r_no']}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                text: '₹ ${_duesData[index]['total'].toString()}',
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 12),
                                children: <TextSpan>[],
                              )),
                          onTap: () {},
                        ),
                      );
                    }, childCount: _duesData.length),
                  )
                ],
              )
            : Center(
                child: Text("Please click on filter button and select month for dues"),
              ),
      ),
    );
  }
}
