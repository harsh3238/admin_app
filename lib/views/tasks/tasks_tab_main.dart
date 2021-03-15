import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';

import 'active_tasks.dart';

class TasksTabsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateTasksTabsMain();
  }
}

class StateTasksTabsMain extends State<TasksTabsMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  ActiveTasks _tabViewOne = ActiveTasks();
  Container _tabViewTwo = Container();

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
          bottom: TabBar(
            tabs: [
              Tab(text: "ACTIVE TASKS"),
              Tab(text: "COMPLETED TASKS"),
            ],
          ),
          title: Text('TASKS'),
          actions: <Widget>[
            FlatButton(
              child: Text("SHARED TO ME"),
            )
          ],
        ),
        body: TabBarView(
          children: [_tabViewOne, _tabViewTwo],
        ),
      ),
    );
  }
}
