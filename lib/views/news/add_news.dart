import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/utils/camera.dart';
import 'package:click_campus_admin/utils/s3_upload.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';

class AddNews extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddNewsState();
  }
}

class AddNewsState extends State<AddNews> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _titleTextController = TextEditingController();
  final _contentTextController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  String fromDate =
  DateFormat().addPattern("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  String toDate =
  DateFormat().addPattern("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  bool isDateSelected = false;
  List<dynamic> _typeList = [];
  Map<String, dynamic> _selectedType;

  List<dynamic> _classData = [];
  bool _firstRunRoutineRan = false;

  Map<String, dynamic> _selectedClass;
  List<dynamic> _sectionsData = [];
  List<dynamic> _selectedSections = [];

  List<dynamic> _subjectsData = [];
  Map<String, dynamic> _selectedSubject;

  List<String> _selectedFilesPaths = [];
  List<Map<String, String>> _filePathsToUpload = [];

  String mSelectedDate =
  DateFormat().addPattern("dd-MM-yyyy").format(DateTime.now());
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
        _typeList.add({"type": "normal", "value": "Normal News"});
        _typeList.add({"type": "flash", "value": "Flash News"});
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add News"),
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
                            padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'News Title',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextField(
                                    onChanged: (value) {},
                                    autofocus: false,
                                    controller: _titleTextController,
                                    enabled: true,
                                    decoration: new InputDecoration(
                                      hintText: "Enter News Title",
                                      border: new OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'News Content',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                            padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextField(
                                    onChanged: (value) {},
                                    autofocus: false,
                                    controller: _contentTextController,
                                    enabled: true,
                                    decoration: new InputDecoration(
                                      hintText: "Enter News Content",
                                      border: new OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                            padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: new Text(
                                      'From Date',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    child: new Text(
                                      'To Date',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                              ],
                            )),
                        Padding(
                            padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        isDateSelected = true;
                                        final DateTime picked =
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          //firstDate: DateTime.now().subtract(Duration(days: 30)),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(Duration(days: 30)),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            fromDate = DateFormat()
                                                .addPattern(
                                                "yyyy-MM-dd HH:mm:ss")
                                                .format(picked);

                                            DateTime date =
                                            DateTime.parse(fromDate);
                                            ;
                                            final customDateFormat =
                                            new DateFormat('yyyy-MM-dd');
                                            var mDate =
                                            customDateFormat.format(date);
                                            //widget._fromDate = mDate;
                                            fromDateController.text = mDate;
                                          });
                                        }
                                      },
                                      child: TextField(
                                        onChanged: (value) {
                                          //widget._fromDate = value;
                                        },
                                        controller: fromDateController,
                                        enabled: false,
                                        decoration: new InputDecoration(
                                          hintText: "DD/MM/YYYY",
                                          border: new OutlineInputBorder(
                                            borderRadius: const BorderRadius
                                                .all(
                                              const Radius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 2.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        isDateSelected = true;
                                        final DateTime picked =
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          //firstDate: DateTime.now().subtract(Duration(days: 30)),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(Duration(days: 30)),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            toDate = DateFormat()
                                                .addPattern(
                                                "yyyy-MM-dd HH:mm:ss")
                                                .format(picked);

                                            DateTime date =
                                            DateTime.parse(fromDate);
                                            ;
                                            final customDateFormat =
                                            new DateFormat('yyyy-MM-dd');
                                            var mDate =
                                            customDateFormat.format(date);
                                            //widget._fromDate = mDate;
                                            toDateController.text = mDate;
                                          });
                                        }
                                      },
                                      child: TextField(
                                        onChanged: (value) {
                                          //widget._fromDate = value;
                                        },
                                        controller: toDateController,
                                        enabled: false,
                                        decoration: new InputDecoration(
                                          hintText: "DD/MM/YYYY",
                                          border: new OutlineInputBorder(
                                            borderRadius: const BorderRadius
                                                .all(
                                              const Radius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                              ],
                            )),
                        Padding(
                            padding:
                            EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      'Type',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Padding(
                          padding:
                          EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.only(left: 15.0,
                                right: 10),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.grey,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            child: DropdownButton<dynamic>(
                              underline: SizedBox(),
                              items: _typeList
                                  .map((b) =>
                                  DropdownMenuItem<dynamic>(
                                    child: Text(
                                      b['value'],
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    value: b,
                                  ))
                                  .toList(),
                              onChanged: (b) {
                                if (b == _selectedType) {
                                  return;
                                }

                                setState(() {
                                  _selectedType = b;
                                });
                              },
                              hint: Text(
                                'Select News Type',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              isExpanded: true,
                              value: _selectedType,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _selectedType!=null && _selectedType['type'] == 'normal'? true :false,
                          child: Padding(
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
                                    itemBuilder: (context) =>
                                    [
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text("Capture an image"),
                                      ),
                                      PopupMenuItem(
                                        value: 2,
                                        child: Text("Select a image"),
                                      ),
                                    ],
                                    onSelected: (v) {
                                      if (v == 1) {
                                        _getImage();
                                      } else {
                                        _openFileExplorer();
                                      }
                                    },
                                  ),
                                  height: 35,
                                ),
                                new FlatButton(
                                  child: new Text(
                                    "Attachment",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  disabledColor: Colors.indigo,
                                  color: Colors.indigo,
                                  onPressed: () {

                                  },
                                ),
                              ]),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                ),
              )),
          Align(
            child: Container(
              child: _getActionButtons(),
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
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0, bottom: 20),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  height: 50,
                  child: new RaisedButton(
                    child: new Text("Add News"),
                    textColor: Colors.white,
                    color: Colors.green,
                    onPressed: () async {
                      if (_selectedType != null &&
                          _selectedType['type'] == "normal" &&
                          _titleTextController.text.isEmpty) {
                        StateHelper().showShortToast(
                            context, "Please enter news title");
                      } else if (_selectedType != null &&
                          _selectedType['type'] == "normal" &&
                          _contentTextController.text.isEmpty) {
                        StateHelper().showShortToast(
                            context, "Please enter news content");
                      } else if (_selectedType == null) {
                        StateHelper().showShortToast(
                            context, "Please select news type");
                      } else if (_selectedType['type'] == "normal" && _selectedFilesPaths.length==0) {
                        StateHelper().showShortToast(
                            context, "Please select attachment");
                      }  else if (_titleTextController.text.isEmpty) {
                        StateHelper()
                            .showShortToast(context, "Please enter title");
                      } else {
                        if(_selectedFilesPaths.length>0){
                          String attachment = await _uploadAttachments();
                          if (attachment != "") {
                            addNews(attachment);
                          }
                        }else{
                          addNews("");
                        }

                      }
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  height: 50,
                  child: new RaisedButton(
                    child: new Text("Cancel"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        //FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  )),
            ),
            flex: 2,
          ),
        ],
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



  void addNews(String attachment) async {
    showProgressDialog();

    String sessionToken = await AppData().getSessionToken();
    int userLoginId = await AppData().getUserLoginId();
    if (activeSession == null || activeSession.sessionId == null) {
      showShortToast(context, "Please set active session and try again");
      return;
    }

    Map data = {
      'active_session': sessionToken,
      'session_id': activeSession.sessionId.toString(),
      'title': _titleTextController.text,
      'news': _contentTextController.text,
      'date_from': fromDate.toString(),
      'date_to': toDate.toString(),
      'news_type': _selectedType['type'],

    };

    if(_selectedType['type']=="normal"){
      data.putIfAbsent('filesupload', () => attachment);
    }
    if(_selectedType['type']=="normal"){
      data.putIfAbsent('media_type', () => 'image');
    }

    debugPrint("${data}");

    var allClassesResponse =
    await http.post(
        GConstants.getAddNewsRoute(await AppData().getSchoolUrl()), body: data);

    debugPrint("${allClassesResponse.request} : ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      debugPrint(allClassesResponse.body);
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("success")) {
        if (allClassesObject["success"] == true) {
          hideProgressDialog();
          showSnackBar("News Added Successfully", color: Colors.indigo);
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

  Future _getImage() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext buildContext) {
          return TakePictureScreen(
            camera: firstCamera,
          );
        })).then((image) {
      setState(() {
        _selectedFilesPaths.clear();
        _selectedFilesPaths.add(image.path);
        //print(_selectedFilesPaths);
      });
    });
  }

  void _openFileExplorer() async {
    var path = await FilePicker.getFilePath(type: FileType.image);

    if (path != null && isValidFile(path)) {
      setState(() {
        _selectedFilesPaths.clear();
        _selectedFilesPaths.add(path);
        //print(_selectedFilesPaths);
      });
    } else {
      showSnackBar("Invalid file, Only image is allowed");
    }
  }

  bool isValidFile(String path) {
    String mimeType = mime(path);

    if (mimeType.contains("image")) {
      return true;
    } else if (mimeType.contains("video")) {
      return false;
    } else if (mimeType.contains("audio")) {
      return false;
    } else if (mimeType.contains("pdf")) {
      return false;
    }
    return false;
  }
}
