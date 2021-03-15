import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/students/search.dart';
import 'package:click_campus_admin/views/students/students_classes.dart';
import 'package:click_campus_admin/views/students/students_list.dart';
import 'package:flutter/material.dart';

class StudentsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStudentsMain();
  }
}

class StateStudentsMain extends State<StudentsMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  StudentClasses _tabViewOne = StudentClasses();
  StudentsList _tabViewTwo = StudentsList();

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                  setActiveSession(value, this).then((v) {
                    _tabViewOne.sessionChanged();
                  });
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
              Tab(text: "Class Strength",),
              Tab(text: "Students")
            ],
          ),
          title: Text('Students'),
        ),
        body: TabBarView(
          children: [
            _tabViewOne,
            _tabViewTwo,
          ],
        ),
      ),
    );
  }
}
