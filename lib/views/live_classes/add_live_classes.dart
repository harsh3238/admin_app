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

class AddLiveClasses extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddLiveClassesState();
  }
}

class AddLiveClassesState extends State<AddLiveClasses>
    with StateHelper, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final _topicTextController = TextEditingController();
  final _linkTextController = TextEditingController();
  var _topicFocus = FocusNode();
  var _linkFocus = FocusNode();

  bool _firstRunRoutineRan = false;

  List<dynamic> _classData = [];
  Map<String, dynamic> _selectedClass;

  List<dynamic> _sectionsData = [];
  List<dynamic> _selectedSections = [];

  List<dynamic> _subjectsData = [];
  Map<String, dynamic> _selectedSubject;

  List<dynamic> _durationDataZoom = [];
  Map<String, dynamic> _selectedZoomDuration;

  List<dynamic> _durationDataGmeet = [];
  Map<String, dynamic> _selectedGMeetDuration;

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

  List<DropdownMenuItem<Map<String, dynamic>>> getSelectableDurationsZoom() {
    return _durationDataZoom.map((item) {
      return DropdownMenuItem<Map<String, dynamic>>(
        child: Text(item['duration_name']),
        value: item,
      );
    }).toList();
  }

  List<DropdownMenuItem<Map<String, dynamic>>> getSelectableDurationsGmeet() {
    return _durationDataGmeet.map((item) {
      return DropdownMenuItem<Map<String, dynamic>>(
        child: Text(item['duration_name']),
        value: item,
      );
    }).toList();
  }

  TabController _tabController;

  List<Map<String, dynamic>> _subjects = [];


  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
    _tabController = TabController(
      vsync: this,
      length: 2,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          //_selectedTerm = null;
          //_selectedClass = null;
          //_selectedExam = null;
          _subjects.clear();
        });
      }
    });

   addZoomDuration();
   addGmeetDuration();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 200), () async {
        _getClasses();
      });
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Add Live Class"),
            bottom: TabBar(controller: _tabController, tabs: [
              Tab(
                text: "Zoom",
              ),
              Tab(
                text: "Google Meet",
              ),
            ]),
          ),
          key: _scaffoldState,
          body: TabBarView(
            controller: _tabController,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Form(
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
                                              if(value!=null){
                                                setState(() {
                                                  _selectedSections = value;
                                                });
                                                _getSubjects();
                                              }

                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: DropdownButtonFormField(
                                              items: [],
                                              hint: Text(_selectedSections!=null && _selectedSections.length > 0 ? "${_selectedSections.length} Selected" : "Select Section"),
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
                                      autofocus: false,
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
                                      focusNode: _topicFocus,
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
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: DropdownButtonFormField(
                                      items: getSelectableDurationsZoom(),
                                      value: _selectedZoomDuration,
                                      onChanged: (nV) {
                                        setState(() {
                                          _selectedZoomDuration = nV;
                                        });
                                      },
                                      hint: Text("Select Duration"),
                                    ),
                                  )
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
                            try{
                              _topicFocus.unfocus();
                              _linkFocus.unfocus();
                            }catch(_){}
                            if (_selectedClass == null || _selectedSections.length <= 0 || _selectedSubject == null ||_selectedZoomDuration == null  || _topicTextController.text.isEmpty) {
                              showSnackBar("Please select all the fields");
                              return;
                            }
                            _validateMeetingTime("zoom");
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[

                  Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Form(
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
                                              if(value!=null){
                                                setState(() {
                                                  _selectedSections = value;
                                                });
                                                _getSubjects();
                                              }

                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: DropdownButtonFormField(
                                              items: [],
                                              hint: Text(_selectedSections!=null && _selectedSections.length > 0 ? "${_selectedSections.length} Selected" : "Select Section"),
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
                                      autofocus: false,
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
                                      focusNode: _topicFocus,
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
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: DropdownButtonFormField(
                                      items: getSelectableDurationsGmeet(),
                                      value: _selectedGMeetDuration,
                                      onChanged: (nV) {
                                        setState(() {
                                          _selectedGMeetDuration = nV;
                                        });
                                      },
                                      hint: Text("Select Duration"),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: TextFormField(
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        hintText: "Meeting Link",
                                        contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                                      ),
                                      maxLines: 1,
                                      keyboardType: TextInputType.text,
                                      scrollPadding: EdgeInsets.all(0),
                                      style: TextStyle(color: Colors.grey),
                                      controller: _linkTextController,
                                      focusNode: _linkFocus,
                                    ),
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
                            try{
                              _topicFocus.unfocus();
                              _linkFocus.unfocus();
                            }catch(_){}
                            if (_selectedClass == null || _selectedSections.length <= 0 || _selectedSubject == null ||
                                _selectedGMeetDuration == null||  _linkTextController.text.isEmpty) {
                              showSnackBar("Please select all the fields");
                              return;
                            }
                            _validateMeetingTime("gmeet");
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
            ],
          )),
    );
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

  void _validateMeetingTime(String liveType) async {
    debugPrint(liveType);
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    String schoolId = await AppData().getSchoolId();
    int userLoginId = await AppData().getUserLoginId();
    var allClassesResponse = await http.post(GConstants.getValidateMeetingTimeRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
      'user_id': userLoginId.toString(),
      'school_id': schoolId,
      'start_time': "${mSelectedTime.hour}:${mSelectedTime.minute}:00",
      'end_time': DateFormat()
          .addPattern("HH:mm:ss")
          .format(DateFormat().addPattern("HH:mm").parse("${mSelectedTime.hour}:${mSelectedTime.minute}")
          .add(Duration(minutes: int.parse(liveType=="zoom"?_selectedZoomDuration["duration"]:_selectedGMeetDuration["duration"])))),
      'class_date': DateFormat().addPattern("yyyy-MM-dd").format(DateFormat().addPattern("dd-MM-yyyy").parse(mSelectedDate))
    });

    debugPrint("${allClassesResponse.request} : ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          var isTimeValid = allClassesObject["is_time_valid"];
          if (isTimeValid == 1) {
            var meetingData = {
              'topic': _topicTextController.text,
              'date': DateFormat().addPattern("yyyy-MM-dd").format(DateFormat().addPattern("dd-MM-yyyy").parse(mSelectedDate)),
              'time': "${mSelectedTime.hour}:${mSelectedTime.minute}:00",
              'password': getRandomString(8),
              'duration': liveType=="zoom"?_selectedZoomDuration["duration"]:_selectedGMeetDuration["duration"]
            };
            debugPrint(meetingData.toString());

              if(liveType=="zoom"){
                //schedule zoom class
                var platform = MethodChannel("com.stucare.cloud_admin.default_channel");
                var meetingId = await platform.invokeMethod("schedule_class", meetingData);
                _putMeetingInDb(meetingId.toString(), meetingData['password'], liveType);
                return null;

              }else{
                //schedule Google meet class
                _putMeetingInDb(_linkTextController.text, meetingData['password'], liveType);
                return null;
              }
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

  void _putMeetingInDb(String meetingId, String password, String liveType) async {
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
          .format(DateFormat().addPattern("HH:mm").parse("${mSelectedTime.hour}:${mSelectedTime.minute}")
          .add(Duration(minutes: int.parse(liveType=="zoom"?_selectedZoomDuration["duration"]:_selectedGMeetDuration["duration"])))),
      "meeting_id": meetingId,
      'meeting_password': password,
      'class_id': _selectedClass['id'].toString(),
      'section_ids': jsonEncode(_selectedSections),
      'subject_id': _selectedSubject['id'].toString(),
      'cloud_class_name': _selectedClass['class_name'].toString(),
      'live_type': liveType,
      'class_date': DateFormat().addPattern("yyyy-MM-dd").format(DateFormat().addPattern("dd-MM-yyyy").parse(mSelectedDate))

      //add fields live_type, live_link
    };
    var allClassesResponse = await http.post(GConstants.getPutMeetingRoute(await AppData().getSchoolUrl()), body: data);

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      debugPrint(allClassesResponse.body);
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          hideProgressDialog();
          showSnackBar("Class Added Successfully", color: Colors.indigo);
          Future.delayed(Duration(seconds: 1), (){
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

  void addZoomDuration() {
    _durationDataZoom.add({'duration':'5','duration_name':'5 Minutes'});
    _durationDataZoom.add({'duration':'10','duration_name':'10 Minutes'});
    _durationDataZoom.add({'duration':'15','duration_name':'15 Minutes'});
    _durationDataZoom.add({'duration':'20','duration_name':'20 Minutes'});
    _durationDataZoom.add({'duration':'25','duration_name':'25 Minutes'});
    _durationDataZoom.add({'duration':'30','duration_name':'30 Minutes'});
    _durationDataZoom.add({'duration':'35','duration_name':'35 Minutes'});
    _durationDataZoom.add({'duration':'40','duration_name':'40 Minutes'});
    _durationDataZoom.add({'duration':'45','duration_name':'45 Minutes'});
    _durationDataZoom.add({'duration':'50','duration_name':'50 Minutes'});
    _durationDataZoom.add({'duration':'55','duration_name':'55 Minutes'});
    _durationDataZoom.add({'duration':'60','duration_name':'60 Minutes'});
    _durationDataZoom.add({'duration':'65','duration_name':'65 Minutes'});
    _durationDataZoom.add({'duration':'70','duration_name':'70 Minutes'});
    _durationDataZoom.add({'duration':'75','duration_name':'75 Minutes'});
    _durationDataZoom.add({'duration':'80','duration_name':'80 Minutes'});
    _durationDataZoom.add({'duration':'85','duration_name':'85 Minutes'});
    _durationDataZoom.add({'duration':'90','duration_name':'90 Minutes'});
  }
  void addGmeetDuration() {
    _durationDataGmeet.add({'duration':'10','duration_name':'10 Minutes'});
    _durationDataGmeet.add({'duration':'20','duration_name':'20 Minutes'});
    _durationDataGmeet.add({'duration':'30','duration_name':'30 Minutes'});
    _durationDataGmeet.add({'duration':'40','duration_name':'40 Minutes'});
    _durationDataGmeet.add({'duration':'50','duration_name':'50 Minutes'});
    _durationDataGmeet.add({'duration':'60','duration_name':'60 Minutes'});
    _durationDataGmeet.add({'duration':'70','duration_name':'70 Minutes'});
    _durationDataGmeet.add({'duration':'80','duration_name':'80 Minutes'});
    _durationDataGmeet.add({'duration':'90','duration_name':'90 Minutes'});
    _durationDataGmeet.add({'duration':'100','duration_name':'100 Minutes'});
    _durationDataGmeet.add({'duration':'110','duration_name':'110 Minutes'});
    _durationDataGmeet.add({'duration':'120','duration_name':'120 Minutes'});
    _durationDataGmeet.add({'duration':'130','duration_name':'130 Minutes'});
    _durationDataGmeet.add({'duration':'140','duration_name':'140 Minutes'});
    _durationDataGmeet.add({'duration':'150','duration_name':'150 Minutes'});
    _durationDataGmeet.add({'duration':'160','duration_name':'160 Minutes'});
    _durationDataGmeet.add({'duration':'170','duration_name':'170 Minutes'});
    _durationDataGmeet.add({'duration':'180','duration_name':'180 Minutes'});
  }

}
