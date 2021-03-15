import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/attendance/teacher/staff_attendance_date_detailed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../state_helper.dart';

class _InputDropdown extends StatelessWidget {
  const _InputDropdown(
      {Key key,
      this.child,
      this.labelText,
      this.valueText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.transparent)),
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class StaffAttendanceDate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStaffAttendanceDate();
  }
}

class StateStaffAttendanceDate extends State<StaffAttendanceDate>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  List<dynamic> _attendanceData = <dynamic>[];
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  void _getAttendanceData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var attendanceResponse = await http.post(
        GConstants.getStaffDateAttendanceRoute(await AppData().getSchoolUrl()),
        body: {
          'from_date': DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
          'to_date': DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
          'active_session': sessionToken,
        });

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
                  child: _InputDropdown(
                    labelText: "From",
                    valueText: DateFormat.yMMMd().format(dateFrom),
                    valueStyle: Theme.of(context)
                        .textTheme
                        .subhead
                        .apply(color: Colors.white),
                    onPressed: () async {
                      DateTime firstDate =
                          DateTime.now().subtract(Duration(days: 90));
                      final DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: dateFrom,
                        firstDate: firstDate,
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (picked != null)
                        setState(() {
                          dateFrom = picked;
                        });
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _InputDropdown(
                    labelText: "To",
                    valueText: DateFormat.yMMMd().format(dateTo),
                    valueStyle: Theme.of(context).textTheme.subhead.apply(
                          color: Colors.white,
                        ),
                    onPressed: () async {
                      DateTime initalDate =
                          DateTime.now().subtract(Duration(days: 90));
                      final DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: dateTo,
                        firstDate: initalDate,
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (picked != null)
                        setState(() {
                          dateTo = picked;
                        });
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                FlatButton(
                  child: Text(
                    "GO",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  shape: CircleBorder(side: BorderSide(color: Colors.white54)),
                  onPressed: () {
                    _getAttendanceData();
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            color: Colors.indigo,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: theInfoTable(),
            ),
          ),
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
              (item == null) ? "Name" : item['name'],
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
              return StaffAttendanceDateDetailed(
                  DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
                  DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
                  item['id'],
                  item['name']);
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
              return StaffAttendanceDateDetailed(
                  DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
                  DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
                  item['id'],
                  item['name']);
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
              return StaffAttendanceDateDetailed(
                  DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
                  DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
                  item['id'],
                  item['name']);
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
              return StaffAttendanceDateDetailed(
                  DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
                  DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
                  item['id'],
                  item['name']);
            }));
          },
        ),
      ],
    );
  }
}
