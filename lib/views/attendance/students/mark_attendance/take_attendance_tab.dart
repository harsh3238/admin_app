import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../state_helper.dart';
import 'mark_attendance.dart';

class TakeAttendance extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TakeAttendanceState();
  }
}

class TakeAttendanceState extends State<TakeAttendance> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  bool _firstRunRoutineRan = false;

  List<Map<String, dynamic>> _allClasses = List();
  List<Map<String, dynamic>> _allSections = List();

  int _selectedClass, _selectedSection;
  String _selectedClassName, _selectedSectionName;


  void _getAllClassesAndSections() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();


    int userLoginId = await AppData().getUserLoginId();
    var allClassesResponse = await http.post(
        GConstants.getAllClassesAndSectionRoute(await AppData().getSchoolUrl()),
        body: {'login_row_id': userLoginId.toString(), 'active_session': sessionToken,});

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> classes = allClassesObject['data']['class'];
          List<dynamic> sections = allClassesObject['data']['sections'];
          await DbClassSection().insertClassesSections(classes, sections);
          _allClasses = await DbClassSection().getAllClasses();
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

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getAllClassesAndSections();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      body: Padding(
        child: Column(
          children: <Widget>[
            Container(
              child: Image.asset(
                "assets/dash_icons/ic_attendance_p.png",
                fit: BoxFit.cover,
                color: Colors.red,
              ),
              width: 70,
              margin: EdgeInsets.all(10),
            ),
            Padding(
              child: Text(
                'Take Attendance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedClass,
              items: _allClasses
                  .map((b) => DropdownMenuItem<int>(
                        child: Text(
                          "Class ${b['class_name']}",
                          style: TextStyle(color: Colors.black, inherit: false),
                        ),
                        value: b['id'],
                      ))
                  .toList(),
              hint: Text(
                'Select Class',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onChanged: (b) {
                _allSections = [];
                setState(() {
                  var theClass = _allClasses
                      .where((Map<String, dynamic> item) => item['id'] == b)
                      .toList()[0];
                  _selectedClass = theClass['id'];
                  _selectedClassName = theClass['class_name'];
                });
                getSectionsForClass(_selectedClass);
              },
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12.0),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedSection,
              items: _allSections
                  .map((b) => DropdownMenuItem<int>(
                        child: Text(
                          "Section ${b['sec_name']}",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        value: b['id'],
                      ))
                  .toList(),
              onChanged: (b) {
                setState(() {
                  var theSection = _allSections
                      .where((Map<String, dynamic> item) => item['id'] == b)
                      .toList()[0];
                  _selectedSection = theSection['id'];
                  _selectedSectionName = theSection['sec_name'];
                });
              },
              hint: Text(
                'Select Section',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              height: 20,
            ),
            FlatButton(
              child: Text("SUBMIT"),
              color: Colors.indigo,
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return MarkAttendance(_selectedClass, _selectedSection,
                      _selectedClassName, _selectedSectionName);
                })).then((onValue) {
                  if (onValue) {
                    showSnackBar("Attendance Submitted", color: Colors.green);
                  }
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22))),
              padding: EdgeInsets.symmetric(horizontal: 50),
            )
          ],
        ),
        padding: EdgeInsets.all(40),
      ),
    );
  }

  void getSectionsForClass(int classId) async {
    _selectedSection = null;
    _allSections = await DbClassSection().getSectionsByClassId(classId);
    setState(() {});
  }
}
