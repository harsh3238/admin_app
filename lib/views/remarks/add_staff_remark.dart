import 'dart:convert';
import 'dart:developer';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import '../state_helper.dart';

class AddStaffRemark extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddStaffRemark();
  }
}

class StateAddStaffRemark extends State<AddStaffRemark> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _descriptionTextController = TextEditingController();
  String remark_category = "unknown"; //1-positive, 2-negative
  String remark_visibility = "unknown"; //1-public, 2-private

  bool _firstRunRoutineRan = false;

  FocusNode descriptionFocus = FocusNode();

  List<dynamic> _departmentList = [];
  Map<String, dynamic> _selectedDepartment;

  List<dynamic> _staffList = [];
  Map<String, dynamic> _selectedStaff;

  List<dynamic> _remarkTypeList = [];
  Map<String, dynamic> _selectedRemarkType;

  String mSelectedDate = DateFormat().addPattern("dd-MM-yyyy").format(DateTime.now());
  TimeOfDay mSelectedTime = TimeOfDay.now();

  void _getDepartments() async {
    _firstRunRoutineRan = true;
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffDepartmentRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    log("${modulesResponse.request} : ${modulesResponse.body}");
    
    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {

          List<dynamic> data = modulesResponseObject['data'];
          _departmentList.clear();
          data.forEach((theItem) {
            _departmentList.add(theItem);
          });
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

  Future<void> _getStaff() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffByDepartmentRoute(await AppData().getSchoolUrl()),
        body: {'department_id': _selectedDepartment['id'].toString(), 'active_session': sessionToken,});

    log("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> data = modulesResponseObject['data'];
          _staffList.clear();
          data.forEach((theItem) {
            _staffList.add(theItem);
          });

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
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        activeSession = await SessionDbProvider().getActiveSession();
        _getDepartments();
        _getRemarkType();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add Staff Remark"),
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
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                      child: Container(
                        padding: const EdgeInsets.only(top: 2, left: 10.0, right: 10.0, bottom: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0), color: Colors.white54, border: Border.all()),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<dynamic>(
                            items: _departmentList
                                .map((b) => DropdownMenuItem<dynamic>(
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
                              if (b == _selectedDepartment) {
                                return;
                              }

                              setState(() {
                                _selectedDepartment = b;
                                _selectedStaff = null;
                                _staffList.clear();

                              });
                              _getStaff();
                            },
                            hint: Text(
                              'Select Department',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            isExpanded: true,
                            value: _selectedDepartment,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                      child: Container(
                        padding: const EdgeInsets.only(left: 5.0, right: 0.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0), color: Colors.white54, border: Border.all()),
                        child: SearchableDropdown.single(
                          underline: Container(),
                          displayClearIcon: false,
                          items: _staffList
                              .map((b) => DropdownMenuItem<dynamic>(
                                    child: Text(
                                      b['name'],
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    value: b,
                                  ))
                              .toList(),
                          value: _selectedStaff,
                          hint: "Select Employee",
                          searchHint: "Search Employee",
                          onChanged: (value) {
                            if (value == _selectedStaff) {
                              return;
                            }
                            setState(() {
                              _selectedStaff = value;
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                      child: Container(
                        padding: const EdgeInsets.only(top: 2, left: 10.0, right: 10.0, bottom: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0), color: Colors.white54, border: Border.all()),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<dynamic>(
                            items: _remarkTypeList
                                .map((b) => DropdownMenuItem<dynamic>(
                                      child: Text(
                                        b['remark'],
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      value: b,
                                    ))
                                .toList(),
                            onChanged: (b) {
                              if (b == _selectedRemarkType) {
                                return;
                              }

                              setState(() {
                                _selectedRemarkType = b;
                              });
                            },
                            hint: Text(
                              'Select Type',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            isExpanded: true,
                            value: _selectedRemarkType,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: TextFormField(
                          focusNode: descriptionFocus,
                          decoration: InputDecoration(
                            hintText: "Remark Description",
                            contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                          ),
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 1000,
                          keyboardType: TextInputType.text,
                          scrollPadding: EdgeInsets.all(0),
                          style: TextStyle(color: Colors.grey),
                          controller: _descriptionTextController,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 0),
                      child: Text(
                        "Remark Visibility",
                        style: TextStyle(fontSize: 17, color: Colors.black38, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _getActionButtons(),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 0),
                      child: Text(
                        "Category of Remark",
                        style: TextStyle(fontSize: 17, color: Colors.black38, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 12.0, top: 15.0, bottom: 15),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              remark_category == "negative" ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                              size: 40,
                              color: Colors.red,
                            ),
                            highlightColor: Colors.grey,
                            onPressed: () {
                              setState(() {
                                remark_category = "negative";
                              });
                            },
                          ),
                          SizedBox(width: 30),
                          IconButton(
                            icon: Icon(
                              remark_category == "positive" ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                              size: 40,
                              color: Colors.green,
                            ),
                            highlightColor: Colors.grey,
                            onPressed: () {
                              setState(() {
                                remark_category = "positive";
                              });
                            },
                          ),
                        ],
                      ),
                    ),
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
                    if (_selectedDepartment == null) {
                      showSnackBar("Please select department");
                      return;
                    }
                    if (_selectedStaff == null) {
                      showSnackBar("Please select employee");
                      return;
                    }

                    if (_selectedRemarkType == null) {
                      showSnackBar("Please select remark type");
                      return;
                    }

                    if (_descriptionTextController.text.isEmpty) {
                      showSnackBar("Please add remark description");
                      return;
                    }

                    if (remark_visibility == "unknown") {
                      showSnackBar("Please select remark visibility");
                      return;
                    }

                    if (remark_category == "unknown") {
                      showSnackBar("Please select remark category");
                      return;
                    }
                    descriptionFocus.unfocus();
                    _saveRemark();
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

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 15.0, bottom: 15),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  height: 45,
                  child: new RaisedButton(
                    child: new Text("Staff"),
                    textColor: Colors.white,
                    color: remark_visibility == "public" ? Colors.deepOrange : Colors.black26,
                    onPressed: () async {
                      setState(() {
                        remark_visibility = "public";
                      });
                    },
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  height: 45,
                  child: new RaisedButton(
                    child: new Text("School"),
                    textColor: Colors.white,
                    color: remark_visibility == "private" ? Colors.deepOrange : Colors.black26,
                    onPressed: () {
                      setState(() {
                        remark_visibility = "private";
                      });
                    },
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  void _saveRemark() async {
    showProgressDialog();

    log("${_selectedStaff}");

    String sessionToken = await AppData().getSessionToken();
    int userLoginId = await AppData().getUserLoginId();
    if (activeSession == null || activeSession.sessionId == null) {
      showShortToast(context, "Please set active session and try again");
      return;
    }

    var data = {
      'active_session': sessionToken,
      'session_id': activeSession.sessionId.toString(),
      'remarkee_id': _selectedStaff['login_id'],
      'remark_for' : 'staff',
      'remark_type_id': _selectedRemarkType['id'].toString(),
      'description': _descriptionTextController.text,
      'visibility': remark_visibility == "public" ? "1" : "2",
      'category': remark_category == "positive" ? "1" : "2",
    };

    debugPrint("${data}");

    var allClassesResponse =
        await http.post(GConstants.getSaveStudentRemarkRoute(await AppData().getSchoolUrl()), body: data);

    debugPrint("${allClassesResponse.request} : ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      debugPrint(allClassesResponse.body);
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("success")) {
        if (allClassesObject["success"] == true) {
          hideProgressDialog();
          showSnackBar("Remark Added Successfully", color: Colors.indigo);
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });
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

  void _getRemarkType() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var allClassesResponse = await http.post(GConstants.getRemarkTypeRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    log("${allClassesResponse.request} : ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("success")) {
        if (allClassesObject["success"] == true) {
          _remarkTypeList = allClassesObject['data'];

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
}
