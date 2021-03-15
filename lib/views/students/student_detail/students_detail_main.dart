import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/students/student_detail/attendance_main.dart';
import 'package:click_campus_admin/views/students/student_detail/exams_main.dart';
import 'package:click_campus_admin/views/students/student_detail/fee_main.dart';
import 'package:click_campus_admin/views/students/student_detail/messages_main.dart';
import 'package:click_campus_admin/views/students/student_detail/student_remark_main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'messages_tab_main.dart';
import 'student_general_profile.dart';

class StudentsDetailMain extends StatefulWidget {
  final Map<String, dynamic> studentData;

  StudentsDetailMain(this.studentData);

  @override
  State<StatefulWidget> createState() {
    return StateStudentsDetailMain();
  }
}

class StateStudentsDetailMain extends State<StudentsDetailMain>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  Map<String, dynamic> _studentProfileData;
  List<dynamic> _examTerms;

  void _getStudentDetailData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      hideProgressDialog();
      return;
    }

    var profileResponse = await http.post(
        GConstants.getStudentDetailsRoute(await AppData().getSchoolUrl()),
        body: {
          'stucare_id': widget.studentData['stucare_id'],
          'session_id': activeSession.sessionId.toString(),
          'active_session': sessionToken,
        });

    log(profileResponse.body, name: "${profileResponse.request}");

    if (profileResponse.statusCode == 200) {
      Map profileResponseObject = json.decode(profileResponse.body);
      if (profileResponseObject.containsKey("status")) {
        if (profileResponseObject["status"] == "success") {
          _studentProfileData = profileResponseObject['profile_data'];
          _examTerms = profileResponseObject['exam_terms'];
          setState(() {});
          hideProgressDialog();
          return null;
        } else {
          showSnackBar(profileResponseObject["message"]);
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
        _getStudentDetailData();
      });
    }
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "General"),
              Tab(text: "Fee"),
              Tab(text: "Attendance"),
              Tab(text: "Exams"),
              Tab(text: "Remarks"),
              Tab(text: "Messages")
            ],
            labelPadding: EdgeInsets.all(0),
          ),
          title: Text('Student Details'),
        ),
        body: TabBarView(
          children: [
            _studentProfileData != null
                ? StudentProfile(
                    widget.studentData['stucare_id'], _studentProfileData)
                : Container(),
            FeeMain(widget.studentData['stucare_id'].toString()),
            AttendanceMain(widget.studentData['stucare_id'].toString()),
            ExamsMain(widget.studentData['stucare_id'].toString()),
            StudentRemarkMain(widget.studentData['stucare_id'].toString()),
            MessageTabMain(widget.studentData['stucare_id'].toString()),
          ],
        ),
      ),
    );
  }
}
