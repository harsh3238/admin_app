import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StaffDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStaffDashboard();
  }
}

class StateStaffDashboard extends State<StaffDashboard> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  List<dynamic> _statsData = <dynamic>[];
  Map<String, dynamic> _totalStats;

  void _getVoiceCalls() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffDepartmentStatsRoute(
            await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _statsData = modulesResponseObject['data'];
          _totalStats = modulesResponseObject['total'];
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
        _getVoiceCalls();
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: theClassInfoTable(),
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
                      text: _totalStats != null ? _totalStats['M'] : "0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Male',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _totalStats != null ? _totalStats['F'] : "0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Female',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _totalStats != null ? _totalStats['T'] : "0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Trans.',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    )),
                RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      text: _totalStats != null ? _totalStats['total_count'] : "0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                            text: '\nTotal Staff',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ],
                    ))
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          )
        ],
      ),
    );
  }

  Widget theClassInfoTable() => Padding(
        padding: EdgeInsets.all(4),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
          },
          children: getTableItems(),
        ),
      );

  List<TableRow> getTableItems() {
    List<TableRow> tablesRows = List();
    tablesRows.add(_buildItemRow(0, "", "", "", "", ""));
    for (int i = 0; i < _statsData.length; i++) {
      tablesRows.add(_buildItemRow(
          i + 1,
          _statsData[i]['department'],
          _statsData[i]['M'],
          _statsData[i]['F'],
          _statsData[i]['T'],
          _statsData[i]['total_count']));
    }
    return tablesRows;
  }

  TableRow _buildItemRow(int index, String departmentName, String maleCount,
      String femaleCount, String transCount, String totalCount) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            (index == 0) ? "Depart." : departmentName,
            style: (index == 0)
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                  )
                : TextStyle(fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            (index == 0) ? "Male" : maleCount != null ? maleCount : "0",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            (index == 0) ? "Female" : femaleCount != null ? femaleCount : "0",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            (index == 0) ? "Trans." : transCount != null ? transCount : "0",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            (index == 0) ? "Total" : totalCount != null ? totalCount : "0",
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
