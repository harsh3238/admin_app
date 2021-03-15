import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/utils/image_viewer.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state_helper.dart';
import 'audio_player_dialog.dart';

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
        body: {'message_id': widget._announcement['message_id'].toString(),
          'active_session': sessionToken,});

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
    List<dynamic> attachedFiles = widget._announcement['attachments'] ?? [];
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 12),
                        child: Text(
                          widget._announcement['message_title'],
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
                              backgroundImage: widget._announcement
                              ['sender_image'] !=
                                  null
                                  ? NetworkImage(widget._announcement
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
                                    text: widget._announcement
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
                                        text: widget._announcement
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
                        height: attachedFiles.length > 5 ? 170 : 80,
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
                                attachedFiles.length,);
                          },
                          itemCount: attachedFiles.length,
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
                                      widget._announcement
                                      ['sender_name'] ??
                                          '',
                                      style: TextStyle(
                                          color: Color(0xffa09a9c),
                                          fontSize: 14))
                                ],
                              ),
                              Text(
                                "${DateFormat().addPattern("dd MMMM yyyy hh:mm a").format(DateTime.parse(widget._announcement['date']))}",
                                style: TextStyle(
                                    color: Color(0xffa09a9c),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
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
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ),
    );
  }

  Widget getGridItem(Map<String, dynamic> data, int index, int totalItem) {
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
