import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/announcement/select_audience.dart';
import 'package:click_campus_admin/views/announcement/selected_audience.dart';
import 'package:click_campus_admin/views/attendance/students/mark_attendance/speech_to_text_dialog.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddSms extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddSmsState();
  }
}

class AddSmsState extends State<AddSms> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _didGetData = false;

  final _contentTextController = TextEditingController();
  List<dynamic> _msgSenders = <dynamic>[];
  Map<String, dynamic> _selectedMsgSender;

  SelectedAudience _selectedAudience;

  final List<Widget> chips = [];
  bool veryHighPriority = false;

  void _getMsgSenders() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getMsgSendersRoute(await AppData().getSchoolUrl()),
        body: {
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
                content: Text(
                    "Are you sure you want to post this announcement, You account will be charged for SMS credits used ! "),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendMessageFinally();
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
        showSnackBar("Please select auidence for this message",
            color: Colors.orange);
      }
    }
  }

  Future<void> _sendMessageFinally() async {
    showProgressDialog();
    var loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        veryHighPriority
            ? GConstants.getHighPrioritySmsRoute(await AppData().getSchoolUrl())
            : GConstants.getLowPrioritySmsRoute(await AppData().getSchoolUrl()),
        body: {
          'sender_id': _selectedMsgSender['id'],
          'students': json.encode(_selectedAudience.checkedStudents.toList()),
          'staff': json.encode(_selectedAudience.checkedStaff.toList()),
          'message': _contentTextController.text,
          'login_id': loginId.toString(),
          'attachments': '',
          'active_session': sessionToken,
        });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _contentTextController.text = '';
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
                                    icon: Icon(
                                      Icons.mic,
                                      size: 44,
                                    ),
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            SpeechToTextDialog(),
                                      ).then((onValue) {
                                        if (onValue[0] == false) {
                                          showSnackBar(
                                              "Microphone permission not granted");
                                        } else if (onValue[1]
                                                .toString()
                                                .length >
                                            0) {
                                          _contentTextController.text =
                                              onValue[1];
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
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: <Widget>[
                                Text("Priority"),
                                SizedBox(
                                  child: Row(
                                    children: <Widget>[
                                      Radio<bool>(
                                        value: false,
                                        groupValue: veryHighPriority,
                                        onChanged: (bool value) {
                                          setState(() {
                                            veryHighPriority = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "High",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      Radio<bool>(
                                        value: true,
                                        groupValue: veryHighPriority,
                                        onChanged: (bool value) {
                                          setState(() {
                                            veryHighPriority = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        "Very High",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ],
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
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
                      padding: EdgeInsets.fromLTRB(8, 20, 0, 10),
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
