import 'package:click_campus_admin/views/announcement/announcement_timeline.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';

import 'announcement_message_page.dart';

class AnnouncementTabsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAnnouncementTabsMain();
  }
}

class StateAnnouncementTabsMain extends State<AnnouncementTabsMain>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  Announcement _tabViewOne = Announcement();
  AnnouncementMessages _tabViewTwo = AnnouncementMessages();

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
              Tab(text: "Timeline"),
              Tab(text: "Messages"),
            ],
          ),
          title: Text('Announcement'),
        ),
        body: TabBarView(
          children: [_tabViewOne, _tabViewTwo],
        ),
      ),
    );
  }
}
