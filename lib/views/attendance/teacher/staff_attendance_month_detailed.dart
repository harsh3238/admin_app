import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../state_helper.dart';

class StaffAttendanceMonthDetailed extends StatefulWidget {
  final String month, empId, empName;

  StaffAttendanceMonthDetailed(this.month, this.empId, this.empName);

  @override
  State<StatefulWidget> createState() {
    return StateStaffAttendanceMonthDetailed();
  }
}

class StateStaffAttendanceMonthDetailed
    extends State<StaffAttendanceMonthDetailed> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _attendanceData = <dynamic>[];

  void _getAttendanceData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var attendanceResponse = await http.post(
        GConstants.getStaffMonthDetailedRoute(await AppData().getSchoolUrl()),
        body: {'month': widget.month, 'emp_id': widget.empId, 'active_session': sessionToken,});

    //print(attendanceResponse.body);

    if (attendanceResponse.statusCode == 200) {
      Map attendanceResponseObject = json.decode(attendanceResponse.body);
      if (attendanceResponseObject.containsKey("status")) {
        if (attendanceResponseObject["status"] == "success") {
          _attendanceData = attendanceResponseObject['data'];
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
        title: Text(widget.empName),
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: ListView.separated(
          separatorBuilder: (context, position) {
            return Divider(
              height: 0,
            );
          },
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_attendanceData[index]['att_date']),
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              trailing: Text(_attendanceData[index]['att_status'] ?? ''),
            );
          },
          itemCount: _attendanceData.length,
        ),
      ),
    );
  }
}
