import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../state_helper.dart';
import 'staff_attendance_current_detailed.dart';


class StaffAttendanceCurrent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStaffAttendanceCurrent();
  }
}

class StateStaffAttendanceCurrent extends State<StaffAttendanceCurrent> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _attendanceData = <dynamic>[];
  Map<String, dynamic> _allEmpsMetaData = Map();

  void _getAttendanceData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var attendanceResponse = await http.post(GConstants.getStaffCurrentRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
      'session_id': activeSession.sessionId.toString(),
    });

    log("${attendanceResponse.request}:${attendanceResponse.body}");

    if (attendanceResponse.statusCode == 200) {
      Map attendanceResponseObject = json.decode(attendanceResponse.body);
      if (attendanceResponseObject.containsKey("status")) {
        if (attendanceResponseObject["status"] == "success") {
          _attendanceData = attendanceResponseObject['data'];
          _allEmpsMetaData = attendanceResponseObject['meta'];
          _attendanceData.insert(0, null);
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(attendanceResponseObject["message"]);
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
        _getAttendanceData();
      });
    }
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: theInfoTable(),
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
                      text: _allEmpsMetaData['all_emps'] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _allEmpsMetaData['all_present'] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nPresent',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _allEmpsMetaData['all_absent'] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nAbsent',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _allEmpsMetaData['late'] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nLate',
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

  Widget theInfoTable() => Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
        },
        children: <TableRow>[]..addAll(_attendanceData.map<TableRow>((b) {
          return _buildItemRow(b);
        })),
      );

  TableRow _buildItemRow(Map<String, dynamic> item) {
    return TableRow(
      children: <Widget>[
        GestureDetector(child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Department" : item['name'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ), onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
                return StaffAttendanceCurrentDetailed(item['id']);
              }));
        },),
        GestureDetector(child:  Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Present" : item['present'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ), onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
                return StaffAttendanceCurrentDetailed(item['id']);
              }));
        },),
        GestureDetector(child:  Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Absent" : item['absent'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ), onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
                return StaffAttendanceCurrentDetailed(item['id']);
              }));
        },),
        GestureDetector(child:  Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Late" : item['late'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ), onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
                return StaffAttendanceCurrentDetailed(item['id']);
              }));
        },),

      ],
    );
  }
}
