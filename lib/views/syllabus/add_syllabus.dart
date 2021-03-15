import 'dart:convert';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/utils/s3_upload.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';


class AddSyllabus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddSyllabus();
  }
}

class StateAddSyllabus extends State<AddSyllabus>
    with StateHelper, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _firstRunRoutineRan = false;
  TabController _tabController;

  List<Map<String, dynamic>> _terms = [];
  Map<String, dynamic> _selectedTerm;

  List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic> _selectedClass;

  List<Map<String, dynamic>> _sections = [];
  Map<String, dynamic> _selectedSection;

  TextEditingController _titleTextController = TextEditingController();
  List<String> _selectedFilesPaths = [];

  void _getTerms() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    if (activeSession == null || activeSession.sessionId == null) {
      showShortToast(context, "Please set active session and try again");
      return;
    }

    var allClassesResponse = await http.post(
        GConstants.getExamTermsRoute(await AppData().getSchoolUrl()),
        body: {
          'session_id': activeSession.sessionId.toString(),
          'active_session': sessionToken,
        });

    debugPrint("${allClassesResponse.request} ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> data = allClassesObject['data'];
          _terms.clear();
          data.forEach((theItem) {
            _terms.add(theItem);
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

  void _getClasses() async {
    showProgressDialog();
    var loginId = await AppData().getUserLoginId();
    int empId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();
    if (activeSession == null || activeSession.sessionId == null) {
      showShortToast(context, "Please set active session and try again");
      return;
    }

    var allClassesResponse = await http.post(
        GConstants.getAllClassesRoute(await AppData().getSchoolUrl()),
        body: {
          'session_id': activeSession.sessionId.toString(),
          'emp_id': empId.toString(),
          'active_session': sessionToken,
        });

    debugPrint("${allClassesResponse.request} ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> data = allClassesObject['data'];
          _classes.clear();
          _selectedClass = null;
          data.forEach((theItem) {
            _classes.add(theItem);
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

  void _getSections(classId) async {
    showProgressDialog();
    var loginId = await AppData().getUserLoginId();
    int empId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    final request = {
      'class_id': classId,
      'emp_id': empId.toString(),
      'active_session': sessionToken,
    };

    var allClassesResponse = await http.post(
        GConstants.getSectionForClassRoute(await AppData().getSchoolUrl()),
        body: request);

    debugPrint("${request.toString()}");
    debugPrint("${allClassesResponse.request} ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> data = allClassesObject['data'];
          _sections.clear();
          _selectedSection = null;
          data.forEach((theItem) {
            _sections.add(theItem);
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
          _selectedTerm = null;
          _selectedClass = null;
          _selectedSection = null;
        });
      }
    });
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
        activeSession = await SessionDbProvider().getActiveSession();
        _getTerms();
      });
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Syllabus"),
/*          actions: <Widget>[
            FlatButton(
              child: Text("SAVE"),
              textColor: Colors.white,
              disabledColor: Colors.white,
              onPressed: () {},
            )
          ],*/
        ),
        key: _scaffoldState,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 2, left: 10.0, right: 10.0, bottom: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white54,
                        border: Border.all()),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        items: _terms
                            .map((b) => DropdownMenuItem<dynamic>(
                                  child: Text(
                                    b['term_name'],
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: b,
                                ))
                            .toList(),
                        onChanged: (b) {
                          if (b == _selectedTerm) {
                            return;
                          }

                          setState(() {
                            _selectedTerm = b;
                            _getClasses();
                          });
                        },
                        hint: Text(
                          'Select Term',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        isExpanded: true,
                        value: _selectedTerm,
                      ),
                    ),
                  )),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 2, left: 10.0, right: 10.0, bottom: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white54,
                      border: Border.all()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<dynamic>(
                      items: _classes
                          .map((b) => DropdownMenuItem<dynamic>(
                                child: Text(
                                  b['class_name'],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                value: b,
                              ))
                          .toList(),
                      onChanged: (b) {
                        if (b == _selectedClass) {
                          return;
                        }

                        setState(() {
                          _selectedClass = b;
                        });
                        _getSections(b['id']);
                      },
                      hint: Text(
                        'Select Class',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      isExpanded: true,
                      value: _selectedClass,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 2, left: 10.0, right: 10.0, bottom: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white54,
                      border: Border.all()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<dynamic>(
                      items: _sections
                          .map((b) => DropdownMenuItem<dynamic>(
                                child: Text(
                                  b['sec_name'],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                value: b,
                              ))
                          .toList(),
                      onChanged: (b) {
                        if (b == _selectedSection) {
                          return;
                        }

                        setState(() {
                          _selectedSection = b;
                        });
                      },
                      hint: Text(
                        'Select Section',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      isExpanded: true,
                      value: _selectedSection,
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                      child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Title',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            hintText: "Enter Title",
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 2),
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          scrollPadding: EdgeInsets.all(0),
                          style: TextStyle(color: Colors.grey),
                          controller: _titleTextController,
                        ),
                        flex: 3,
                      ),
                    ],
                  ))),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: ButtonTheme(
                  minWidth: 44.0,
                  height: 35,
                  padding: new EdgeInsets.all(6),
                  child: new ButtonBar(children: <Widget>[
                    (_selectedFilesPaths.length > 0)
                        ? FlatButton(
                            child: new Text(
                              "Attachments (${_selectedFilesPaths.length})",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            disabledColor: Colors.grey.shade300,
                            color: Colors.grey.shade300,
                            onPressed: () {
                              //showMultiAttachmentDialog(_selectedFilesPaths);
                            },
                          )
                        : Container(
                            width: 0,
                          ),
                    Container(
                      color: Colors.grey.shade400,
                      child: PopupMenuButton<int>(
                        icon: Icon(
                          Icons.attach_file,
                          color: Colors.grey.shade700,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: Text("Select a file"),
                          ),
                        ],
                        onSelected: (v) {
                          if (v == 1) {
                            _openFileExplorer();
                          } else {}
                        },
                      ),
                      height: 35,
                    ),
                    new FlatButton(
                      child: new Text(
                        "Attachment",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      disabledColor: Colors.indigo,
                      color: Colors.indigo,
                      onPressed: () {},
                    ),
                  ]),
                ),
              ),
              Expanded(
                child: Align(
                  child: Container(
                    height: 46,
                    child: RawMaterialButton(
                      child: new Text(
                        "PROCEED",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      onPressed: () async {
                        if (_selectedTerm == null) {
                          StateHelper()
                              .showShortToast(context, "Please select term");
                        } else if (_selectedClass == null) {
                          StateHelper()
                              .showShortToast(context, "Please select class");
                        } else if (_selectedSection == null) {
                          StateHelper()
                              .showShortToast(context, "Please select section");
                        } else if (_titleTextController.text.isEmpty) {
                          StateHelper()
                              .showShortToast(context, "Please enter title");
                        } else {
                          String attachment = await _uploadAttachments();
                          if (attachment != "") {
                            addSyllabus(attachment);
                          }
                        }
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    color: Colors.indigo,
                    width: double.infinity,
                  ),
                  alignment: Alignment.bottomCenter,
                ),
              )
            ]),
      ),
    );
  }

  Future<String> _uploadAttachments() async {
    showProgressDialog();
    var filePath = _selectedFilesPaths[0];
    if (filePath == "") {
      showSnackBar("No file selected");
      return "";
    }
    String extension;
    int lastDot = filePath.lastIndexOf('.', filePath.length - 1);
    if (lastDot != -1) {
      extension = filePath.substring(lastDot + 1);
    }

    var fileNameNew =
        "${DateTime.now().millisecondsSinceEpoch.toString()}.$extension";
    var rs = await s3Upload(File(filePath), fileNameNew);
    if (!rs) {
      showSnackBar("Could not upload files");
      return "";
    }

    var imageUrl =
        "https://stucarecloud-data.s3.ap-south-1.amazonaws.com/uploaded/$fileNameNew";
    log(imageUrl);
    hideProgressDialog();
    return imageUrl.toString();
  }

  void addSyllabus(String attachment) async {
    showProgressDialog();

    String sessionToken = await AppData().getSessionToken();
    int userLoginId = await AppData().getUserLoginId();
    if (activeSession == null || activeSession.sessionId == null) {
      showShortToast(context, "Please set active session and try again");
      return;
    }

    var data = {
      'active_session': sessionToken,
      'session_id': activeSession.sessionId.toString(),
      'section_id': _selectedSection['id'].toString(),
      'class_id': _selectedClass['id'].toString(),
      'title': _titleTextController.text,
      'media': attachment,
      'media_type':'pdf'
    };

    debugPrint("${data}");

    var allClassesResponse = await http.post(
        GConstants.getAddSyllabusRoute(await AppData().getSchoolUrl()),
        body: data);

    debugPrint("${allClassesResponse.request} : ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      debugPrint(allClassesResponse.body);
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject["success"] == true) {
        hideProgressDialog();
        showSnackBar("Syllabus Added Successfully", color: Colors.indigo);
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
    hideProgressDialog();
  }

  void _openFileExplorer() async {

    var b = await _checkPermission();
    if (b) {
      var path = await FilePicker.getFilePath(type: FileType.any);

      if (path != null && isValidFile(path)) {
        setState(() {
          _selectedFilesPaths.clear();
          _selectedFilesPaths.add(path);
        });
      } else {
        showSnackBar("Invalid or No file selected");
      }
    }

  }

  bool isValidFile(String path) {
    String mimeType = mime(path);

    if (mimeType.contains("image")) {
      return false;
    } else if (mimeType.contains("video")) {
      return false;
    } else if (mimeType.contains("audio")) {
      return false;
    } else if (mimeType.contains("pdf")) {
      return true;
    }
    return false;
  }

  Future<bool> _checkPermission() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

}
