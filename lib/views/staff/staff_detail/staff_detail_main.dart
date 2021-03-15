import 'package:click_campus_admin/views/staff/staff_detail/staff_attendance_detail.dart';
import 'package:click_campus_admin/views/staff/staff_detail/staff_profile.dart';
import 'package:flutter/material.dart';

class StaffDetailMain extends StatelessWidget {
  String loginId;

  StaffDetailMain(this.loginId);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Gereral",
              ),
              Tab(text: "Attendance"),
            ],
          ),
          title: Text('Staff Details'),
        ),
        body: TabBarView(
          children: [
            ProfileOnePage(loginId),
            StaffAttendanceDetail(),
          ],
        ),
      ),
    );
  }
}
