import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/announcement/selected_audience.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectAudience extends StatefulWidget {
  @override
  _SelectAudienceState createState() => new _SelectAudienceState();
}

class _SelectAudienceState extends State<SelectAudience> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  Set<int> checkedDepartment = Set();
  Set<int> checkedStaff = Set();

  Set<int> checkedSections = Set();
  Set<int> checkedClasses = Set();
  Set<int> checkedStudents = Set();

  bool _firstRunRoutineRan = false;

  List<AudienceData> _audienceData = [];

  void _getAllClassesAndSections() async {
    _firstRunRoutineRan = true;
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http
        .post(GConstants.getAudienceRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> data = allClassesObject['data'];
          List<dynamic> allStaffData = allClassesObject['staff'];

          List<DepartmentData> parsedDepartmentData = [];

          allStaffData.forEach((theDepartment) {
            List<dynamic> staff = theDepartment['staff'];
            List<StaffItem> parsedStaff = [];
            staff.forEach((theStaff) {
              parsedStaff
                  .add(StaffItem(int.parse(theStaff['id']), theStaff['name']));
            });
            parsedDepartmentData.add(DepartmentData(
                int.parse(theDepartment['id']),
                theDepartment['name'],
                parsedStaff));
          });

          List<ClassesWithSections> parsedClassData = [];
          data.forEach((theClass) {
            List<SectionItem> parsedSections = [];
            List<dynamic> sections = theClass['sections'];
            sections.forEach((theSections) {
              List<StudentItem> parsedStudents = [];
              List<dynamic> students = theSections['students'];
              students.forEach((theStudent) {
                parsedStudents.add(StudentItem(
                    int.parse(theStudent['stucare_id']),
                    theStudent['s_r_no'],
                    theStudent['student_name']));
              });
              parsedSections.add((SectionItem(int.parse(theSections['id']),
                  theSections['sec_name'], parsedStudents)));
            });
            parsedClassData.add(ClassesWithSections(int.parse(theClass['id']),
                theClass['class_name'], parsedSections));
          });

          _audienceData = [
            AudienceData("staff", parsedDepartmentData),
            AudienceData("students", parsedClassData)
          ];
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
        title: Text("Select Audience"),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                SelectedAudience selectedAudience = SelectedAudience();
                for (AudienceData data in _audienceData) {
                  if (data.audienceType == "staff") {
                    selectedAudience.areAllStaffSelected =
                        isAllStaffSelected(data.data);
                    if (!selectedAudience.areAllStaffSelected) {
                      if (checkedDepartment.length == 1) {
                        selectedAudience.oneDepartmentSelected = true;
                        var depName = data.data
                            .where((depData) =>
                                depData.id == checkedDepartment.elementAt(0))
                            .toList()[0]
                            .name;
                        selectedAudience.selectedDepartments.add(depName);
                      } else if (checkedDepartment.length > 1) {
                        selectedAudience.multipleDepartmentSelected = true;
                        var depName = data.data
                            .where((depData) =>
                                checkedDepartment.contains(depData.id))
                            .toList();
                        depName.forEach((depItem) {
                          selectedAudience.selectedDepartments
                              .add(depItem.name);
                        });
                      } else if (checkedStaff.length == 1) {
                        selectedAudience.oneStaffSelected = true;
                        var staffName = "";
                        for (DepartmentData depData in data.data) {
                          var rs = depData.staffData
                              .where((staffData) =>
                                  staffData.id == checkedStaff.elementAt(0))
                              .toList();
                          if(rs.length > 0){
                            staffName = rs[0].name;
                          }
                          if (staffName.isNotEmpty) {
                            break;
                          }
                        }
                        selectedAudience.selectedStaff.add(staffName);
                      } else if (checkedStaff.length > 1) {
                        selectedAudience.multipleStaffSelected = true;
                        for (DepartmentData depData in data.data) {
                          var staffList = depData.staffData
                              .where((staffData) =>
                                  checkedStaff.contains(staffData.id))
                              .toList();
                          staffList.forEach((staffItem) {
                            selectedAudience.selectedStaff.add(staffItem.name);
                          });
                        }
                      }
                    }
                  } else {
                    selectedAudience.areAllStudentsSelected =
                        isAllStudentSelected(data.data);
                    if (!selectedAudience.areAllStudentsSelected) {
                      if (checkedClasses.length == 1) {
                        selectedAudience.oneClassSelected = true;
                        var className = data.data
                            .where((classData) =>
                                classData.classCode ==
                                checkedClasses.elementAt(0))
                            .toList()[0]
                            .className;
                        selectedAudience.selectedClasses.add(className);
                      } else if (checkedClasses.length > 1) {
                        selectedAudience.multipleClassSelected = true;
                        var classNameList = data.data
                            .where((classData) =>
                                checkedClasses.contains(classData.classCode))
                            .toList();
                        classNameList.forEach((classItem) {
                          selectedAudience.selectedClasses
                              .add(classItem.className);
                        });
                      }else if (checkedSections.length == 1) {
                        selectedAudience.oneSectionSelected = true;
                        var sectionName = "";
                        for (ClassesWithSections classData in data.data) {
                          var rs = classData.sections
                              .where((sectionItem) =>
                          sectionItem.sectionCode == checkedSections.elementAt(0))
                              .toList();
                          if(rs.length > 0 ){
                            sectionName = "${classData.className} - ${rs[0].sectionName}";
                          }
                          if (sectionName.isNotEmpty) {
                            break;
                          }
                        }
                        selectedAudience.selectedSections.add(sectionName);
                      }else if (checkedSections.length > 1) {
                        selectedAudience.multipleSectionSelected = true;
                        for (ClassesWithSections classData in data.data) {
                          var sectionList = classData.sections
                              .where((sectionItem) =>
                              checkedSections.contains(sectionItem.sectionCode))
                              .toList();
                          sectionList.forEach((sectionItem) {
                            var sectionName = "${classData.className} - ${sectionItem.sectionName}";
                            selectedAudience.selectedSections.add(sectionName);
                          });
                        }
                      }else if (checkedStudents.length == 1) {
                        selectedAudience.oneStudentSelected = true;
                        var studentName = "";
                        for (ClassesWithSections classData in data.data) {
                          for(SectionItem section in classData.sections){
                            var ok = section.students
                                .where((studentItem) =>
                            studentItem.stucareId == checkedStudents.elementAt(0))
                                .toList();
                            if(ok.length > 0){
                              studentName = ok[0].studentName;
                            }
                            if (studentName.isNotEmpty) {
                              break;
                            }
                          }
                          if (studentName.isNotEmpty) {
                            break;
                          }
                        }
                        selectedAudience.selectedStudents.add(studentName);
                      }else if (checkedStudents.length > 1) {
                        selectedAudience.multipleStudentSelected = true;
                      }
                    }
                  }
                }
                selectedAudience.checkedStaff = checkedStaff;
                selectedAudience.checkedStudents = checkedStudents;
                Navigator.pop(context, selectedAudience);
              })
        ],
      ),
      body: new ListView.separated(
        itemCount: _audienceData.length,
        itemBuilder: (context, i) {
          return new ExpansionTile(
            title: new Text(
              _audienceData[i].audienceType.toUpperCase(),
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              new Column(
                children: _buildMainExpandableContent(_audienceData[i]),
              ),
            ],
            leading: Checkbox(
              value: (_audienceData[i].audienceType == "students")
                  ? isAllStudentSelected(_audienceData[i].data)
                  : isAllStaffSelected(_audienceData[i].data),
              onChanged: (nV) {
                setState(() {
                  _audienceData[i].isSelected = !_audienceData[i].isSelected;
                  if (_audienceData[i].audienceType == "students") {
                    if (_audienceData[i].isSelected) {
                      for (ClassesWithSections content
                          in _audienceData[i].data) {
                        checkedClasses.add(content.classCode);
                        _checkAllSectionForClass(content);
                      }
                    } else {
                      for (ClassesWithSections content
                          in _audienceData[i].data) {
                        checkedClasses.remove(content.classCode);
                        _uncheckAllSectionForClass(content);
                      }
                    }
                  } else {
                    if (_audienceData[i].isSelected) {
                      for (DepartmentData content in _audienceData[i].data) {
                        checkedDepartment.add(content.id);
                        _checkAllStaffForDepartment(content);
                      }
                    } else {
                      for (DepartmentData content in _audienceData[i].data) {
                        checkedDepartment.remove(content.id);
                        _uncheckAllStaffForDepartment(content);
                      }
                    }
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

  bool isAllStudentSelected(List<ClassesWithSections> classData) {
    for (ClassesWithSections content in classData) {
      for (SectionItem section in content.sections) {
        for (StudentItem student in section.students) {
          if (!checkedStudents.contains(student.stucareId)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool isAllStaffSelected(List<DepartmentData> departments) {
    for (DepartmentData department in departments) {
      for (StaffItem content in department.staffData) {
        if (!checkedStaff.contains(content.id)) {
          return false;
        }
      }
    }
    return true;
  }

  _checkAllSectionForClass(ClassesWithSections _classesData) {
    for (SectionItem content in _classesData.sections) {
      checkedSections.add(content.sectionCode);
      _checkAllStudentsForSection(content);
    }
  }

  _uncheckAllSectionForClass(ClassesWithSections _classesData) {
    for (SectionItem content in _classesData.sections) {
      checkedSections.remove(content.sectionCode);
      _uncheckAllStudentsForSection(content);
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

  _checkAllStudentsForSection(SectionItem _section) {
    for (StudentItem content in _section.students) {
      checkedStudents.add(content.stucareId);
    }
  }

  _uncheckAllStudentsForSection(SectionItem _section) {
    for (StudentItem content in _section.students) {
      checkedStudents.remove(content.stucareId);
    }
  }

  _checkAllSectionsIfNeeded(SectionItem section) {
    bool shouldSelectAllSections = true;

    for (StudentItem content in section.students) {
      if (!checkedStudents.contains(content.stucareId)) {
        shouldSelectAllSections = false;
        break;
      }
    }
    if (shouldSelectAllSections) {
      checkedSections.add(section.sectionCode);
    }
  }

  _checkAllDepartmentIfNeeded(DepartmentData depData) {
    bool shouldSelectAllClasses = true;

    for (StaffItem content in depData.staffData) {
      if (!checkedStaff.contains(content.id)) {
        shouldSelectAllClasses = false;
        break;
      }
    }
    if (shouldSelectAllClasses) {
      checkedDepartment.add(depData.id);
    }
  }

  _uncheckAllStaffForDepartment(DepartmentData depData) {
    for (StaffItem content in depData.staffData) {
      checkedStaff.remove(content.id);
    }
  }

  _checkAllStaffForDepartment(DepartmentData depData) {
    for (StaffItem content in depData.staffData) {
      checkedStaff.add(content.id);
    }
  }

  _buildMainExpandableContent(AudienceData _audienceData) {
    List<Widget> columnContent = [];

    if (_audienceData.audienceType == "students") {
      for (ClassesWithSections content in _audienceData.data)
        columnContent.add(
          Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: ExpansionTile(
                title: new Text(
                  content.className,
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                children: <Widget>[
                  new Column(
                    children: _buildSectionsList(content),
                  ),
                ],
                leading: Checkbox(
                  value: checkedClasses.contains(content.classCode),
                  onChanged: (nV) {
                    setState(() {
                      if (checkedClasses.contains(content.classCode)) {
                        checkedClasses.remove(content.classCode);
                        _uncheckAllSectionForClass(content);
                      } else {
                        checkedClasses.add(content.classCode);
                        _checkAllSectionForClass(content);
                      }
                    });
                  },
                ),
              )),
        );
    } else {
      for (DepartmentData content in _audienceData.data)
        columnContent.add(
          Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: ExpansionTile(
                title: new Text(
                  content.name,
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                children: <Widget>[
                  new Column(
                    children: _buildStaffList(content),
                  ),
                ],
                leading: Checkbox(
                  value: checkedDepartment.contains(content.id),
                  onChanged: (nV) {
                    setState(() {
                      if (checkedDepartment.contains(content.id)) {
                        checkedDepartment.remove(content.id);
                        _uncheckAllStaffForDepartment(content);
                      } else {
                        checkedDepartment.add(content.id);
                        _checkAllStaffForDepartment(content);
                      }
                    });
                  },
                ),
              )),
        );
    }

    return columnContent;
  }

  _buildSectionsList(ClassesWithSections _classesData) {
    List<Widget> columnContent = [];

    for (SectionItem content in _classesData.sections)
      columnContent.add(
        Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: ExpansionTile(
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
                    _uncheckAllStudentsForSection(content);

                    if (checkedClasses.contains(_classesData.classCode)) {
                      checkedClasses.remove(_classesData.classCode);
                    }
                  } else {
                    checkedSections.add(content.sectionCode);
                    _checkAllStudentsForSection(content);
                    _checkAllClassesIfNeeded(_classesData);
                  }
                });
              },
            ),
            children: <Widget>[
              new Column(
                children: _buildStudentsList(content, _classesData),
              ),
            ],
          ),
        ),
      );

    return columnContent;
  }

  _buildStudentsList(
      SectionItem _sectionData, ClassesWithSections _classesData) {
    List<Widget> columnContent = [];

    for (StudentItem content in _sectionData.students)
      columnContent.add(
        Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: ListTile(
            title: new Text(
              content.studentName,
              style: new TextStyle(fontSize: 14.0),
            ),
            leading: Checkbox(
              value: checkedStudents.contains(content.stucareId),
              onChanged: (nV) {
                setState(() {
                  if (checkedStudents.contains(content.stucareId)) {
                    checkedStudents.remove(content.stucareId);

                    if (checkedSections.contains(_sectionData.sectionCode)) {
                      checkedSections.remove(_sectionData.sectionCode);
                    }
                    if (checkedClasses.contains(_classesData.classCode)) {
                      checkedClasses.remove(_classesData.classCode);
                    }
                  } else {
                    checkedStudents.add(content.stucareId);
                    _checkAllSectionsIfNeeded(_sectionData);
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

  _buildStaffList(DepartmentData _departmentData) {
    List<Widget> columnContent = [];

    for (StaffItem content in _departmentData.staffData)
      columnContent.add(
        Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: ListTile(
            title: new Text(
              content.name,
              style: new TextStyle(fontSize: 14.0),
            ),
            leading: Checkbox(
              value: checkedStaff.contains(content.id),
              onChanged: (nV) {
                setState(() {
                  if (checkedStaff.contains(content.id)) {
                    checkedStaff.remove(content.id);

                    if (checkedDepartment.contains(_departmentData.id)) {
                      checkedDepartment.remove(_departmentData.id);
                    }
                  } else {
                    checkedStaff.add(content.id);
                    _checkAllDepartmentIfNeeded(_departmentData);
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

class AudienceData {
  String audienceType;
  List<dynamic> data = [];
  bool isSelected = false;

  AudienceData(this.audienceType, this.data);
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
  List<StudentItem> students = [];
  bool isSelected = false;

  SectionItem(this.sectionCode, this.sectionName, this.students);
}

class StudentItem {
  int stucareId;
  String srNo;
  String studentName;
  bool isSelected = false;

  StudentItem(this.stucareId, this.srNo, this.studentName);
}

class DepartmentData {
  int id;
  String name;
  List<StaffItem> staffData = [];

  DepartmentData(this.id, this.name, this.staffData);
}

class StaffItem {
  int id;
  String name;

  StaffItem(this.id, this.name);
}
