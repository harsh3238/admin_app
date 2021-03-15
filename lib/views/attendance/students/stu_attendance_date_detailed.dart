import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../state_helper.dart';

class StuAttendanceDateDetailed extends StatefulWidget {
  final String fromDate, toDate, classId, sectionId, className, sectionName;

  StuAttendanceDateDetailed(this.fromDate, this.toDate, this.classId,
      this.sectionId, this.className, this.sectionName);

  @override
  State<StatefulWidget> createState() {
    return StateStuAttendanceDateDetailed();
  }
}

class StateStuAttendanceDateDetailed extends State<StuAttendanceDateDetailed>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _attendanceData = <dynamic>[];

  void _getAttendanceData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var attendanceResponse = await http.post(
        GConstants.getStudentDateDetailedRoute(await AppData().getSchoolUrl()),
        body: {
          'from_date': widget.fromDate,
          'to_date': widget.toDate,
          'class_id': widget.classId,
          'section_id': widget.sectionId,
          'active_session': sessionToken,
        });

    //print(attendanceResponse.body);

    if (attendanceResponse.statusCode == 200) {
      Map attendanceResponseObject = json.decode(attendanceResponse.body);
      if (attendanceResponseObject.containsKey("status")) {
        if (attendanceResponseObject["status"] == "success") {
          _attendanceData = attendanceResponseObject['data'];
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
        _getAttendanceData();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.className}-${widget.sectionName}"),
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: SingleChildScrollView(
          child: theInfoTable(),
        ),
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
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (item == null) ? Colors.white : Colors.transparent,
            child: Text(
              (item == null) ? "Date" : item['att_date'],
              style: (item == null)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                      fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {},
        ),
        GestureDetector(
          child: Container(
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
          ),
          onTap: () {},
        ),
        GestureDetector(
          child: Container(
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
          ),
          onTap: () {},
        ),
        GestureDetector(
          child: Container(
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
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
