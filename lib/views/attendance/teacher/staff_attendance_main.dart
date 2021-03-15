import 'package:click_campus_admin/views/attendance/teacher/staff_attendance_current.dart';
import 'package:click_campus_admin/views/attendance/teacher/staff_attendance_date.dart';
import 'package:click_campus_admin/views/attendance/teacher/staff_attendance_month.dart';
import 'package:flutter/material.dart';

class StaffAttendanceMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Current",
              ),
              Tab(text: "Month Wise"),
              Tab(text: "Date Wise"),
            ],
          ),
          title: Text('Staff Attendance'),
        ),
        body: TabBarView(
          children: [
            StaffAttendanceCurrent(),
            StaffAttendanceMonth(),
            StaffAttendanceDate(),
          ],
        ),
      ),
    );
  }
}
