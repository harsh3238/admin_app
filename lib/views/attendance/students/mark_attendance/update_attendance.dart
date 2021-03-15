import 'dart:convert';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/dao_att_update_students.dart';
import 'package:click_campus_admin/views/attendance/students/mark_attendance/sort_dialog.dart';
import 'package:click_campus_admin/views/attendance/students/mark_attendance/speech_to_text_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../state_helper.dart';

class UpdateAttendance extends StatefulWidget {
  final int classId, sectionId;
  final String selectedClassName, selectedSectionName, selectedDate;

  UpdateAttendance(this.classId, this.sectionId, this.selectedClassName,
      this.selectedSectionName, this.selectedDate);

  @override
  State<StatefulWidget> createState() {
    return StateUpdateAttendance();
  }
}

class StateUpdateAttendance extends State<UpdateAttendance> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool shouldHighlightDefaultedStatus = false;

  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  bool _firstRunRoutineRan = false;
  bool _showSearchBar = false;
  List<dynamic> _students = [];
  Map<String, bool> _wholeClassAttStatus = {
    'all_p': false,
    'all_a': false,
    'all_l': false
  };
  final TextEditingController _filter = new TextEditingController();

  Future<void> _getStudents(bool ignoreCache) async {
    showProgressDialog();
    if (!ignoreCache) {
      //print("GETTING STUDENTS FROM CACHE");
      int stuCount = await DaoUpdateAttendance()
          .getStudentCount(widget.classId, widget.sectionId);

      if (stuCount > 0) {
        _students = await DaoUpdateAttendance().getStudents(
            widget.classId, widget.sectionId,
            orderBy: _sortBy, order: _sortOrder);
        await _getWholeClassStatus();
        hideProgressDialog();
        setState(() {});
        return null;
      }
    }
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getAttUpdateRoute(await AppData().getSchoolUrl()),
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
          if (allClassesObject['att_not_marked'] == 1) {
            hideProgressDialog();
            showSnackBar("Attendance has not been marked yet");
          } else {
            await DaoUpdateAttendance()
                .insertStudents(allClassesObject['data']);
            _students = await DaoUpdateAttendance().getStudents(
                widget.classId, widget.sectionId,
                orderBy: _sortBy, order: _sortOrder);
            await _getWholeClassStatus();
            hideProgressDialog();
            setState(() {});
          }
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

  Future<void> _submitMarkedAttendance() async {
    showProgressDialog();
    bool isAttMarked = await DaoUpdateAttendance()
        .isAttendanceMarked(widget.classId, widget.sectionId);
    if (!isAttMarked) {
      hideProgressDialog();
      setState(() {
        shouldHighlightDefaultedStatus = true;
      });
      showSnackBar("Attendance is not marked completely");
      return null;
    }

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      hideProgressDialog();
      showSnackBar("You are not connected to the internet.");
      return null;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
    } on SocketException catch (_) {
      hideProgressDialog();
      showSnackBar("You are not connected to the internet.");
      return null;
    }

    List<Map<String, dynamic>> data = await DaoUpdateAttendance()
        .getAttToSubmit(widget.classId, widget.sectionId);
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getUpdateStuAttRoute(await AppData().getSchoolUrl()),
        body: {
          'data': json.encode(data),
          'active_session': sessionToken,
        });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          await DaoUpdateAttendance()
              .deleteAll(widget.classId, widget.sectionId);
          hideProgressDialog();
          showSnackBar("Success", color: Colors.green);
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
    _wholeClassAttStatus = await DaoUpdateAttendance()
        .getWholeClassAttendanceStatus(widget.classId, widget.sectionId);
    if (_wholeClassAttStatus['all_p'] ||
        _wholeClassAttStatus['all_a'] ||
        _wholeClassAttStatus['all_l']) {
      shouldHighlightDefaultedStatus = false;
    }
  }

  Future<void> _setWholeClassStatus(String status) async {
    await DaoUpdateAttendance().setAttendanceStatusWholeClass(
        widget.classId, widget.sectionId, status);
    await _getStudents(false);
    setState(() {});
  }

  Future<void> _setStudentStatus(String srNo, String status) async {
    await DaoUpdateAttendance().setAttendanceStatusStudent(srNo, status);
    await _getStudents(false);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
    _filter.addListener(() async {
      _students = await DaoUpdateAttendance()
          .searchStudent(widget.classId, widget.sectionId, _filter.text);
      setState(() {});
    });
  }

  Future<void> _handleRefresh() async {
    _getStudents(true);
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Do you want to exit?'),
            content: new Text('Are you sure you want to exist?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {
                  DaoUpdateAttendance().deleteAll(widget.classId, widget.sectionId);
                  Navigator.of(context).pop(true);
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  AppBar _getAppBar() {
    if (_showSearchBar) {
      return AppBar(
        centerTitle: true,
        title: Theme(
            data: ThemeData(
                accentColor: Colors.white,
                primaryColor: Colors.white,
                focusColor: Colors.white),
            child: TextField(
              controller: _filter,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
              ),
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
            )),
        leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _filter.text = "";
                _showSearchBar = false;
              });
            }),
        actions: <Widget>[
          IconButton(
              tooltip: 'Microphone',
              icon: const Icon(Icons.mic),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => SpeechToTextDialog(),
                ).then((onValue) {
                  if (onValue[0] == false) {
                    showSnackBar("Microphone permission not granted");
                  } else if (onValue[1].toString().length > 0) {
                    setState(() {
                      _filter.text = onValue[1].toString();
                    });
                  }
                });
              })
        ],
      );
    } else {
      return AppBar(
        title: Text(
          _students.length > 0 ? _students[0]['att_date'] : "Attendance",
          style: TextStyle(fontSize: 14),
        ),
        actions: <Widget>[
          GestureDetector(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text("SORT", style: TextStyle(fontSize: 16)),
                ),
                ImageIcon(
                  AssetImage("assets/sort.png"),
                  size: 18,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    SortDialog(_sortBy, _sortOrder),
              ).then((onValue) {
                _sortBy = onValue[0];
                _sortOrder = onValue[1];
                _getStudents(false);
              });
            },
          ),
          IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearchBar = true;
                });
              }),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getStudents(false);
      });
    }

    return WillPopScope(
        child: Scaffold(
          key: _scaffoldState,
          appBar: _getAppBar(),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            child: Column(
              children: <Widget>[
                ListTile(
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
                            onPressed: () {
                              String status =
                                  _wholeClassAttStatus['all_p'] ? "" : "P";
                              _setWholeClassStatus(status);
                            },
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
                            onPressed: () {
                              String status =
                                  _wholeClassAttStatus['all_a'] ? "" : "AB";
                              _setWholeClassStatus(status);
                            },
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
                            onPressed: () {
                              String status =
                                  _wholeClassAttStatus['all_l'] ? "" : "LV";
                              _setWholeClassStatus(status);
                            },
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
                ),
                Expanded(
                    child: ListView.separated(
                  itemBuilder: (context, index) {
                    return Container(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/dash_icons/ic_profile.png"),
                          foregroundColor: Colors.black,
                        ),
                        title: Text(
                          _students[index]['student_name'],
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "Roll No. ${_students[index]['roll_no']}",
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 12),
                        ),
                        trailing: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 32,
                                    height: 32,
                                    padding: EdgeInsets.all(1),
                                    child: FlatButton(
                                      shape: CircleBorder(
                                          side: BorderSide(color: Colors.grey)),
                                      color: (_students[index]['att_status'] ==
                                              "P")
                                          ? Colors.green
                                          : Colors.white,
                                      textColor: Colors.black,
                                      onPressed: () {
                                        String status = (_students[index]
                                                    ['att_status'] ==
                                                "P")
                                            ? ""
                                            : "P";
                                        _setStudentStatus(
                                            _students[index]['s_r_no'], status);
                                      },
                                      child: Text(
                                        "P",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: (_students[index]
                                                        ['att_status'] ==
                                                    "P")
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
                                      color: (_students[index]['att_status'] ==
                                              "AB")
                                          ? Colors.red
                                          : Colors.white,
                                      textColor: Colors.black,
                                      onPressed: () {
                                        String status = (_students[index]
                                                    ['att_status'] ==
                                                "AB")
                                            ? ""
                                            : "AB";
                                        _setStudentStatus(
                                            _students[index]['s_r_no'], status);
                                      },
                                      child: Text(
                                        "A",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: (_students[index]
                                                        ['att_status'] ==
                                                    "AB")
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
                                      color: (_students[index]['att_status'] ==
                                              "LV")
                                          ? Colors.orange
                                          : Colors.white,
                                      textColor: Colors.black,
                                      onPressed: () {
                                        String status = (_students[index]
                                                    ['att_status'] ==
                                                "LV")
                                            ? ""
                                            : "LV";
                                        _setStudentStatus(
                                            _students[index]['s_r_no'], status);
                                      },
                                      child: Text(
                                        "L",
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: (_students[index]
                                                        ['att_status'] ==
                                                    "LV")
                                                ? Colors.white
                                                : Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                              ),
                              (_students[index]['att_status'] == "AB")
                                  ? GestureDetector(
                                      child: Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text(
                                            (_students[index]
                                                        ['absent_reason'] !=
                                                    null && _students[index]
                                            ['absent_reason'].toString().length > 0)
                                                ? _students[index]
                                                    ['absent_reason']
                                                : "Select Reason",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: (_students[index]
                                                            ['absent_reason'] !=
                                                        null)
                                                    ? Colors.indigo
                                                    : Colors.red),
                                          )),
                                      onTap: () {
                                        var dialog = SimpleDialog(
                                          title: const Text('Absent Reason'),
                                          children: [
                                            SimpleDialogOption(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                child: Text(
                                                  "Sick Leave",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, "Sick Leave");
                                              },
                                            ),
                                            SimpleDialogOption(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                child: Text(
                                                  "Parental Leave",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, "Parental Leave");
                                              },
                                            ),
                                            SimpleDialogOption(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                child: Text(
                                                  "Casual Leave",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, "Casual Leave");
                                              },
                                            ),
                                          ],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              dialog,
                                        ).then((value) {
                                          //print(value);
                                          if (value != null) {
                                            DaoUpdateAttendance().setAbsentReason(_students[index]['stucare_id'], value);
                                            _getStudents(false);
                                          }
                                        });
                                      },
                                    )
                                  : SizedBox(height: 0),
                            ],
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),
                          width: 120,
                        ),
                        onTap: () {},
                      ),
                      color: (shouldHighlightDefaultedStatus &&
                              _students[index]['att_status']
                                      .toString()
                                      .trim()
                                      .length <=
                                  0)
                          ? Colors.redAccent.shade100
                          : Colors.white,
                    );
                  },
                  itemCount: _students.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 0,
                    );
                  },
                )),
                Container(
                  child: FlatButton(
                    onPressed: () {
                      _submitMarkedAttendance();
                    },
                    child:
                        Text("SUBMIT", style: TextStyle(color: Colors.white)),
                    disabledColor: Colors.indigo,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  width: double.infinity,
                  color: Colors.indigo,
                )
              ],
            ),
          ),
        ),
        onWillPop: _onWillPop);
  }
}
