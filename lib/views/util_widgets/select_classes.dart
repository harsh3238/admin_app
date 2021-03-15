import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectClasses extends StatefulWidget {
  @override
  _SelectClassesState createState() => new _SelectClassesState();
}

class _SelectClassesState extends State<SelectClasses>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  Set<int> checkedClasses = Set();

  bool _firstRunRoutineRan = false;

  List<Map<String, dynamic>> _allClasses = List();

  void _getAllClassesAndSections() async {
    _firstRunRoutineRan = true;
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getAllClassesAndSectionRoute(
            await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> classes = allClassesObject['data']['class'];
          List<dynamic> sections = allClassesObject['data']['sections'];
          await DbClassSection().insertClassesSections(classes, sections);
          _allClasses = await DbClassSection().getAllClasses();
          setState(() {});
          hideProgressDialog();
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
    super.init(context, _scaffoldState);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _getAllClassesAndSections();
      });
    }

    return new Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Select Classes"),
        /*actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, checkedClasses);
              })
        ]*/
      ),
      body: new ListView.separated(
        itemCount: _allClasses.length,
        itemBuilder: (context, i) {
          return new ListTile(
            title: new Text(
              "Class ${_allClasses[i]['class_name']}",
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            /*leading: Checkbox(
                value: checkedClasses.contains(_allClasses[i]['id']),
                onChanged: (nV) {
                  setState(() {
                    if (checkedClasses.contains(_allClasses[i]['id'])) {
                      checkedClasses.remove(_allClasses[i]['id']);
                    } else {
                      checkedClasses.add(_allClasses[i]['id']);
                    }
                  });
                }),*/
            onTap: (){
              Navigator.pop(context, _allClasses[i]['id']);
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 0,
          );
        },
      ),
    );
  }


}

class ClassesWithSections {
  int classCode;
  String className;
  List<SectionItem> sections = [];
  bool isSelected = false;

  ClassesWithSections(this.classCode, this.className, this.sections);
}

class SectionItem {
  int sectionCode;
  String sectionName;
  bool isSelected = false;

  SectionItem(this.sectionCode, this.sectionName);
}
