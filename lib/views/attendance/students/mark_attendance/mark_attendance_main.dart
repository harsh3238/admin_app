import 'package:click_campus_admin/views/attendance/students/mark_attendance/reports_tab.dart';
import 'package:click_campus_admin/views/attendance/students/mark_attendance/update_tab.dart';
import 'package:flutter/material.dart';

import 'absentees_tab.dart';
import 'take_attendance_tab.dart';

class MarkAttendanceMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Attendance"),
              Tab(text: "Update"),
              Tab(text: "Absentees"),
              Tab(text: "Reports"),
            ],
          ),
          title: Text('Mark Attendance'),
        ),
        body: TabBarView(
          children: [
            TakeAttendance(),
            UpdatesTap(),
            AbsenteesTab(),
            ReportsTab(),
          ],
        ),
      ),
    );
  }
}
