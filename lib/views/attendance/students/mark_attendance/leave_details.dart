import 'dart:convert';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/utils/s3_upload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../state_helper.dart';

class AttLeaveDetails extends StatefulWidget {
  final String stucareId, date;

  AttLeaveDetails(this.stucareId, this.date);

  @override
  State<StatefulWidget> createState() {
    return LeaveState();
  }
}

class LeaveState extends State<AttLeaveDetails> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _leavesData = [];

  List<Map<String, String>> contentData = [
    {"reason": "Reason"},
    {"from_date": "From Date"},
    {"to_date": "To Date"},
    {"applied_timestamp": "Date Applied"},
    {"leave_status": "Status"},
    {"attachment_path": "Attachment"},
  ];

  void _getLeave() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getAttLeaveDetailsRoute(await AppData().getSchoolUrl()),
        body: {
          "stucare_id": widget.stucareId,
          'date': widget.date,
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _leavesData = modulesResponseObject['data'];
          hideProgressDialog();
          if (_leavesData.length > 0) {
            setState(() {});
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (b) =>
                        ApplyLeaveDialog(null, widget.stucareId))).then((b) {
              if (b) {
                showSnackBar("Leave added successfully", color: Colors.green);
                _getLeave();
              }
            });
          }
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

  _launchURL(String theUrl) async {
    if (await canLaunch(theUrl)) {
      await launch(theUrl);
    } else {
      throw 'Cannot open browser for this $theUrl';
    }
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
      Future.delayed(Duration(milliseconds: 500), () async {
        _getLeave();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Leave Detail"),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(8),
        separatorBuilder: (context, position) {
          return Container(
            height: 8,
          );
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, _leavesData[index]["id"]);
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "Leave No. ${_leavesData[index]["id"]}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        )
                      ],
                    ),
                    width: double.infinity,
                    color: Colors.grey.shade900,
                  ),
                  contentTable(index)
                ],
              ),
            ),
          );
        },
        itemCount: _leavesData.length,
      ),
    );
  }

  Widget contentTable(index) => Padding(
        padding: EdgeInsets.all(0),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
          },
          children: <TableRow>[]
            ..addAll(contentData.map<TableRow>((Map<String, String> d) {
              var theKey = d.keys.toList()[0];
              return _buildItemRow(d[theKey], _leavesData[index][theKey]);
            })),
        ),
      );

  TableRow _buildItemRow(String left, String right) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            (left == "Attachment")
                ? (right != null && right.trim().length > 0)
                    ? "Tap To See"
                    : "No File"
                : right,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class ApplyLeaveDialog extends StatefulWidget {
  final Map<String, dynamic> editLeaveData;
  final String stucareId;

  ApplyLeaveDialog(this.editLeaveData, this.stucareId);

  @override
  State<StatefulWidget> createState() {
    return ApplyLeaveDialogState();
  }
}

