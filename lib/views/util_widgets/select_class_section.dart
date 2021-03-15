import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectClassSection extends StatefulWidget {
  @override
  _SelectClassSectionState createState() => new _SelectClassSectionState();
}

class _SelectClassSectionState extends State<SelectClassSection>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  Set<int> checkedSections = Set();
  Set<int> checkedClasses = Set();

  bool _firstRunRoutineRan = false;

  List<ClassesWithSections> _classesData = [];

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
          _classesData = await DbClassSection().getClassesWithSection();
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
        title: Text("Select Class/Section"),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, checkedSections);
              })
        ],
      ),
      body: new ListView.separated(
        itemCount: _classesData.length,
        itemBuilder: (context, i) {
          return new ExpansionTile(
            title: new Text(
              _classesData[i].className,
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              new Column(
                children: _buildExpandableContent(_classesData[i]),
              ),
            ],
            leading: Checkbox(
              value: checkedClasses.contains(_classesData[i].classCode),
              onChanged: (nV) {
                setState(() {
                  if (checkedClasses.contains(_classesData[i].classCode)) {
                    checkedClasses.remove(_classesData[i].classCode);
                    _uncheckAllSectionForClass(_classesData[i]);
                  } else {
                    checkedClasses.clear();
                    checkedSections.clear();
                    checkedClasses.add(_classesData[i].classCode);
                    _checkAllSectionForClass(_classesData[i]);
                  }
                });
              },
            ),
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

  _checkAllSectionForClass(ClassesWithSections _classesData) {
    for (SectionItem content in _classesData.sections) {
      checkedSections.add(content.sectionCode);
    }
  }

  _uncheckAllSectionForClass(ClassesWithSections _classesData) {
    for (SectionItem content in _classesData.sections) {
      checkedSections.remove(content.sectionCode);
    }
  }

  _checkAllClassesIfNeeded(ClassesWithSections _classesData) {
    bool shouldSelectAllClasses = true;

    for (SectionItem content in _classesData.sections) {
      if (!checkedSections.contains(content.sectionCode)) {
        shouldSelectAllClasses = false;
        break;
      }
    }
    if (shouldSelectAllClasses) {
      checkedClasses.add(_classesData.classCode);
    }
  }

  _buildExpandableContent(ClassesWithSections _classesData) {
    List<Widget> columnContent = [];

    for (SectionItem content in _classesData.sections)
      columnContent.add(
        Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: ListTile(
            title: new Text(
              content.sectionName,
              style: new TextStyle(fontSize: 14.0),
            ),
            leading: Checkbox(
              value: checkedSections.contains(content.sectionCode),
              onChanged: (nV) {
                setState(() {
                  if (checkedSections.contains(content.sectionCode)) {
                    checkedSections.remove(content.sectionCode);

                    if (checkedClasses.contains(_classesData.classCode)) {
                      checkedClasses.remove(_classesData.classCode);
                    }
                  } else {
                    if (checkedSections.length > 0) {
                      bool shouldClearSections = false;
                      for (int i in checkedSections) {
                        if (!_classesData.doesContainSection(i)) {
                          shouldClearSections = true;
                        }
                      }
                      if(shouldClearSections ){
                        checkedSections.clear();
                        checkedClasses.clear();
                      }
                      checkedSections.add(content.sectionCode);
                    } else {
                      checkedSections.add(content.sectionCode);
                    }
                    _checkAllClassesIfNeeded(_classesData);
                  }
                });
              },
            ),
          ),
        ),
      );

    return columnContent;
  }
}

class ClassesWithSections {
  int classCode;
  String className;
  List<SectionItem> sections = [];
  bool isSelected = false;

  bool doesContainSection(int sectionId) {
    for (SectionItem item in sections) {
      if (item.sectionCode == sectionId) {
        return true;
      }
    }
    return false;
  }

  ClassesWithSections(this.classCode, this.className, this.sections);
}

class SectionItem {
  int sectionCode;
  String sectionName;
  bool isSelected = false;

  SectionItem(this.sectionCode, this.sectionName);
}
