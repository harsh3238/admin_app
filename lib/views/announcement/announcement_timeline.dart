import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/announcement/announcement_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../state_helper.dart';
import 'fancy_fab.dart';

class Announcement extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AnnouncementState();
  }
}

class _AnnouncementState extends State<Announcement> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  int _msgFromApp = 0;

  List<Color> _colors = [
    Colors.red.shade50,
    Colors.blue.shade50,
    Colors.yellow.shade50,
    Colors.pink.shade50,
    Colors.lightBlue.shade50,
    Colors.green.shade50,
    Colors.deepOrange.shade50,
    Colors.lightGreen.shade50,
    Colors.teal.shade50,
    Colors.pink.shade50,
    Colors.purple.shade50,
    Colors.teal.shade50
  ];

  List<dynamic> _announcements = [];

  void _getAnnouncement() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getAnnouncementRoute(await AppData().getSchoolUrl()),
        body: {'last_id': "0", 'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _msgFromApp = int.parse(modulesResponseObject['msg_from_app']);
          _announcements = modulesResponseObject['data'];
          if (_announcements.length > 0) {
            _announcements.add(null);
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

  void _getAnnouncementNext(String lastId) async {
    var modulesResponse = await http.post(
        GConstants.getAnnouncementRoute(await AppData().getSchoolUrl()),
        body: {'last_id': lastId});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _msgFromApp = int.parse(modulesResponseObject['msg_from_app']);
          var data = modulesResponseObject['data'];
          if (data.length > 0) {
            _announcements.removeLast();
            _announcements.addAll(data);
            _announcements.add(null);
            setState(() {});
          } else {
            showSnackBar("No More Messages", color: Colors.black);
          }
          return null;
        } else {
          showSnackBar(modulesResponseObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
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
      Future.delayed(Duration(milliseconds: 100), () async {
        _getAnnouncement();
      });
    }
    return Scaffold(
      key: _scaffoldState,
      floatingActionButton: FancyFab(_msgFromApp),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) {
          int position = index % 10;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: _announcements[index] == null
                ? Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: ContinuousRectangleBorder(),
                    child: Center(
                      child: FlatButton(
                          onPressed: () {
                            _getAnnouncementNext(_announcements[index - 1]
                                    ['message_id']
                                .toString());
                          },
                          child: Text("Load More")),
                    ),
                  )
                : Container(
                    child: Card(
                      color: _colors[position],
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _announcements[index]['message_text']
                                              .toString()
                                              .length >
                                          0
                                      ? Expanded(
                                          child: Text(
                                            _announcements[index]
                                                ['message_text'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        )
                                      : Expanded(
                                          child: Card(
                                            child: Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    "Audio Message",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                  ),
                                                  Icon(
                                                    Icons.audiotrack,
                                                    color: Colors.grey,
                                                  )
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                              ),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                ],
                              ),
                              width: double.infinity,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                Text(_announcements[index]['sender_name'] ?? '',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14))
                              ],
                            ),
                            Text(
                                "${DateFormat().addPattern("dd-MMM 'at' hh:mm a").format(DateTime.parse(_announcements[index]['date']))}",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                            Divider(),
                            Row(
                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.all(0.0),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.thumb_up,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          "0 Likes",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {},
                                ),
                                FlatButton(
                                  padding: EdgeInsets.all(0.0),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          "2 Views",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return Scaffold(
                                    body: AnnouncementDetails(_colors[position],
                                        _announcements[index]),
                                  );
                                }));
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      "View Details",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                                mainAxisSize: MainAxisSize.min,
                              ),
                              padding: EdgeInsets.all(0),
                            )
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                        ),
                      ),
                    ),
                  ),
          );
        },
        itemCount: _announcements.length,
      ),
    );
  }
}