class ApplyLeaveDialogState extends State<ApplyLeaveDialog> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _reasonTextController;

  DateTime initialDateFrom = DateTime.now();
  DateTime initialDateTo = DateTime.now();
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  String _selectedFilesPath;
  List<Map<String, String>> _filePathsToUpload = [];

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _selectedFilesPath = image.path;
      //print(_selectedFilesPath);
    });
  }

  void _openFileExplorer() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      var dialog = SimpleDialog(
        title: const Text('Please Select Option'),
        children: [
          SimpleDialogOption(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Select Photo/Video",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 0);
            },
          ),
          SimpleDialogOption(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Select Document",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 1);
            },
          )
        ],
      );
      showDialog(context: context, builder: (BuildContext context) => dialog)
          .then((value) async {
        if (value == 0) {
          var image = await ImagePicker.pickImage(source: ImageSource.gallery);

          setState(() {
            _selectedFilesPath = image.path;
            //print(_selectedFilesPath);
          });
        } else {
          var path = await FilePicker.getFilePath(type: FileType.any);

          if (path != null && isValidFile(path)) {
            setState(() {
              _selectedFilesPath = path;
              //print(_selectedFilesPath);
            });
          } else {
            showSnackBar("Invalid file");
          }
        }
      });
    } else {
      var path = await FilePicker.getFilePath(type: FileType.any);

      if (path != null && isValidFile(path)) {
        setState(() {
          _selectedFilesPath = path;
          //print(_selectedFilesPath);
        });
      } else {
        showSnackBar("Invalid file");
      }
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

  void _addLeave() async {
    showProgressDialog();
    if (_selectedFilesPath != null) {
      var shouldGoAhead = (_selectedFilesPath.contains("s3"))
          ? true
          : await _uploadAttachments();
      if (shouldGoAhead) {
        await _addLeaveFinally();
      } else {
        hideProgressDialog();
      }
    } else {
      await _addLeaveFinally();
    }
  }

  Future<bool> _uploadAttachments() async {
    _filePathsToUpload.clear();
    var filePath = _selectedFilesPath;
    String mimeType = mime(filePath);

    String extension;
    int lastDot = filePath.lastIndexOf('.', filePath.length - 1);
    if (lastDot != -1) {
      extension = filePath.substring(lastDot + 1);
    }

    var fileNameNew =
        "${DateTime.now().millisecondsSinceEpoch.toString()}.$extension";
    var rs = await s3Upload(File(_selectedFilesPath), fileNameNew);
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

    return true;
  }

  Future<void> _addLeaveFinally() async {
    int userLoginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getAddStuLeaveRoute(await AppData().getSchoolUrl()),
        body: {
          "leave_id":
              widget.editLeaveData != null ? widget.editLeaveData["id"] : "",
          'session_id': activeSession.sessionId.toString(),
          'stucare_id': widget.stucareId,
          'reason': _reasonTextController.text,
          'from_date': DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
          'to_date': DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
          'teacher_id': userLoginId.toString(),
          'attachment':
              _filePathsToUpload.length > 0 ? _filePathsToUpload[0]['url'] : "",
          'attachment_mime': _filePathsToUpload.length > 0
              ? _filePathsToUpload[0]['media_type']
              : "",
          'active_session': sessionToken,
        });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          hideProgressDialog();
          Navigator.pop(context, true);
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
    _reasonTextController = widget.editLeaveData != null
        ? TextEditingController(text: widget.editLeaveData["reason"])
        : TextEditingController();
    if (widget.editLeaveData != null) {
      _selectedFilesPath = widget.editLeaveData["attachment_path"];
    }

    if (_selectedFilesPath != null) {
      Map<String, String> map = Map();
      map['media_type'] = widget.editLeaveData["attachment_mime"];
      map['url'] = widget.editLeaveData["attachment_path"];
      _filePathsToUpload.add(map);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Apply for Leave"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.indigo,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: _InputDropdown(
                          labelText: "From",
                          valueText: widget.editLeaveData != null
                              ? DateFormat.yMMMd().format(DateTime.parse(
                                  widget.editLeaveData["from_date"]))
                              : DateFormat.yMMMd().format(dateFrom),
                          valueStyle: Theme.of(context)
                              .textTheme
                              .title
                              .apply(color: Colors.white),
                          onPressed: () async {
                            DateTime firstDate =
                                DateTime.now().subtract(Duration(minutes: 10));
                            final DateTime picked = await showDatePicker(
                              context: context,
                              initialDate: dateFrom,
                              firstDate: firstDate,
                              lastDate: DateTime.now().add(Duration(days: 30)),
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
                        child: _InputDropdown(
                          labelText: "To",
                          valueText: widget.editLeaveData != null
                              ? DateFormat.yMMMd().format(DateTime.parse(
                                  widget.editLeaveData["to_date"]))
                              : DateFormat.yMMMd().format(dateTo),
                          valueStyle: Theme.of(context).textTheme.title.apply(
                                color: Colors.white,
                              ),
                          onPressed: () async {
                            DateTime initalDate =
                                DateTime.now().subtract(Duration(minutes: 10));
                            final DateTime picked = await showDatePicker(
                              context: context,
                              initialDate: dateTo,
                              firstDate: initalDate,
                              lastDate: DateTime.now().add(Duration(days: 30)),
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
                ),
              ),
              Form(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: TextFormField(
                    enabled: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter reason for leave"),
                    maxLines: 6,
                    maxLength: 200,
                    validator: (txt) {
                      if (txt.length <= 0) {
                        return "Please enter reason";
                      }
                      return null;
                    },
                    controller: _reasonTextController,
                  ),
                ),
                key: _formKey,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: ButtonTheme(
                  minWidth: 44.0,
                  height: 35,
                  padding: new EdgeInsets.all(6),
                  child: new ButtonBar(children: <Widget>[
                    _selectedFilesPath != null
                        ? Container(
                            child: Text(
                              "Attached file",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          )
                        : Container(
                            height: 0,
                          ),
                    Container(
                      color: Colors.grey.shade400,
                      child: IconButton(
                        icon: Icon(Icons.add_a_photo),
                        iconSize: 18,
                        onPressed: () {
                          getImage();
                        },
                      ),
                      height: 35,
                    ),
                    Container(
                      color: Colors.grey.shade400,
                      child: IconButton(
                        icon: Icon(Icons.attach_file),
                        iconSize: 18,
                        onPressed: () {
                          _openFileExplorer();
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
                          _addLeave();
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
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown(
      {Key key,
      this.child,
      this.labelText,
      this.valueText,
      this.valueStyle,
      this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.white)),
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
