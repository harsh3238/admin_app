import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/attendance/students/stu_attendance_month_detailed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../state_helper.dart';


class StudentAttendanceMonth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStudentAttendanceMonth();
  }
}

class StateStudentAttendanceMonth extends State<StudentAttendanceMonth>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  List<dynamic> _attendanceData = <dynamic>[];
  List<Map<String, String>> allMonthsArr = [
    {'month': 'January', 'id': "1"},
    {'month': 'February', 'id': "2"},
    {'month': 'March', 'id': "3"},
    {'month': 'April', 'id': "4"},
    {'month': 'May', 'id': "5"},
    {'month': 'June', 'id': "6"},
    {'month': 'July', 'id': "7"},
    {'month': 'August', 'id': "8"},
    {'month': 'September', 'id': "9"},
    {'month': 'October', 'id': "10"},
    {'month': 'November', 'id': "11"},
    {'month': 'December', 'id': "12"}
  ];

  Map<String, String> selectedMonth;

  void _getAttendanceData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var attendanceResponse = await http.post(
        GConstants.getStudentMonthRoute(await AppData().getSchoolUrl()),
        body: {'month': selectedMonth['id'], 'active_session': sessionToken,});

    //print(attendanceResponse.body);

    if (attendanceResponse.statusCode == 200) {
      Map attendanceResponseObject = json.decode(attendanceResponse.body);
      if (attendanceResponseObject.containsKey("status")) {
        if (attendanceResponseObject["status"] == "success") {
          _attendanceData = attendanceResponseObject['data'];
          _attendanceData.insert(0, null);
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(attendanceResponseObject["message"]);
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
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Theme(
                      data: Theme.of(context)
                          .copyWith(brightness: Brightness.dark),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, String>>(
                            items: allMonthsArr
                                .map((b) => DropdownMenuItem<Map<String, String>>(
                              child: Text(
                                b['month'],
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              value: b,
                            ))
                                .toList(),
                            onChanged: (b) {
                              setState(() {
                                selectedMonth = b;
                              });
                            },
                            hint: Text(
                              'Select Month',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            value: selectedMonth,
                          ))),
                ),
                const SizedBox(width: 12.0),
                FlatButton(
                  child: Text(
                    "GO",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  shape: CircleBorder(side: BorderSide(color: Colors.white54)),
                  onPressed: () {
                    if (selectedMonth != null) {
                      _getAttendanceData();
                    }
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            color: Colors.indigo,
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: theInfoTable(),
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  Widget theInfoTable() => Table(
    columnWidths: const <int, TableColumnWidth>{
      0: FlexColumnWidth(1),
    },
    children: <TableRow>[]..addAll(_attendanceData.map<TableRow>((b) {
      return _buildItemRow(b);
    })),
  );

  TableRow _buildItemRow(Map<String, dynamic> item) {
    return TableRow(
      children: <Widget>[
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (item == null) ? Colors.white : Colors.transparent,
            child: Text(
              (item == null) ? "Class" : item['class_name'],
              style: (item == null)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade700,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return StuAttendanceMonthDetailed(selectedMonth['id'], item['class_id'],
                      item['section_id'], item['class_name'], item['sec_name']);
                }));
          },
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (item == null) ? Colors.white : Colors.transparent,
            child: Text(
              (item == null) ? "Section" : item['sec_name'],
              style: (item == null)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade700,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return StuAttendanceMonthDetailed(selectedMonth['id'], item['class_id'],
                      item['section_id'], item['class_name'], item['sec_name']);
                }));
          },
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (item == null) ? Colors.white : Colors.transparent,
            child: Text(
              (item == null) ? "Present" : item['present'],
              style: (item == null)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade700,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return StuAttendanceMonthDetailed(selectedMonth['id'], item['class_id'],
                      item['section_id'], item['class_name'], item['sec_name']);
                }));
          },
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (item == null) ? Colors.white : Colors.transparent,
            child: Text(
              (item == null) ? "Absent" : item['absent'],
              style: (item == null)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade700,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return StuAttendanceMonthDetailed(selectedMonth['id'], item['class_id'],
                      item['section_id'], item['class_name'], item['sec_name']);
                }));
          },
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (item == null) ? Colors.white : Colors.transparent,
            child: Text(
              (item == null) ? "Late" : item['late'],
              style: (item == null)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade700,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                 // return StudentAttendanceCurrentDetailed(item['class_id'], item['section_id']);
                }));
          },
        ),

      ],
    );
  }
}
