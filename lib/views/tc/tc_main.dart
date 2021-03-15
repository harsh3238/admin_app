import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class TcMainList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateTcMainList();
  }
}

class StateTcMainList extends State<TcMainList> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _tcsData = [];

  List<Map<String, String>> contentData = [
    {"s_r_no": "Admission No"},
    {"student_name": "Student Name"},
    {"class_section": "Class/Section"},
    {"date_of_leave": "Deactive Date"}
  ];

  void _getTcs() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http
        .post(GConstants.getTcsRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _tcsData = modulesResponseObject['data'];
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
        _getTcs();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("T.C."),
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
                            "T.C. No. : ${_tcsData[index]['tc_no']}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    color: Colors.indigo,
                  ),
                  contentTable(index)
                ],
              ),
            ),
          );
        },
        itemCount: _tcsData.length,
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
              return _buildItemRow(d[theKey], _tcsData[index][theKey]);
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
          child: Text(
            right,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
