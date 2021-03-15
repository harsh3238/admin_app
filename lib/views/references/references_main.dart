import 'dart:convert';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/reference_object.dart';
import 'package:click_campus_admin/data/models/the_class.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

enum ParentType { father, mother, guardian }

class AddReference extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddReference();
  }
}

class StateAddReference extends State<AddReference> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _parentNameTextController = TextEditingController();
  final _parentMobileTextController = TextEditingController();

  final _addressTextController = TextEditingController();
  final _remarkTextController = TextEditingController();

  final _student1NameTextController = TextEditingController();
  final _student1SchoolNameTextController = TextEditingController();

  final _student2NameTextController = TextEditingController();
  final _student2SchoolNameTextController = TextEditingController();

  final _student3NameTextController = TextEditingController();
  final _student3SchoolNameTextController = TextEditingController();

  TheClass dropDown1SelectedValue;
  TheClass dropDown2SelectedValue;
  TheClass dropDown3SelectedValue;

  Map<int, int> selectedClassCodes = Map();

  List<TheClass> _classData = List();
  bool _firstRunRoutineRan = false;
  int visibleOptions = 1;
  Widget theFooterWidget;
  bool shouldShowRemove = false;

  ParentType _parentType = ParentType.father;

  void _addReference() async {
    showProgressDialog();
    var userLoginId = await AppData().getUserLoginId();

    List<ReferenceObject> paramsList = List();
    for (int i = 1; i <= visibleOptions; i++) {
      paramsList.add(ReferenceObject(
          parentName: _parentNameTextController.text,
          parentMobile: _parentMobileTextController.text,
          parentType: _parentType.toString().split('.')[1],
          studentName: getStudentNameTextController(i).text,
          appliedClass: getClassDropDownDefaultValue(i).classId.toString(),
          prevSchool: getStudentSchoolTextController(i).text,
          address: _addressTextController.text,
          remark: _remarkTextController.text,
          refByType: "admin",
          refById: userLoginId.toString()));
    }

    var modulesResponse = await http.post(
        GConstants.getAddReferenceRoute(await AppData().getSchoolUrl()),
        body: json.encode(paramsList),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          hideProgressDialog();
          Navigator.pop(context, true);
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

  void _getClasses() async {
    _firstRunRoutineRan = true;
    showProgressDialog();

    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http
        .post(GConstants.getAllClassesRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> data = allClassesObject['data'];
          _classData.clear();
          data.forEach((theItem) {
            _classData.add(TheClass.fromJson(theItem));
          });
          dropDown1SelectedValue = _classData[0];
          hideProgressDialog();
          setState(() {});
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

  List<DropdownMenuItem<TheClass>> getSelectableClasses() {
    return _classData.map((item) {
      return DropdownMenuItem<TheClass>(
        child: Text(item.className),
        value: item,
      );
    }).toList();
  }

  TextEditingController getStudentNameTextController(int position) {
    switch (position) {
      case 1:
        return _student1NameTextController;
      case 2:
        return _student2NameTextController;
      case 3:
        return _student3NameTextController;
    }
    return null;
  }

  TextEditingController getStudentSchoolTextController(int position) {
    switch (position) {
      case 1:
        return _student1SchoolNameTextController;
      case 2:
        return _student2SchoolNameTextController;
      case 3:
        return _student3SchoolNameTextController;
    }
    return null;
  }

  TheClass getClassDropDownDefaultValue(int position) {
    switch (position) {
      case 1:
        return dropDown1SelectedValue;
      case 2:
        return dropDown2SelectedValue;
      case 3:
        return dropDown3SelectedValue;
    }
    return null;
  }

  List<Widget> getOneOptionItem(int position) {
    return [
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            decoration: InputDecoration(
                labelText: "Student $position Name",
                contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                labelStyle: TextStyle(fontSize: 14)),
            maxLines: 1,
            keyboardType: TextInputType.text,
            scrollPadding: EdgeInsets.all(0),
            validator: (txt) {
              if (txt.length <= 0) {
                return "Please enter Student $position name";
              }
              return null;
            },
            controller: getStudentNameTextController(position),
          )),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            decoration: InputDecoration(
                labelText: "Student $position 's previous school if any",
                contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                labelStyle: TextStyle(fontSize: 14)),
            maxLines: 1,
            keyboardType: TextInputType.text,
            scrollPadding: EdgeInsets.all(0),
            validator: (txt) {
              return null;
            },
            controller: getStudentSchoolTextController(position),
          )),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: _classData.length > 0
              ? DropdownButtonFormField(
            items: getSelectableClasses(),
            value: getClassDropDownDefaultValue(position),
            onChanged: (nV) {
              setState(() {
                switch (position) {
                  case 1:
                    {
                      dropDown1SelectedValue = nV;
                      break;
                    }
                  case 2:
                    {
                      dropDown2SelectedValue = nV;
                      break;
                    }
                  case 3:
                    {
                      dropDown3SelectedValue = nV;
                      break;
                    }
                }
              });
            },
            hint: Text("Select Class"),
          )
              : Container(
            height: 0,
          )),
    ];
  }

  Widget getWidgets() {
    List<Widget> theList = List();

    for (int i = 1; i <= visibleOptions; i++) {
      theList.add(Column(
        children: getOneOptionItem(i),
      ));
    }
    theList.add(theFooterWidget);
    return Column(
      children: theList,
    );
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
        _getClasses();
      });
    }

    theFooterWidget = Align(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            shouldShowRemove
                ? FlatButton(
              child: Text("Remove"),
              onPressed: () {
                setState(() {
                  if (visibleOptions > 1) {
                    visibleOptions -= 1;
                    if (visibleOptions == 1) {
                      shouldShowRemove = false;
                    }
                  } else {
                    shouldShowRemove = false;
                  }
                });
              },
            )
                : Container(
              height: 0,
            ),
            FlatButton(
              child: Text("Add more student"),
              onPressed: () {
                setState(() {
                  if (visibleOptions < 3) {
                    visibleOptions += 1;
                    shouldShowRemove = true;
                  }
                });
              },
            )
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      alignment: Alignment.centerRight,
    );

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("References"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: "Parent/Guardian Name",
                                contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                                labelStyle: TextStyle(fontSize: 14)),
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            scrollPadding: EdgeInsets.all(0),
                            validator: (txt) {
                              if (txt.length <= 0) {
                                return "Please enter parent/guardian name";
                              }
                              return null;
                            },
                            controller: _parentNameTextController,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: "Parent/Guardian Mobile",
                                contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                                labelStyle: TextStyle(fontSize: 14)),
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            scrollPadding: EdgeInsets.all(0),
                            validator: (txt) {
                              RegExp regex = new RegExp("^\\d{10}\$");
                              if (!regex.hasMatch(txt)) {
                                return "Invalid mobile number";
                              }
                              return null;
                            },
                            controller: _parentMobileTextController,
                          ),
                        ),
                        SizedBox(
                          child: Row(
                            children: <Widget>[
                              Radio<ParentType>(
                                value: ParentType.father,
                                groupValue: _parentType,
                                onChanged: (ParentType value) {
                                  setState(() {
                                    _parentType = value;
                                  });
                                },
                              ),
                              Text(
                                "Father",
                                style: TextStyle(fontSize: 11),
                              ),
                              Radio<ParentType>(
                                value: ParentType.mother,
                                groupValue: _parentType,
                                onChanged: (ParentType value) {
                                  setState(() {
                                    _parentType = value;
                                  });
                                },
                              ),
                              Text(
                                "Mother",
                                style: TextStyle(fontSize: 11),
                              ),
                              Radio<ParentType>(
                                value: ParentType.guardian,
                                groupValue: _parentType,
                                onChanged: (ParentType value) {
                                  setState(() {
                                    _parentType = value;
                                  });
                                },
                              ),
                              Text(
                                "Guardian",
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                          ),
                        ),
                        getWidgets(),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Address",
                                  contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                                  labelStyle: TextStyle(fontSize: 14)),
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              scrollPadding: EdgeInsets.all(0),
                              validator: (txt) {
                                return null;
                              },
                              controller: _addressTextController,
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: "Remark",
                                  contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                                  labelStyle: TextStyle(fontSize: 14)),
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              scrollPadding: EdgeInsets.all(0),
                              validator: (txt) {
                                return null;
                              },
                              controller: _remarkTextController,
                            ))
                      ],
                    ),
                  ),
                ),
              )),
          Align(
            child: Container(
              color: Colors.indigo,
              child: FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _addReference();
                    }
                  },
                  child: Text(
                    "SUBMIT",
                    style: TextStyle(color: Colors.white),
                  )),
              width: double.infinity,
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }
}
