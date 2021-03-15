import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/message/audio_player_dialog.dart';
import 'package:click_campus_admin/views/message/msg_video_player.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/util_widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state_helper.dart';

class LeaveTeacher extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LeaveTeacherState();
  }
}

class LeaveTeacherState extends State<LeaveTeacher> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _leavesData = [];

  List<String> contentData = [
    "Reason",
    "Date From",
    "Date To",
    "Date Applied",
    "Status"
  ];

  void _getLeave() async {
    showProgressDialog();
    int loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStuLeaveRoute(await AppData().getSchoolUrl()),
        body: {
          'login_id': loginId.toString(),
          'active_session': sessionToken,
        });

    log("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _leavesData = modulesResponseObject['data'];
          if(_leavesData.length==0){
            StateHelper().showShortToast(context, "No Data Available");
          }
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

  void _changeLeaveStatus(String leaveId, String status) async {
    showProgressDialog();
    int loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStuLeaveChangeStatusRoute(await AppData().getSchoolUrl()),
        body: {
          'login_id': loginId.toString(),
          'leave_id': leaveId,
          'status': status,
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _leavesData = modulesResponseObject['data'];
          hideProgressDialog();
          _getLeave();
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
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 300), () async {
        _getLeave();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Applications"),
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
              if (_leavesData[index]["attachment_path"] != null &&
                  _leavesData[index]["attachment_path"]
                          .toString()
                          .trim()
                          .length >
                      0) {
                switch (_leavesData[index]["attachment_mime"]) {
                  case "image":
                    var photo =
                        Photo(assetName: _leavesData[index]["attachment_path"]);
                    Navigator.push(context, MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                      return Scaffold(
                        body: SizedBox.expand(
                          child: Hero(
                            tag: photo.tag,
                            child: GridPhotoViewer(photo: photo),
                          ),
                        ),
                      );
                    }));
                    break;
                  case "video":
                    Navigator.push(context, MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                      return VideoDemo(_leavesData[index]["attachment_path"]);
                    }));
                    break;
                  case "audio":
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AudioPlayerDialog(
                          _leavesData[index]["attachment_path"]),
                    );
                    break;
                  case "pdf":
                    _launchURL(_leavesData[index]["attachment_path"]);
                    break;
                }
              }
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Leave No. ${_leavesData[index]["id"]}",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        Text(
                          "IV-C",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        )
                      ],
                    ),
                    width: double.infinity,
                    color: Colors.grey.shade700,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                    child: Text(
                      _leavesData[index]["reason"],
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  (_leavesData[index]["attachment_path"] != null &&
                          _leavesData[index]["attachment_path"]
                                  .toString()
                                  .trim()
                                  .length >
                              0)
                      ? SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                                child: Text(
                                  "Has Attachment",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              color: Colors.grey.shade100,
                              elevation: 0,
                            ),
                          ),
                        )
                      : Container(
                          height: 0,
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                    TextSpan(text: "Student : "),
                                    TextSpan(
                                        text: _leavesData[index]
                                            ["student_name"],
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal))
                                  ]))),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                    TextSpan(text: "Leave Date : "),
                                    TextSpan(
                                        text:
                                            "${_leavesData[index]["from_date"]} to ${_leavesData[index]["to_date"]}",
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal))
                                  ]))),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                    TextSpan(text: "Applied at : "),
                                    TextSpan(
                                        text: DateFormat()
                                            .addPattern("dd-MMM 'at' hh:mm a")
                                            .format(DateTime.parse(
                                                _leavesData[index]
                                                    ["applied_timestamp"])),
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal))
                                  ]))),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 12, 8),
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                TextSpan(text: "Status :   "),
                                TextSpan(
                                    text: _leavesData[index]["leave_status"]
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        background: Paint()
                                          ..color = Colors.deepOrange
                                          ..strokeWidth = 14
                                          ..style = PaintingStyle.stroke
                                          ..strokeJoin = StrokeJoin.round))
                              ])))
                    ],
                  ),
                  (_leavesData[index]["leave_status"] == 'approved')
                      ? Container(
                          height: 8,
                        )
                      : Divider(
                          height: 8,
                        ),
                  (_leavesData[index]["leave_status"] == 'approved')
                      ? Container(
                          height: 0,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            (_leavesData[index]["leave_status"] == 'rejected')
                                ? Container(
                                    height: 40,
                                  )
                                : Padding(
                                    padding: EdgeInsets.all(8),
                                    child: ButtonTheme(
                                      minWidth: 60.0,
                                      height: 30,
                                      child: RaisedButton(
                                        onPressed: () {
                                          _changeLeaveStatus(
                                              _leavesData[index]["id"],
                                              "rejected");
                                        },
                                        child: Text(
                                          "Reject",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11),
                                        ),
                                        disabledColor: Colors.grey.shade400,
                                        color: Colors.grey.shade400,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: ButtonTheme(
                                  minWidth: 60.0,
                                  height: 30,
                                  child: RaisedButton(
                                    onPressed: () {
                                      _changeLeaveStatus(
                                          _leavesData[index]["id"], "approved");
                                    },
                                    child: Text(
                                      "Approve",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                    disabledColor: Colors.indigo,
                                    color: Colors.indigo,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ))
                          ],
                        )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          );
        },
        itemCount: _leavesData.length,
      ),
    );
  }

  _launchURL(String theUrl) async {
    if (await canLaunch(theUrl)) {
      await launch(theUrl);
    } else {
      throw 'Cannot open browser for this $theUrl';
    }
  }
}
