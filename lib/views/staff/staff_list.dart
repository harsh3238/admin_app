import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/staff/staff_detail/staff_detail_main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class StaffList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStaffList();
  }
}

class StateStaffList extends State<StaffList> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  List<dynamic> _staffData = <dynamic>[];
  List<dynamic> _departmentData = <dynamic>[];
  Map<String, dynamic> _selectedDepartment;

  void _getDepartments() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffDepartmentRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _departmentData = modulesResponseObject['data'];
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["message"]);
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

  void _getStaff() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffByDepartmentRoute(await AppData().getSchoolUrl()),
        body: {'department_id': _selectedDepartment['id'].toString(), 'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _staffData.clear();
          _staffData = modulesResponseObject['data'];
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["message"]);
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
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getDepartments();
      });
    }
    return Scaffold(
      key: _scaffoldState,
      body: Container(
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
                            child: DropdownButton<Map<String, dynamic>>(
                          items: _departmentData
                              .map(
                                  (b) => DropdownMenuItem<Map<String, dynamic>>(
                                        child: Text(
                                          b['name'],
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        value: b,
                                      ))
                              .toList(),
                          onChanged: (b) {
                            setState(() {
                              _selectedDepartment = b;
                            });
                          },
                          hint: Text(
                            'Select Department',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: _selectedDepartment,
                        ))),
                  ),
                  const SizedBox(width: 12.0),
                  FlatButton(
                    child: Text(
                      "GO",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    shape:
                        CircleBorder(side: BorderSide(color: Colors.white54)),
                    onPressed: () {
                      if (_selectedDepartment != null) {
                        _getStaff();
                      } else {
                        showSnackBar("Please select department",
                            color: Colors.orange);
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
            ),
            Container(
              color: Colors.indigo,
              padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
              child: Align(
                child: RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: (_staffData.length - 1).toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Staff',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                alignment: Alignment.centerRight,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }

  Widget theInfoTable() => Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
        },
        children: getTableItems(),
      );

  List<TableRow> getTableItems() {
    List<TableRow> tablesRows = List();
    if (_staffData.length > 0 && _staffData[0] != null) {
      _staffData.insert(0, null);
    }
    for (int i = 0; i < _staffData.length; i++) {
      tablesRows.add(_buildItemRow(i));
    }
    return tablesRows;
  }

  TableRow _buildItemRow(int index) {
    return TableRow(
      children: <Widget>[
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (index == 0) ? Colors.white : Colors.transparent,
            child: Text(
              (index == 0) ? "ID" : _staffData[index]['employee_id'],
              style: (index == 0)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                      fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            navigateToStaffDetail(index);
          },
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (index == 0) ? Colors.white : Colors.transparent,
            child: Text(
              (index == 0) ? "Name" : _staffData[index]['name'],
              style: (index == 0)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                      fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            navigateToStaffDetail(index);
          },
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: (index == 0) ? Colors.white : Colors.transparent,
            child: Text(
              (index == 0)
                  ? "Mobile No."
                  : _staffData[index]['primary_contact'],
              style: (index == 0)
                  ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                  : TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                      fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            navigateToStaffDetail(index);
          },
        ),
      ],
    );
  }

  void navigateToStaffDetail(int index) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return StaffDetailMain(_staffData[index]['login_id']);
    }));
  }
}
