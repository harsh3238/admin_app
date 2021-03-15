import 'dart:convert';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/utils/s3_upload.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/util_widgets/custom_drop_down.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';

class AddHomework extends StatefulWidget {
  final List<Map<String, dynamic>> _classSections;

  AddHomework(this._classSections);

  @override
  State<StatefulWidget> createState() {
    return AddHomeworkState();
  }
}

class AddHomeworkState extends State<AddHomework> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  final _titleTextController = TextEditingController();
  final _contentTextController = TextEditingController();

  List<String> _selectedFilesPaths = [];
  List<Map<String, String>> _filePathsToUpload = [];

  bool _firstRunRoutineRan = false;

  List<dynamic> _subjectsData = [];
  Map<String, dynamic> _selectedSubject;

  void _getSubjects() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var subjectsResponse = await http.post(
        GConstants.getHomeworkSubjectsRoute(await AppData().getSchoolUrl()),
        body: {
          'class_ids': json.encode(widget._classSections),
          'active_session': sessionToken,
        });

    //print(subjectsResponse.body);

    if (subjectsResponse.statusCode == 200) {
      Map subjectsObject = json.decode(subjectsResponse.body);
      if (subjectsObject.containsKey("status")) {
        if (subjectsObject["status"] == "success") {
          _subjectsData = subjectsObject['data'];
          setState(() {});
          hideProgressDialog();
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(subjectsObject["message"]);
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

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _selectedFilesPaths.add(image.path);
      //print(_selectedFilesPaths);
    });
  }

  void _openFileExplorer() async {
    var path = await FilePicker.getFilePath(type: FileType.any);

    if (path != null && isValidFile(path)) {
      setState(() {
        _selectedFilesPaths.add(path);
        //print(_selectedFilesPaths);
      });
    } else {
      showSnackBar("Invalid file");
    }
  }

  bool isValidFile(String path) {
    String mimeType = mime(path);

    if (mimeType.contains("image")) {
      return true;
    } else if (mimeType.contains("video")) {
      return true;
    } else if (mimeType.contains("audio")) {
      return true;
    } else if (mimeType.contains("pdf")) {
      return true;
    }

    return false;
  }

  Future<bool> _uploadAttachments() async {
    for (int i = 0; i < _selectedFilesPaths.length; i++) {
      var filePath = _selectedFilesPaths[i];
      String mimeType = mime(filePath);

      String extension;
      int lastDot = filePath.lastIndexOf('.', filePath.length - 1);
      if (lastDot != -1) {
        extension = filePath.substring(lastDot + 1);
      }

      var fileNameNew =
          "${DateTime.now().millisecondsSinceEpoch.toString()}.$extension";
      var rs = await s3Upload(File(_selectedFilesPaths[i]), fileNameNew);
      if (!rs) {
        showSnackBar("Could not upload files");
        return false;
      }

      Map<String, String> map = Map();

      if (mimeType.contains("image")) {
        map['media_type'] = "image";
      } else if (mimeType.contains("video")) {
        map['media_type'] = "video";
      } else if (mimeType.contains("audio")) {
        map['media_type'] = "audio";
      } else if (mimeType.contains("pdf")) {
        map['media_type'] = "pdf";
      }

      map['url'] =
          "https://stucarecloud.s3.ap-south-1.amazonaws.com/uploaded/$fileNameNew";
      _filePathsToUpload.add(map);
    }

    return true;
  }

  void _homeworkRoutine() async {
    showProgressDialog();

    if (_selectedFilesPaths.length > 0) {
      var shouldGoAhead = await _uploadAttachments();
      if (shouldGoAhead) {
        await _putHomework();
      } else {
        hideProgressDialog();
      }
    } else {
      _putHomework();
    }
  }

  Future<void> _putHomework() async {
    var loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getPutHomeworkRoute(await AppData().getSchoolUrl()),
        body: {
          'session_id': activeSession.sessionId.toString(),
          'class_sections': json.encode(widget._classSections),
          'title': _titleTextController.text,
          'content': _contentTextController.text,
          'subject_id': _selectedSubject['id'].toString(),
          'start_date': DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
          'submission_date':
              DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
          'login_row_id': loginId.toString(),
          'attachments': json.encode(_filePathsToUpload),
          'active_session': sessionToken,
        });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _titleTextController.text = '';
          _contentTextController.text = '';
          _selectedFilesPaths.clear();
          _filePathsToUpload.clear();
          showSnackBar('Homework added successfully', color: Colors.green);
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
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 200), () async {
        _getSubjects();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add Homework"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.indigo,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: CustomInputDropdown(
                            labelText: "From",
                            valueText: DateFormat.yMMMd().format(dateFrom),
                            valueStyle: Theme.of(context)
                                .textTheme
                                .title
                                .apply(color: Colors.white),
                            onPressed: () async {
                              DateTime firstDate = DateTime.now()
                                  .subtract(Duration(minutes: 10));
                              final DateTime picked = await showDatePicker(
                                context: context,
                                initialDate: dateFrom,
                                firstDate: firstDate,
                                lastDate:
                                    DateTime.now().add(Duration(days: 30)),
                              );
                              if (picked != null)
                                setState(() {
                                  dateFrom = picked;
                                });
                            },
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          flex: 4,
                          child: CustomInputDropdown(
                            labelText: "Submission Date",
                            valueText: DateFormat.yMMMd().format(dateTo),
                            valueStyle: Theme.of(context).textTheme.title.apply(
                                  color: Colors.white,
                                ),
                            onPressed: () async {
                              DateTime initalDate = DateTime.now()
                                  .subtract(Duration(minutes: 10));
                              final DateTime picked = await showDatePicker(
                                context: context,
                                initialDate: dateTo,
                                firstDate: initalDate,
                                lastDate:
                                    DateTime.now().add(Duration(days: 30)),
                              );
                              if (picked != null)
                                setState(() {
                                  dateTo = picked;
                                });
                            },
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Theme(
                              data: Theme.of(context)
                                  .copyWith(brightness: Brightness.dark),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Map<String, dynamic>>(
                                items: _subjectsData
                                    .map((b) =>
                                        DropdownMenuItem<Map<String, dynamic>>(
                                          child: Text(
                                            "${b['subject_name']} (${b['class_name']})",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          value: b,
                                        ))
                                    .toList(),
                                onChanged: (b) {
                                  setState(() {
                                    _selectedSubject = b;
                                  });
                                },
                                hint: Text(
                                  'Select Subject',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                value: _selectedSubject,
                              ))),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    )
                  ],
                ),
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 20, 8, 8),
                        child: TextFormField(
                          enabled: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), hintText: "Title"),
                          maxLines: 1,
                          validator: (txt) {
                            if (txt.length <= 0) {
                              return "Please enter title";
                            }
                            return null;
                          },
                          controller: _titleTextController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 20, 8, 8),
                        child: TextFormField(
                          enabled: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter content here"),
                          maxLines: 6,
                          maxLength: 400,
                          validator: (txt) {
                            if (txt.length <= 0) {
                              return "Please enter content";
                            }
                            return null;
                          },
                          controller: _contentTextController,
                        ),
                      )
                    ],
                  )),
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
                              showMultiAttachmentDialog(_selectedFilesPaths);
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
                            child: Text("Capture an image"),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text("Select a file"),
                          ),
                        ],
                        onSelected: (v) {
                          if (v == 1) {
                            getImage();
                          } else {
                            _openFileExplorer();
                          }
                        },
                      ),
                      height: 35,
                    ),
                    new FlatButton(
                      child: new Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      disabledColor: Colors.indigo,
                      color: Colors.indigo,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          if(_selectedSubject != null){
                            _homeworkRoutine();
                          }else{
                            showSnackBar("Please select subject", color: Colors.orange);
                          }

                        }
                      },
                    ),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  List<Widget> getAttachmentWidgets(List<String> attachments) {
    List<Widget> widgets = List();
    for (int i = 0; i < attachments.length; i++) {
      widgets.add(SimpleDialogOption(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Text(
                "Attachment ${i + 1}",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.delete),
                  iconSize: 22,
                  onPressed: () {
                    _selectedFilesPaths.removeAt(i);
                    Navigator.pop(context);
                  },
                ),
                height: 35,
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ));
    }
    return widgets;
  }

  void showMultiAttachmentDialog(List<String> attachments) {
    var dialog = SimpleDialog(
      title: const Text('Please Select Attachment'),
      children: getAttachmentWidgets(attachments),
    );
    showDialog(
            context: context,
            builder: (BuildContext context) => dialog,
            barrierDismissible: false)
        .then((value) {
      setState(() {});
    });
  }
}
