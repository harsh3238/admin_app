import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/data/downlaod_task_data.dart';
import 'package:click_campus_admin/data/models/syllabus.dart';
import 'package:click_campus_admin/data/models/the_session.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/syllabus/add_syllabus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SyllabusMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateSyllabusMain();
  }
}

class StateSyllabusMain extends State<SyllabusMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _firstRunRoutineRan = false;
  bool _isDownloaderRunning = false;

  List<Map<String, dynamic>> _allClasses = List();
  List<Map<String, dynamic>> _allSections = List();

  List<ModelSyllabus> _syllabusList = List();

  int _selectedClass;
  int _selectedSection;

  TheSession _activeSession;
  List<TheSession> _allSessions = List();

  void _getSyllabus() async {
    _firstRunRoutineRan = true;
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var syllabusData = await http.post(
        GConstants.getSyllabusRoute(await AppData().getSchoolUrl()),
        body: {
          'class_id': _selectedClass.toString(),
          'section_id': _selectedSection.toString(),
          'session_id': _activeSession.sessionId.toString(),
          'active_session': sessionToken,
        });

    log("${syllabusData.request} : ${syllabusData.body}");

    if (syllabusData.statusCode == 200) {
      Map allClassesObject = json.decode(syllabusData.body);
      if (allClassesObject.containsKey("status")) {
        _syllabusList.clear();
        if (allClassesObject["status"] == "success") {
          List<dynamic> data = allClassesObject['data'];
          data.forEach((item) {
            _syllabusList.add(ModelSyllabus.fromJson(item));
          });
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          setState(() {});
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
          _activeSession = await SessionDbProvider().getActiveSession();
          hideProgressDialog();
          _getAllSession();
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

  void getSectionsForClass(int classId) async {
    _selectedSection = null;
    _allSections = await DbClassSection().getSectionsByClassId(classId);
    setState(() {});
  }

  void _setActiveSession(TheSession theSession) async{
    await SessionDbProvider().setActiveSession(theSession.sessionId);
    _activeSession = await SessionDbProvider().getActiveSession();
    setState(() {
    });
  }

  void _getAllSession() async{
    _allSessions = await SessionDbProvider().getAllSessions();
    setState(() {
    });
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

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (b) => AddSyllabus())).then((value){

            });
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text("Syllabus"), actions: <Widget>[FlatButton(
          child: _activeSession != null
              ? Text(_activeSession.sessionName)
              : Container(
            height: 0,
          ),
          textColor: Colors.white,
          disabledColor: Colors.white,
          onPressed: () {
            var dialog = SimpleDialog(
              title: const Text('Change Session'),
              children: _allSessions.map((oneSessionItem){
                return SimpleDialogOption(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      oneSessionItem.sessionName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, oneSessionItem);
                  },
                );
              }).toList(),
            );
            showDialog(
              context: context,
              builder: (BuildContext context) => dialog,
            ).then((value){
              //print(value);
              _setActiveSession(value);
            });
          },
        ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: 'Refresh',
                child: Text('Refresh'),
              ),
            ],
          )],),
        key: _scaffoldState,
        body: Container(
          color: Colors.grey.shade200,
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Theme(
                          data: Theme.of(context)
                              .copyWith(brightness: Brightness.dark),
                          child: _allClasses.length > 0
                              ? DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                  value: _selectedClass,
                                  items: _allClasses
                                      .map((b) => DropdownMenuItem<int>(
                                            child: Text(
                                              "Class ${b['class_name']}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  inherit: false),
                                            ),
                                            value: b['id'],
                                          ))
                                      .toList(),
                                  hint: Text(
                                    'Select Class',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onChanged: (b) {
                                    _allSections = [];
                                    setState(() {
                                      _selectedClass = _allClasses
                                          .where((Map<String, dynamic> item) =>
                                              item['id'] == b)
                                          .toList()[0]['id'];
                                    });
                                    getSectionsForClass(_selectedClass);
                                  },
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ))
                              : Container(
                                  height: 0,
                                )),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Theme(
                          data: Theme.of(context)
                              .copyWith(brightness: Brightness.dark),
                          child: _allSections.length > 0
                              ? DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                  value: _selectedSection,
                                  items: _allSections
                                      .map((b) => DropdownMenuItem<int>(
                                            child: Text(
                                              "Section ${b['sec_name']}",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            value: b['id'],
                                          ))
                                      .toList(),
                                  onChanged: (b) {
                                    setState(() {
                                      _selectedSection = _allSections
                                          .where((Map<String, dynamic> item) =>
                                              item['id'] == b)
                                          .toList()[0]['id'];
                                    });
                                  },
                                  hint: Text(
                                    'Select Section',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                              : Container(
                                  height: 0,
                                )),
                    ),
                    FlatButton(
                      child: Text(
                        "GO",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      shape:
                          CircleBorder(side: BorderSide(color: Colors.white54)),
                      onPressed: (){
                        _getSyllabus();
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                color: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              Expanded(
                  child: CustomScrollView(slivers: [
                    SliverList(
                        delegate:
                        SliverChildBuilderDelegate((BuildContext context, int index) {
                          return GestureDetector(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      height: 40,
                                      width: 40,
                                      padding: EdgeInsets.all(6),
                                      child: Image(
                                        image:
                                        AssetImage("assets/dash_icons/ic_syllabus_p.png"),
                                        fit: BoxFit.fill,
                                      ),
                                      decoration: ShapeDecoration(
                                          color: Colors.indigo,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(4)))),
                                    ),
                                    Container(
                                      width: 20,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(_syllabusList[index].title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 12)),
                                        Text(
                                            "Date : ${DateFormat().addPattern("dd-MM-yyyy 'at' hh:mm a").format(DateTime.parse(_syllabusList[index].timestamp))}",
                                            style: TextStyle(
                                                color: Colors.grey.shade800, fontSize: 12)),
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                    ),
                                  ],
                                ),
                              ),
                              elevation: 0,
                            ),
                            onTap: () async {
                              ///We try to get the task ID in case we have already downloaded the file
                              var a;
                              try {
                                a = await DownloadTasks()
                                    .getTaskIdForFile(_syllabusList[index].mediaPath);
                              } catch (e) {
                                //just don't do anything
                              }

                              if (a != null) {
                                var taskStatus = await DownloadTasks().getTaskStatus(a);

                                ///3 means the task completed successfully and the file
                                ///can be opened now
                                if (taskStatus == 3) {
                                  FlutterDownloader.open(taskId: a);
                                } else if (taskStatus == 4 ||
                                    taskStatus == 5 ||
                                    taskStatus == 6) {

                                  ///if task failed, was canceled or paused try to restart the task
                                  if (_isDownloaderRunning) {
                                    showSnackBar("Downloader is running, please wait.");
                                  } else {
                                    _requestDownload(_syllabusList[index].mediaPath);
                                  }
                                }
                              } else {
                                ///If task was never queued, start now
                                if (_isDownloaderRunning) {
                                  showSnackBar("Downloader is running, please wait.");
                                } else {
                                  _requestDownload(_syllabusList[index].mediaPath);
                                }
                              }
                            },
                          );
                        }, childCount: _syllabusList.length))
              ]))
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
        ));
  }

  void _requestDownload(String fielurl) async {
    var b = await _checkPermission();
    if (b) {
      String p = await _findLocalPath();
      var id = await FlutterDownloader.enqueue(
          url: fielurl,
          headers: {"auth": "test_for_sql_encoding"},
          savedDir: p,
          showNotification: true,
          openFileFromNotification: true);

      FlutterDownloader.registerCallback(
              (String id, DownloadTaskStatus status, int progress) {
            //print("$id | ${status.toString()} | $progress");
            _isDownloaderRunning = true;
            if (status == DownloadTaskStatus.canceled ||
                status == DownloadTaskStatus.complete ||
                status == DownloadTaskStatus.failed) {
              _isDownloaderRunning = false;
            }
          });
      showSnackBar("Download starting...", color: Colors.green);
    }
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    final savedDir = Directory(directory.path + '/Download');
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return savedDir.path;
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
