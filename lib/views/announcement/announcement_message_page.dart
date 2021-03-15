import 'package:click_campus_admin/views/message/message_detail.dart';
import 'package:click_campus_admin/views/message/message_staff.dart';
import 'package:click_campus_admin/views/message/messages_inbox.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';

class AnnouncementMessages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAnnouncementMessages();
  }
}

class StateAnnouncementMessages extends State<AnnouncementMessages>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
              return Scaffold(
                body: MessageInbox(),
              );
            }));
          },
          child: Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "My Inbox",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
              return Scaffold(
                body: MsgStudents(),
              );
            }));
          },
          child: Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Students Messages",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
              return Scaffold(
                body: MsgStaff(),
              );
            }));
          },
          child: Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Staff Messages",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
