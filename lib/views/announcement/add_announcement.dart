import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/utils/s3_upload.dart';
import 'package:click_campus_admin/views/announcement/select_audience.dart';
import 'package:click_campus_admin/views/announcement/selected_audience.dart';
import 'package:click_campus_admin/views/attendance/students/mark_attendance/speech_to_text_dialog.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';

class AddAnnouncement extends StatefulWidget {
  AddAnnouncement();

  @override
  State<StatefulWidget> createState() {
    return AddAnnouncementState();
  }
}

class AddAnnouncementState extends State<AddAnnouncement> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _didGetData = false;

  final _contentTextController = TextEditingController();
  List<dynamic> _msgSenders = <dynamic>[];
  Map<String, dynamic> _selectedMsgSender;

  List<String> _selectedFilesPaths = [];
  List<Map<String, String>> _filePathsToUpload = [];

  SelectedAudience _selectedAudience;

  void _getMsgSenders() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http
        .post(GConstants.getMsgSendersRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _msgSenders = modulesResponseObject['data'];
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

  final List<Widget> chips = [];

  Future getImageFromCamera() async {
    if (_selectedFilesPaths.length == 3) {
      showSnackBar("Only 3 attachmetns allowed");
      return;
    }
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _selectedFilesPaths.add(image.path);
      //print(_selectedFilesPaths);
    });
  }

  Future getImageFromGallery() async {
    if (_selectedFilesPaths.length == 3) {
      showSnackBar("Only 3 attachmetns allowed");
      return;
    }
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedFilesPaths.add(image.path);
      //print(_selectedFilesPaths);
    });
  }

  void _openFileExplorer() async {
    if (_selectedFilesPaths.length == 3) {
      showSnackBar("Only 3 attachmetns allowed");
      return;
    }
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

  void _validateSubmit() {
    if (_formKey.currentState.validate()) {
      if (_selectedMsgSender == null) {
        showSnackBar("Please select a sender", color: Colors.orange);
        return;
      }

      if (_selectedAudience != null &&
          (_selectedAudience.checkedStaff.length > 0 ||
              _selectedAudience.checkedStudents.length > 0)) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Post Announcement?"),
                content:
                    Text("Are you sure you want to post this announcement ? "),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendMessage();
                    },
                    child: Text("Okay"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  )
                ],
              );
            });
      } else {
        showSnackBar("Please select audience for this message",
            color: Colors.orange);
      }
    }
  }

  void _sendMessage() async {
    if (_selectedFilesPaths.length > 0) {
      showProgressDialog();
      var shouldGoAhead = await _uploadAttachments();
      if (shouldGoAhead) {
        await _sendMessageFinally();
      } else {
        hideProgressDialog();
      }
    } else {
      showProgressDialog();
      _sendMessageFinally();
    }
  }

  Future<void> _sendMessageFinally() async {
    var loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    Map requestBody = {
      'sender_id': _selectedMsgSender['id'],
      'students': json.encode(_selectedAudience.checkedStudents.toList()),
      'staff': json.encode(_selectedAudience.checkedStaff.toList()),
      'message': _contentTextController.text,
      'login_id': loginId.toString(),
      'attachments': json.encode(_filePathsToUpload),
      'active_session': sessionToken,
    };

    log("${requestBody}");

    var allClassesResponse = await http.post(
        GConstants.getSendMediaMsgRoute(await AppData().getSchoolUrl()),
        body: requestBody);

    log("${allClassesResponse.request}:${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _contentTextController.text = '';
          _selectedFilesPaths.clear();
          _filePathsToUpload.clear();
          _selectedMsgSender = null;
          _selectedAudience = null;
          chips.clear();
          showSnackBar('Message sent successfully', color: Colors.green);
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

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getMsgSenders();
      });
    }
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add Annoucement"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Write here"),
                                      maxLines: 8,
                                      maxLength: 500,
                                      validator: (txt) {
                                        if (txt.length <= 0) {
                                          return "Please enter content";
                                        }
                                        return null;
                                      },
                                      controller: _contentTextController,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.mic, size: 44,),
                                      padding: EdgeInsets.all(0),
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              SpeechToTextDialog(),
                                        ).then((onValue) {
                                          if (onValue[0] == false) {
                                            showSnackBar(
                                                "Microphone permission not granted");
                                          } else if (onValue[1].toString().length > 0) {
                                            _contentTextController.text = onValue[1];
                                          }
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                              margin: EdgeInsets.all(6),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Add Attachment",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    "Maximum Attachment : 3",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 10, 8, 8),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(
                                        Icons.image,
                                        size: 38,
                                        color: Colors.indigo,
                                      ),
                                      onPressed: () {
                                        getImageFromCamera();
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        Icons.video_library,
                                        size: 38,
                                        color: Colors.indigo,
                                      ),
                                      onPressed: () {
                                        getImageFromGallery();
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        Icons.insert_drive_file,
                                        size: 38,
                                        color: Colors.indigo,
                                      ),
                                      onPressed: () {
                                        _openFileExplorer();
                                      })
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                              ),
                            )
                          ],
                        )),
                    (_selectedFilesPaths.length > 0)
                        ? SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(8, 24, 8, 24),
                                  child: Text(
                                    "Attachments (${_selectedFilesPaths.length})",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                                margin: EdgeInsets.all(8),
                              ),
                              onTap: () {
                                showMultiAttachmentDialog(_selectedFilesPaths);
                              },
                            ),
                          )
                        : Container(
                            width: 0,
                          ),
                    Card(
                      child: DropdownButtonFormField(
                        items: _msgSenders.map((v) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                              child: Text(v['name']), value: v);
                        }).toList(),
                        value: _selectedMsgSender,
                        onChanged: (nV) {
                          setState(() {
                            _selectedMsgSender = nV;
                          });
                        },
                        decoration: InputDecoration(
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 8, 12),
                        ),
                        hint: Text("Select Sender"),
                      ),
                      margin: EdgeInsets.all(8),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 10, 0, 10),
                      child: Text(
                        "Audience",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    Wrap(
                      children: chips.map<Widget>((Widget chip) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: chip,
                        );
                      }).toList(),
                    ),
                    GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 20, 8, 20),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Select Audience",
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down)
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                        margin: EdgeInsets.all(8),
                      ),
                      onTap: () async {
                        await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return SelectAudience();
                                    },
                                    fullscreenDialog: true))
                            .then((rs) {
                          _selectedAudience = rs as SelectedAudience;
                          chips.clear();
                          if (_selectedAudience.areAllStaffSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text('All Staff')));
                          } else if (_selectedAudience.oneDepartmentSelected) {
                            var depName =
                                _selectedAudience.selectedDepartments[0];
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text(depName)));
                          } else if (_selectedAudience
                              .multipleDepartmentSelected) {
                            _selectedAudience.selectedDepartments
                                .forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.oneStaffSelected) {
                            _selectedAudience.selectedStaff.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.multipleStaffSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text("Multiple Staff")));
                          }

                          if (_selectedAudience.areAllStudentsSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text('All Students')));
                          } else if (_selectedAudience.oneClassSelected) {
                            _selectedAudience.selectedClasses.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.multipleClassSelected) {
                            _selectedAudience.selectedClasses.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.oneSectionSelected) {
                            _selectedAudience.selectedSections.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience
                              .multipleSectionSelected) {
                            _selectedAudience.selectedSections.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.oneStudentSelected) {
                            _selectedAudience.selectedStudents.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience
                              .multipleStudentSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text("Multiple Students")));
                          }
                        });
                        setState(() {});
                      },
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      _validateSubmit();
                    },
                    color: Colors.indigo,
                    child: Text(
                      "Post Now",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {},
                    color: Colors.indigo,
                    child: Text(
                      "Post Sheduled",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          )
        ],
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }
}
