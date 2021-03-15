import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/message/audio_player_dialog.dart';
import 'package:click_campus_admin/views/message/msg_video_player.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/util_widgets/image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../state_helper.dart';

class AnnouncementDetails extends StatefulWidget {
  final Color _cardColor;
  final Map<String, dynamic> _announcement;

  AnnouncementDetails(this._cardColor, this._announcement);

  @override
  State<StatefulWidget> createState() {
    return _AnnouncementDetailsState();
  }
}

class _AnnouncementDetailsState extends State<AnnouncementDetails>
    with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  List<dynamic> _details = [];

  void _getDetails() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getAnnouncementDetailsRoute(await AppData().getSchoolUrl()),
        body: {
          'message_id': widget._announcement['message_id'].toString(),
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _details = modulesResponseObject['data'];
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
        _getDetails();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Announcement Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
              child: Card(
                color: widget._cardColor,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            widget._announcement['message_text']
                                        .toString()
                                        .length >
                                    0
                                ? Expanded(
                                  child: Text(
                                      widget._announcement['message_text'],
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
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            Icon(
                                              Icons.audiotrack,
                                              color: Colors.grey,
                                            )
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                          Text(widget._announcement['sender_name'],
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14))
                        ],
                      ),
                      Text(
                          "${DateFormat().addPattern("dd-MMM 'at' hh:mm a").format(DateTime.parse(widget._announcement['date']))}",
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 10, 0, 10),
              child: Text(
                "Attachments",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      switch (_details[index]['media_type']) {
                        case "image":
                          var photo = Photo(assetName: _details[index]['url']);
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
                            return VideoDemo(_details[index]['url']);
                          }));
                          break;
                        case "audio":
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                AudioPlayerDialog(_details[index]['url']),
                          );
                          break;
                      }
                    },
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Attachment ${index + 1}",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _details.length,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ),
    );
  }
}
