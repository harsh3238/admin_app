import 'dart:convert';
import 'dart:math';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_dialog.dart';

import '../state_helper.dart';


enum ParentType { father, mother, guardian }

class AddLiveClass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddLiveClass();
  }
}

class StateAddLiveClass extends State<AddLiveClass> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _topicTextController = TextEditingController();

  List<dynamic> _classData = [];
  bool _firstRunRoutineRan = false;

  Map<String, dynamic> _selectedClass;
  List<dynamic> _sectionsData = [];
  List<dynamic> _selectedSections = [];

  List<dynamic> _subjectsData = [];
  Map<String, dynamic> _selectedSubject;

  String mSelectedDate = DateFormat().addPattern("dd-MM-yyyy").format(DateTime.now());
  TimeOfDay mSelectedTime = TimeOfDay.now();

  List<DropdownMenuItem<Map<String, dynamic>>> getSelectableClasses() {
    return _classData.map((item) {
      return DropdownMenuItem<Map<String, dynamic>>(
        child: Text(item['class_name']),
        value: item,
      );
    }).toList();
  }

  List<DropdownMenuItem<Map<String, dynamic>>> getSelectableSubjects() {
    return _subjectsData.map((item) {
      return DropdownMenuItem<Map<String, dynamic>>(
        child: Text(item['subject_name']),
        value: item,
      );
    }).toList();
  }

  void _getClasses() async {
    _firstRunRoutineRan = true;
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var allClassesResponse = await http.post(GConstants.getAllClassesRoute(await AppData().getSchoolUrl()), body: {
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
            _classData.add(theItem);
          });
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

  void _getSections() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var allClassesResponse = await http.post(GConstants.getSectionForClassRoute(await AppData().getSchoolUrl()),
        body: {'active_session': sessionToken, 'class_id': _selectedClass['id'].toString()});

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _sectionsData = allClassesObject['data'];
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

  void _getSubjects() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var allClassesResponse = await http.post(GConstants.getSubjectForClassRoute(await AppData().getSchoolUrl()),
        body: {'active_session': sessionToken, 'class_id': _selectedClass['id'].toString()});

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _subjectsData = allClassesObject['data'];
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

  void _validateMeetingTime() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    String schoolId = await AppData().getSchoolId();
    int userLoginId = await AppData().getUserLoginId();
    var allClassesResponse = await http.post(GConstants.getValidateMeetingTimeRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
      'user_id': userLoginId.toString(),
      'school_id': schoolId,
      'start_time': "${mSelectedTime.hour}:${mSelectedTime.minute}",
      'class_date': DateFormat().addPattern("yyyy-MM-dd").format(DateFormat().addPattern("dd-MM-yyyy").parse(mSelectedDate))
    });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          var isTimeValid = allClassesObject["is_time_valid"];
          if (isTimeValid == 1) {
            var platform = MethodChannel("com.stucare.cloud_admin.default_channel");
            var meetingData = {
              'topic': _topicTextController.text,
              'date': DateFormat().addPattern("yyyy-MM-dd").format(DateFormat().addPattern("dd-MM-yyyy").parse(mSelectedDate)),
              'time': "${mSelectedTime.hour}:${mSelectedTime.minute}:00",
              'password': getRandomString(8)
            };
            var meetingId = await platform.invokeMethod("schedule_class", meetingData);
            _putMeetingInDb(meetingId.toString(), meetingData['password']);
            return null;
          } else {
            showSnackBar("you already have a meeting scheduled around this time");
            hideProgressDialog();
          }
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

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  void _putMeetingInDb(String meetingId, String password) async {
    String sessionToken = await AppData().getSessionToken();
    String schoolId = await AppData().getSchoolId();
    int userLoginId = await AppData().getUserLoginId();
    var data = {
      'active_session': sessionToken,
      'user_id': userLoginId.toString(),
      'school_id': schoolId,
      'topic_name': _topicTextController.text,
      'start_time': "${mSelectedTime.hour}:${mSelectedTime.minute}",
      'end_time': DateFormat()
          .addPattern("HH:mm:ss")
          .format(DateFormat().addPattern("HH:mm").parse("${mSelectedTime.hour}:${mSelectedTime.minute}").add(Duration(minutes: 40))),
      "meeting_id": meetingId,
      'meeting_password': password,
      'class_id': _selectedClass['id'].toString(),
      'section_ids': jsonEncode(_selectedSections),
      'subject_id': _selectedSubject['id'].toString(),
      'cloud_class_name': _selectedClass['class_name'].toString(),
      'class_date': DateFormat().addPattern("yyyy-MM-dd").format(DateFormat().addPattern("dd-MM-yyyy").parse(mSelectedDate))
    };
    var allClassesResponse = await http.post(GConstants.getPutMeetingRoute(await AppData().getSchoolUrl()), body: data);

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          hideProgressDialog();
          showSnackBar("class added");
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
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getClasses();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add Classes"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Card(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: DropdownButtonFormField(
                                items: getSelectableClasses(),
                                value: _selectedClass,
                                onChanged: (nV) {
                                  setState(() {
                                    _selectedClass = nV;
                                  });
                                  _getSections();
                                },
                                hint: Text("Select Class"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return MultiSelectDialog(
                                        items: _sectionsData.map((e) {
                                          return MultiSelectDialogItem(e['id'], e['sec_name']);
                                        }).toList(),
                                        title: "Select Sections",
                                        cancelButtonLabel: "Cancel",
                                        okButtonLabel: "Okay",
                                      );
                                    }).then((value) {
                                  setState(() {
                                    _selectedSections = value;
                                  });
                                  _getSubjects();
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: DropdownButtonFormField(
                                  items: [],
                                  hint: Text(_selectedSections.length > 0 ? "${_selectedSections.length} Selected" : "Select Section"),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                          items: getSelectableSubjects(),
                          value: _selectedSubject,
                          onChanged: (nV) {
                            setState(() {
                              _selectedSubject = nV;
                            });
                          },
                          hint: Text("Select Subject"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Topic",
                            contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          scrollPadding: EdgeInsets.all(0),
                          style: TextStyle(color: Colors.grey),
                          controller: _topicTextController,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(Duration(days: 30)),
                                  lastDate: DateTime.now().add(Duration(days: 30)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    mSelectedDate = DateFormat().addPattern("dd-MM-yyyy").format(picked);
                                  });
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: DropdownButtonFormField(
                                  items: [],
                                  hint: Text(mSelectedDate),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final TimeOfDay picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null)
                                  setState(() {
                                    mSelectedTime = picked;
                                  });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: DropdownButtonFormField(
                                  items: [],
                                  hint: Text(mSelectedTime.format(context)),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
          Align(
            child: Container(
              color: Colors.indigo,
              child: FlatButton(
                  onPressed: () {
                    if (_selectedClass == null || _selectedSections.length <= 0 || _selectedSubject == null || _topicTextController.text.isEmpty) {
                      showSnackBar("Please select all the fields");
                      return;
                    }
                    _validateMeetingTime();
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
