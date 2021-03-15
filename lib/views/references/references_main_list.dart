import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';
import 'references_main.dart';

class ReferencesMainList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateReferencesMainList();
  }
}

class StateReferencesMainList extends State<ReferencesMainList>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _refsData = [];

  List<Map<String, String>> contentData = [
    {"student_fname": "Student Name"},
    {"class_name": "Applied Class"},
    {"guardian_parent_name": "Guardian/Parent"},
    {"guardian_parent_mobile": "Mobile"}
  ];

  void _getLeave() async {
    showProgressDialog();
    int userLoginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();


    var modulesResponse = await http.post(GConstants.getRefRoute(await AppData().getSchoolUrl()),
        body: {"login_id": userLoginId.toString(), 'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _refsData = modulesResponseObject['data'];
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
        _getLeave();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("References"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(context,
              MaterialPageRoute(builder: (b) => AddReference()))
              .then((b) {
            if (b) {
              showSnackBar("Reference added successfully", color: Colors.green);
              _getLeave();
            }
          });
        },
        child: Text(
          "Add",
          style: TextStyle(fontSize: 12),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(8),
        separatorBuilder: (context, position) {
          return Container(
            height: 8,
          );
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "Reference No. ${_refsData[index]["id"]}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    color: Colors.grey.shade900,
                  ),
                  contentTable(index)
                ],
              ),
            ),
          );
        },
        itemCount: _refsData.length,
      ),
    );
  }

  Widget contentTable(index) => Padding(
        padding: EdgeInsets.all(0),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
          },
          children: <TableRow>[]
            ..addAll(contentData.map<TableRow>((Map<String, String> d) {
              var theKey = d.keys.toList()[0];
              return _buildItemRow(d[theKey], _refsData[index][theKey]);
            })),
        ),
      );

  TableRow _buildItemRow(String left, String right) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(right,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
