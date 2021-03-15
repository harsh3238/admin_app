import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/the_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../state_helper.dart';

class EnquiriesTab extends StatefulWidget {
  StateEnquiriesTab _stateEnquiriesTab;

  @override
  State<StatefulWidget> createState() {
    _stateEnquiriesTab = StateEnquiriesTab();
    return _stateEnquiriesTab;
  }

  void sessionChanged(TheSession session) {
    _stateEnquiriesTab._getData(session.sessionId.toString(),);
  }
}

class StateEnquiriesTab extends State<EnquiriesTab> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _enquiriesData = [];

  void _getData(sessionId) async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getEnquiriesRoute(await AppData().getSchoolUrl()),
        body: {
          'session_id': sessionId,
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _enquiriesData = modulesResponseObject['data'];
          _enquiriesData.insert(0, null);
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
      Future.delayed(Duration(milliseconds: 500), () async {
        _getData(activeSession.sessionId.toString());
      });
    }

    return Scaffold(
      key: _scaffoldState,
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: theInfoTable(),
              ),
            ),
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
        children: <TableRow>[]..addAll(_enquiriesData.map<TableRow>((d) {
            return _buildItemRow(d);
          })),
      );

  TableRow _buildItemRow(Map<String, dynamic> item) {
    return TableRow(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "S.No." : item['id'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Student" : item['student_name'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Father" : item['father_name'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Mother" : item['mother_name'],
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: (item == null) ? Colors.white : Colors.transparent,
          child: Text(
            (item == null) ? "Date" : DateFormat().addPattern("dd-MMM").format(DateTime.parse(item['enquiry_date'])),
            style: (item == null)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)
                : TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade700,
                    fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
