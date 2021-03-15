import 'dart:convert';

import 'package:click_campus_admin/utils/image_viewer.dart';
import 'package:click_campus_admin/views/announcement/announcement_details.dart';
import 'package:click_campus_admin/views/message/audio_player_dialog.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Announcement extends StatefulWidget {
  final String studentId;

  Announcement(this.studentId);

  @override
  State<StatefulWidget> createState() {
    return _AnnouncementState();
  }
}

class _AnnouncementState extends State<Announcement> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

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


    var modulesResponse = await http.post(GConstants.getMessagesAllRoute(await AppData().getSchoolUrl()),
        body: {'stucare_id': widget.studentId,
          'last_msg_id': "0",
          'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
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
    String sessionToken = await AppData().getSessionToken();


    var modulesResponse = await http.post(GConstants.getMessagesAllRoute(await AppData().getSchoolUrl()),
        body: {'stucare_id': widget.studentId, 'last_msg_id': lastId,
          'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
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
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) {
          //print("ITEM BUILD $index");
          List<dynamic> attachedFiles = [];
          int position = index % 10;
          if (_announcements[index] != null &&
              _announcements[index]['is_low_priority'] == "1") {

          }
          if (_announcements[index] != null) {
            attachedFiles = _announcements[index]['attachments'] ?? [];
          }
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                              child: Text(
                                _announcements[index]['message_title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: _announcements[index]
                                                ['sender_image'] !=
                                            null
                                        ? NetworkImage(_announcements[index]
                                            ['sender_image'])
                                        : AssetImage("assets/profile.png"),
                                    foregroundColor: Colors.black,
                                    radius: 22.0,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                      child: GestureDetector(
                                    child: Linkify(
                                      text: _announcements[index]
                                          ['message_text'],
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: 'Ubuntu'),
                                      onOpen: (link) async {
                                        if (await canLaunch(link.url)) {
                                          await launch(link.url);
                                        } else {
                                          throw 'Could not launch $link';
                                        }
                                      },
                                    ),
                                    onLongPress: () {
                                      Clipboard.setData(ClipboardData(
                                          text: _announcements[index]
                                              ['message_text']));
                                      showSnackBar("Copied", color: Colors.orange);
                                    },
                                  ))
                                ],
                              ),
                              width: double.infinity,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            attachedFiles.length > 0
                                ? SizedBox(
                                    height: 80,
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 5,
                                        mainAxisSpacing: 2.0,
                                        crossAxisSpacing: 2.0,
                                        childAspectRatio: 1,
                                      ),
                                      itemBuilder: (BuildContext context,
                                          int innerIndex) {
                                        return getGridItem(
                                            attachedFiles[innerIndex],
                                            innerIndex,
                                            attachedFiles.length,
                                            index,
                                            _colors[position]);
                                      },
                                      itemCount: attachedFiles.length > 4
                                          ? 5
                                          : attachedFiles.length,
                                    ),
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Color(0xffa09a9c),
                                        ),
                                        Text(
                                            _announcements[index]
                                                    ['sender_name'] ??
                                                '',
                                            style: TextStyle(
                                                color: Color(0xffa09a9c),
                                                fontSize: 14))
                                      ],
                                    ),
                                    Text(
                                      "${DateFormat().addPattern("dd MMMM yyyy hh:mm a").format(DateTime.parse(_announcements[index]['date']))}",
                                      style: TextStyle(
                                          color: Color(0xffa09a9c),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return Scaffold(
                                        body: AnnouncementDetails(
                                            _colors[position],
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget getGridItem(Map<String, dynamic> data, int index, int totalItem,
      int outerItemPosition, Color cardColor) {
    if (index == 4) {
      var i = totalItem - 4;
      return FlatButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return Scaffold(
                    body: AnnouncementDetails(
                        cardColor, _announcements[outerItemPosition]),
                  );
                }));
          },
          child: Text(
            "+ $i",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ));
    }
    switch (data['media_type']) {
      case 'audio':
        return GridTile(
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AudioPlayerDialog(data['url']),
                );
              },
              child: Card(
                child: Stack(
                  children: <Widget>[
                    Image.network(
                      'https://image.flaticon.com/icons/png/128/391/391300.png',
                      fit: BoxFit.cover,
                      height: 100,
                      width: double.maxFinite,
                    ),
                    Container(
                      color: Colors.black12,
                    ),
                    Positioned(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                      ),
                      bottom: 4,
                      right: 4,
                    )
                  ],
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                elevation: 0,
              ),
            ));
        break;
      case 'video':
        var videoId = youtubeParser(data['url']);
        return GridTile(
            child: GestureDetector(
              onTap: () {
                if (videoId != null) {
                  _launchURL(data['url']);
                } else {
                  showSnackBar("Video type not supported");
                }
              },
              child: Card(
                child: Stack(
                  children: <Widget>[
                    Image.network(
                      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                      fit: BoxFit.cover,
                      height: 100,
                      width: double.maxFinite,
                    ),
                    Container(
                      color: Colors.black26,
                    ),
                    Positioned(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                      ),
                      bottom: 4,
                      right: 4,
                    )
                  ],
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                elevation: 0,
              ),
            ));
        break;
      case 'pdf':
        return GridTile(
            child: GestureDetector(
              onTap: () {
                _launchURL(data['url']);
              },
              child: Card(
                child: Image.network(
                  'https://image.flaticon.com/icons/png/128/179/179483.png',
                  fit: BoxFit.contain,
                  height: 30,
                  width: 30,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                elevation: 0,
              ),
            ));
        break;
      default:
        return GridTile(
            child: GestureDetector(
              onTap: () {
                var photo = Photo(assetName: data['url']);
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                      return Scaffold(
                        body: SizedBox.expand(
                          child: Hero(
                            tag: photo.tag,
                            child: GridPhotoViewer(photo: photo),
                          ),
                        ),
                      );
                    }));
              },
              child: Card(
                child: Image.network(
                  data['url'],
                  height: 30,
                  width: 30,
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                elevation: 0,
              ),
            ));
        break;
    }
  }

  String youtubeParser(String url) {
    RegExp regExp = new RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );

    final match = regExp.firstMatch(url).group(1);
    return match;
  }

  _launchURL(String theUrl) async {
    if (await canLaunch(theUrl)) {
      await launch(theUrl);
    } else {
      throw 'Cannot open browser for this $theUrl';
    }
  }
}
