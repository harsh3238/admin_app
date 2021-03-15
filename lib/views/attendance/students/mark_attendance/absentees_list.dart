import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../state_helper.dart';

class AbsenteesScreen extends StatefulWidget {
  final int classId, sectionId;
  final String selectedClassName, selectedSectionName, selectedDate;

  AbsenteesScreen(this.classId, this.sectionId, this.selectedClassName,
      this.selectedSectionName, this.selectedDate);

  @override
  State<StatefulWidget> createState() {
    return StateAbsenteesScreen();
  }
}

class StateAbsenteesScreen extends State<AbsenteesScreen> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool _firstRunRoutineRan = false;
  List<dynamic> _students = [];

  Future<void> _getAbsentees() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getAbsenteesRoute(await AppData().getSchoolUrl()),
        body: {
          'class_id': widget.classId.toString(),
          'section_id': widget.sectionId.toString(),
          'date': widget.selectedDate,
          'active_session': sessionToken,
        });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _students = allClassesObject['data'];
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(allClassesObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
    }
    hideProgressDialog();
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  Future<void> _handleRefresh() async {
    _getAbsentees();
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getAbsentees();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Absentees"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: ListView.separated(
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                title: Text(
                  'Class Section',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "${widget.selectedClassName} - ${widget.selectedSectionName}",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                onTap: () {},
              );
            }
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/dash_icons/ic_profile.png"),
                foregroundColor: Colors.black,
              ),
              title: Text(
                _students[index - 1]['student_name'],
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "Roll No : ${_students[index - 1]['roll_no'] ?? 'Not Found'}",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
              onTap: () {},
            );
          },
          itemCount: _students.length + 1,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(
              height: 0,
            );
          },
        ),
      ),
    );
  }
}
