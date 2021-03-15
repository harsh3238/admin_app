import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/message.dart';
import 'package:click_campus_admin/views/message/audio_player_dialog.dart';
import 'package:click_campus_admin/views/message/msg_video_player.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/util_widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MsgStaff extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateMsgStaff();
  }
}

class StateMsgStaff extends State<MsgStaff> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<TheMessage> _data = List();
  bool _didGetData = false;

  Future<void> _getMessagesData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffMsgRoute(await AppData().getSchoolUrl()),
        body: {'last_msg_id': "0", 'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> messagesData = modulesResponseObject['data'];
          messagesData.forEach((i) {
            _data.add(TheMessage.fromJson(i));
          });
          _data.add(TheMessage.name(true));
          setState(() {});
          hideProgressDialog();
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

  void _getNextMsgThreads($lastMsgId) async {
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffMsgRoute(await AppData().getSchoolUrl()),
        body: {'last_msg_id': $lastMsgId.toString(), 'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> data = modulesResponseObject['data'];
          if (data.length > 0) {
            _data.removeLast();
            data.forEach((i) {
              _data.add(TheMessage.fromJson(i));
            });
            _data.add(TheMessage.name(true));
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

  void _getMsgAttachment($messageId) async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getMessagesAttachmentRoute(await AppData().getSchoolUrl()),
        body: {'message_id': $messageId.toString(), 'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> data = modulesResponseObject['data'];
          var attachments = List<MessageAttachments>();
          data.forEach((i) {
            attachments.add(MessageAttachments(i['url'], i['media_type']));
          });
          hideProgressDialog();
          showMultiAttachmentDialog(attachments);
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

  Widget getListItem(index) {
    if (_data[index].isStub) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: ContinuousRectangleBorder(),
        child: Center(
          child: FlatButton(
              onPressed: () {
                _getNextMsgThreads(_data[index - 1].messageId);
              },
              child: Text("Load More")),
        ),
      );
    }

    switch (_data[index].mediaType) {
      case MessageMedia.Text:
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: ContinuousRectangleBorder(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                child: Text(
                  _data[index].messageText,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Align(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                          TextSpan(
                              text:
                                  "${_data[index].senderName} : ${DateFormat().addPattern("dd-MMM 'at' hh:mm a").format(DateTime.parse(_data[index].date))}",
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal))
                        ]))),
                alignment: Alignment.centerRight,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
        break;
      case MessageMedia.Image:
        return Card(
          shape: ContinuousRectangleBorder(),
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              (_data[index].attachmentCount > 1)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Card(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                child: Icon(
                                  Icons.attachment,
                                  color: Colors.white,
                                ),
                                decoration: ShapeDecoration(
                                    color: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)))),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  Text("Multi Media Message",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12)),
                                  Text(
                                      "${_data[index].attachmentCount} attachments",
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 12)),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ],
                          ),
                        ),
                        elevation: 0,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                          _data[index].attachments[0].fileUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              (_data[index].messageText.length > 0)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                      child: Text(
                        _data[index].messageText,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  : Container(
                      height: 0,
                    ),
              Align(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                          TextSpan(
                              text:
                                  "${_data[index].senderName} : ${DateFormat().addPattern("dd-MMM 'at' hh:mm a").format(DateTime.parse(_data[index].date))}",
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal))
                        ]))),
                alignment: Alignment.centerRight,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
        break;
      case MessageMedia.Video:
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: ContinuousRectangleBorder(),
          child: Column(
            children: <Widget>[
              (_data[index].attachmentCount > 1)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Card(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                child: Icon(
                                  Icons.attachment,
                                  color: Colors.white,
                                ),
                                decoration: ShapeDecoration(
                                    color: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)))),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  Text("Multi Media Message",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12)),
                                  Text(
                                      "${_data[index].attachmentCount} attachments",
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 12)),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ],
                          ),
                        ),
                        elevation: 0,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Card(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                child: Icon(
                                  Icons.attachment,
                                  color: Colors.white,
                                ),
                                decoration: ShapeDecoration(
                                    color: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)))),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  Text("Video File",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12)),
                                  Text("1 attachments",
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 12)),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ],
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
              (_data[index].messageText.length > 0)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                      child: Text(
                        _data[index].messageText,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  : Container(
                      height: 0,
                    ),
              Align(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                          TextSpan(
                              text:
                                  "${_data[index].senderName} : ${DateFormat().addPattern("dd-MMM 'at' hh:mm a").format(DateTime.parse(_data[index].date))}",
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal))
                        ]))),
                alignment: Alignment.centerRight,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
        break;
      case MessageMedia.Audio:
        var f = _data[index].attachments[0].fileUrl;
        var fileName = f.substring(f.lastIndexOf("/") + 1, f.length);
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: ContinuousRectangleBorder(),
          child: Column(
            children: <Widget>[
              (_data[index].attachmentCount > 1)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Card(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                child: Icon(
                                  Icons.attachment,
                                  color: Colors.white,
                                ),
                                decoration: ShapeDecoration(
                                    color: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)))),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  Text("Multi Media Message",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12)),
                                  Text(
                                      "${_data[index].attachmentCount} attachments",
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 12)),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ],
                          ),
                        ),
                        elevation: 0,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Card(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                ),
                                decoration: ShapeDecoration(
                                    color: Colors.deepOrange,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)))),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  Text("Audio File",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12)),
                                  Text(fileName,
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 12)),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ],
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
              (_data[index].messageText.length > 0)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                      child: Text(
                        _data[index].messageText,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  : Container(
                      height: 0,
                    ),
              Align(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                          TextSpan(
                              text:
                                  "${_data[index].senderName} : ${DateFormat().addPattern("dd-MMM 'at' hh:mm a").format(DateTime.parse(_data[index].date))}",
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal))
                        ]))),
                alignment: Alignment.centerRight,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
        break;
      case MessageMedia.Misc:
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: ContinuousRectangleBorder(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Card(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          child: Icon(
                            Icons.attachment,
                            color: Colors.white,
                          ),
                          decoration: ShapeDecoration(
                              color: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)))),
                        ),
                        Container(
                          width: 20,
                        ),
                        Column(
                          children: <Widget>[
                            Text("Multi Media Message",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12)),
                            Text("${_data[index].attachmentCount} attachments",
                                style: TextStyle(
                                    color: Colors.grey.shade800, fontSize: 12)),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ],
                    ),
                  ),
                  elevation: 0,
                ),
              ),
              (_data[index].messageText.length > 0)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                      child: Text(
                        _data[index].messageText,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  : Container(
                      height: 0,
                    ),
              Align(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                          TextSpan(
                              text:
                                  "${_data[index].senderName} : ${DateFormat().addPattern("dd-MMM 'at' hh:mm a").format(DateTime.parse(_data[index].date))}",
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal))
                        ]))),
                alignment: Alignment.centerRight,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
        break;
    }
  }

  void handleListItemTapped(index) {
    switch (_data[index].mediaType) {
      case MessageMedia.Text:
        break;
      case MessageMedia.Image:
        if (_data[index].attachmentCount == 1) {
          var photo = Photo(assetName: _data[index].attachments[0].fileUrl);
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
        } else if (_data[index].attachmentCount > 1) {
          _getMsgAttachment(_data[index].messageId);
        }
        break;
      case MessageMedia.Video:
        if (_data[index].attachmentCount == 1) {
          Navigator.push(context,
              MaterialPageRoute<void>(builder: (BuildContext context) {
            return VideoDemo(_data[index].attachments[0].fileUrl);
          }));
        } else if (_data[index].attachmentCount > 1) {
          _getMsgAttachment(_data[index].messageId);
        }

        break;
      case MessageMedia.Audio:
        if (_data[index].attachmentCount == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                AudioPlayerDialog(_data[index].attachments[0].fileUrl),
          );
        } else if (_data[index].attachmentCount > 1) {
          _getMsgAttachment(_data[index].messageId);
        }
        break;
      case MessageMedia.Misc:
        _getMsgAttachment(_data[index].messageId);
        break;
    }
  }

  void showMultiAttachmentDialog(List<MessageAttachments> attachments) {
    var dialog = SimpleDialog(
      title: const Text('Please Select Attachment'),
      children: getAttachmentWidgets(attachments),
    );
    showDialog(
            context: context,
            builder: (BuildContext context) => dialog,
            barrierDismissible: false)
        .then((value) {
      var a = value as MessageAttachments;
      switch (a.mediaType) {
        case "image":
          var photo = Photo(assetName: a.fileUrl);
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
          break;
        case "video":
          Navigator.push(context,
              MaterialPageRoute<void>(builder: (BuildContext context) {
            return VideoDemo(a.fileUrl);
          }));
          break;
        case "audio":
          showDialog(
            context: context,
            builder: (BuildContext context) => AudioPlayerDialog(a.fileUrl),
          );
          break;
      }
    });
  }

  List<Widget> getAttachmentWidgets(List<MessageAttachments> attachments) {
    List<Widget> widgets = List();
    for (MessageAttachments aAttachment in attachments) {
      var f = aAttachment.fileUrl;
      var fileName = f.substring(f.lastIndexOf("/") + 1, f.length);

      widgets.add(SimpleDialogOption(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            fileName,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
        ),
        onPressed: () {
          Navigator.pop(context, aAttachment);
        },
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _getMessagesData();
        _didGetData = true;
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Staff Message"),
      ),
      body: ListView.separated(
        separatorBuilder: (context, position) {
          return Container(
            height: 0.5,
            color: Colors.grey,
          );
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              handleListItemTapped(index);
            },
            child: getListItem(index),
          );
        },
        itemCount: _data.length,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldKey);
  }
}
