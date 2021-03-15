import 'package:click_campus_admin/views/students/student_detail/messages_main.dart';
import 'package:flutter/material.dart';

import 'announcement_timeline.dart';

class MessageTabMain extends StatelessWidget {
  final String studentId;

  MessageTabMain(this.studentId);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body:
        Column(
          children: <Widget>[
            TabBar(
              labelColor: Colors.indigo,
              tabs: [
                Tab(text: "Announcements", ),
                Tab(text: "Teacher Wise"),
              ],
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                children: [
                  Announcement(studentId),
                  MessagesMain(studentId),
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}
