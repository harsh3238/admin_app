import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/dao_att_students.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../state_helper.dart';
import 'sort_dialog.dart';

class ReportsScreen extends StatefulWidget {
  final int classId, sectionId;
  final String selectedClassName, selectedSectionName, selectedDate;

  ReportsScreen(this.classId, this.sectionId, this.selectedClassName,
      this.selectedSectionName, this.selectedDate);

  @override
  State<StatefulWidget> createState() {
    return StateReportsScreen();
  }
}

class StateReportsScreen extends State<ReportsScreen> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  bool _firstRunRoutineRan = false;
  List<dynamic> _students = [];
  Map<String, bool> _wholeClassAttStatus = {
    'all_p': false,
    'all_a': false,
    'all_l': false
  };

  Future<void> _getStudents() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getAttReportsRoute(await AppData().getSchoolUrl()),
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
          await DaoAttStudents().insertStudents(allClassesObject['data']);
          _students = await DaoAttStudents().getStudents(
              widget.classId, widget.sectionId,
              orderBy: _sortBy, order: _sortOrder);
          await _getWholeClassStatus();
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

  Future<void> _getWholeClassStatus() async {
    _wholeClassAttStatus = await DaoAttStudents()
        .getWholeClassAttendanceStatus(widget.classId, widget.sectionId);
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  Future<void> _handleRefresh() async {
    _getStudents();
  }

  Future<bool> _onWillPop() async {
    await DaoAttStudents().deleteAll(widget.classId, widget.sectionId);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getStudents();
      });
    }

    return WillPopScope(
        child: Scaffold(
          key: _scaffoldState,
          appBar: AppBar(
            title: Text(
              "Reports",
              style: TextStyle(fontSize: 14),
            ),
            actions: <Widget>[
              IconButton(
                  tooltip: 'Sort',
                  icon: const Icon(Icons.sort),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          SortDialog(_sortBy, _sortOrder),
                    ).then((onValue) {
                      _sortBy = onValue[0];
                      _sortOrder = onValue[1];
                      _getStudents();
                    });
                  }),
            ],
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
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    trailing: Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 32,
                            height: 32,
                            padding: EdgeInsets.all(1),
                            child: FlatButton(
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.grey)),
                              color: _wholeClassAttStatus['all_p']
                                  ? Colors.green
                                  : Colors.white,
                              textColor: Colors.black,
                              onPressed: () {},
                              child: Text(
                                "P",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: _wholeClassAttStatus['all_p']
                                        ? Colors.white
                                        : Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            padding: EdgeInsets.all(1),
                            child: FlatButton(
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.grey)),
                              color: _wholeClassAttStatus['all_a']
                                  ? Colors.red
                                  : Colors.white,
                              textColor: Colors.black,
                              onPressed: () {},
                              child: Text(
                                "A",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: _wholeClassAttStatus['all_a']
                                        ? Colors.white
                                        : Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            padding: EdgeInsets.all(1),
                            child: FlatButton(
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.grey)),
                              color: _wholeClassAttStatus['all_l']
                                  ? Colors.orange
                                  : Colors.white,
                              textColor: Colors.black,
                              onPressed: () {},
                              child: Text(
                                "L",
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: _wholeClassAttStatus['all_l']
                                        ? Colors.white
                                        : Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                      width: 120,
                    ),
                    onTap: () {},
                  );
                }
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        AssetImage("assets/dash_icons/ic_profile.png"),
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
                    "Roll No. ${_students[index - 1]['roll_no']}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  trailing: Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          padding: EdgeInsets.all(1),
                          child: FlatButton(
                            shape: CircleBorder(
                                side: BorderSide(color: Colors.grey)),
                            color: (_students[index - 1]['att_status'] == "P")
                                ? Colors.green
                                : Colors.white,
                            textColor: Colors.black,
                            onPressed: () {},
                            child: Text(
                              "P",
                              style: TextStyle(
                                fontSize: 14.0,
                                color:
                                    (_students[index - 1]['att_status'] == "P")
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          padding: EdgeInsets.all(1),
                          child: FlatButton(
                            shape: CircleBorder(
                                side: BorderSide(color: Colors.grey)),
                            color: (_students[index - 1]['att_status'] == "AB")
                                ? Colors.red
                                : Colors.white,
                            textColor: Colors.black,
                            onPressed: () {},
                            child: Text(
                              "A",
                              style: TextStyle(
                                fontSize: 14.0,
                                color:
                                    (_students[index - 1]['att_status'] == "AB")
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          padding: EdgeInsets.all(1),
                          child: FlatButton(
                            shape: CircleBorder(
                                side: BorderSide(color: Colors.grey)),
                            color: (_students[index - 1]['att_status'] == "LV")
                                ? Colors.orange
                                : Colors.white,
                            textColor: Colors.black,
                            onPressed: () {},
                            child: Text(
                              "L",
                              style: TextStyle(
                                fontSize: 14.0,
                                color:
                                    (_students[index - 1]['att_status'] == "LV")
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    ),
                    width: 120,
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
        ),
        onWillPop: _onWillPop);
  }
}
