import 'package:click_campus_admin/views/attendance/students/stu_attendance_current.dart';
import 'package:click_campus_admin/views/attendance/students/stu_attendance_date.dart';
import 'package:click_campus_admin/views/attendance/students/stu_attendance_month.dart';
import 'package:flutter/material.dart';

import 'mark_attendance/take_attendance_tab.dart';
import 'mark_attendance/mark_attendance_main.dart';

class StudentAttendanceMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: Text('Mark Attendance'),
              textColor: Colors.white,
              disabledColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return MarkAttendanceMain();
                }));
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Current",
              ),
              Tab(text: "Month Wise"),
              Tab(text: "Date Wise"),
            ],
          ),
          title: Text('Student Attendance'),
        ),
        body: TabBarView(
          children: [
            StudentAttendanceCurrent(),
            StudentAttendanceMonth(),
            StuAttendanceDate(),
          ],
        ),
      ),
    );
  }
}
