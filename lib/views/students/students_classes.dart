import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentClasses extends StatefulWidget {
  StateStudentClasses _stateStudentClasses;

  @override
  State<StatefulWidget> createState() {
    _stateStudentClasses = StateStudentClasses();
    return _stateStudentClasses;
  }

  void sessionChanged() {
    _stateStudentClasses._getStudentsStrength();
  }
}

class StateStudentClasses extends State<StudentClasses> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _firstRunRoutineRan = false;

  List<dynamic> _classStrengthList = List();
  Map<String, dynamic> _collectiveData = Map();

  void _getStudentsStrength() async {
    showProgressDialog();

    String sessionToken = await AppData().getSessionToken();

    if (activeSession == null || activeSession.sessionId == null) {
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    var studentsResponse = await http.post(
        GConstants.getStudentsStrengthBySectionRoute(
            await AppData().getSchoolUrl()),
        body: {'session_id': activeSession.sessionId.toString(), 'active_session': sessionToken,});

    //print(studentsResponse.body);

    if (studentsResponse.statusCode == 200) {
      Map studentsObject = json.decode(studentsResponse.body);
      if (studentsObject.containsKey("status")) {
        if (studentsObject["status"] == "success") {
          _classStrengthList = studentsObject['data'];
          _collectiveData = studentsObject['collective_data'];
          setState(() {});
          hideProgressDialog();
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(studentsObject["message"]);
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

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;

      Future.delayed(Duration(milliseconds: 100), () async {
        _getStudentsStrength();
      });
    }

    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Text(
                  "Class",
                  style: TextStyle(color: Colors.indigo),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Section",
                  style: TextStyle(color: Colors.indigo),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Boys",
                  style: TextStyle(color: Colors.indigo),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Girls",
                  style: TextStyle(color: Colors.indigo),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Total",
                  style: TextStyle(color: Colors.indigo),
                  textAlign: TextAlign.center,
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
            color: Colors.white,
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _classStrengthList[index]['class_name'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: Text(
                      _classStrengthList[index]['sec_name'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    )),
                    Expanded(
                        child: Text(
                      _classStrengthList[index]['boys'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    )),
                    Expanded(
                        child: Text(
                      _classStrengthList[index]['girls'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    )),
                    Expanded(
                        child: Text(
                      _classStrengthList[index]['student_count'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ))
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                );
              },
              itemCount: _classStrengthList.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
          Container(
            color: Colors.indigo,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: <Widget>[
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _collectiveData['boys'],
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Boys',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _collectiveData['girls'],
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Girls',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _collectiveData['total'],
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nCollective Total',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    ))
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }
}
