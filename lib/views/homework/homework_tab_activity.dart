import 'package:click_campus_admin/views/homework/homework_all.dart';
import 'package:click_campus_admin/views/homework/homework_class_wise.dart';
import 'package:click_campus_admin/views/homework/homework_teacher_wise.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/students/search.dart';
import 'package:flutter/material.dart';

class HomeworkTabsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHomeworkTabsMain();
  }
}

class StateHomeworkTabsMain extends State<HomeworkTabsMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  HomeworkAll _tabViewOne = HomeworkAll();
  HomeworkTeacherWise _tabViewTwo = HomeworkTeacherWise();
  HomeworkClassWise _tabViewThree = HomeworkClassWise();

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: activeSession != null
                  ? Text(activeSession.sessionName)
                  : Container(
                      height: 0,
                    ),
              textColor: Colors.white,
              disabledColor: Colors.white,
              onPressed: () {
                var dialog = SimpleDialog(
                  title: const Text('Change Session'),
                  children: allSessions.map((oneSessionItem) {
                    return SimpleDialogOption(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          oneSessionItem.sessionName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, oneSessionItem);
                      },
                    );
                  }).toList(),
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) => dialog,
                ).then((value) {
                  //print(value);
                });
              },
            ),
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchList(),
                    ));
              },
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Current"),
              Tab(text: "Teacher Wise"),
              Tab(text: "Class Wise")
            ],
          ),
          title: Text('Homework'),
        ),
        body: TabBarView(
          children: [_tabViewOne, _tabViewTwo, _tabViewThree],
        ),
      ),
    );
  }
}
