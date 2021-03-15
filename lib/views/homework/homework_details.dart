import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/model_homework.dart';
import 'package:click_campus_admin/views/message/audio_player_dialog.dart';
import 'package:click_campus_admin/views/message/msg_video_player.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/util_widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeworkDetails extends StatefulWidget {
  final ModelHomework _homework;

  HomeworkDetails(this._homework);

  @override
  State<StatefulWidget> createState() {
    return HomeworkDetailsState();
  }
}

class HomeworkDetailsState extends State<HomeworkDetails> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  Future<void> _getHomeworkAttachment() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var homeworkResponse = await http.post(
        GConstants.getHomeworkAttachmentRoute(await AppData().getSchoolUrl()),
        body: {'homework_id': widget._homework.id.toString(), 'active_session': sessionToken,});

    //print(homeworkResponse.body);

    if (homeworkResponse.statusCode == 200) {
      Map homeworkResponseObject = json.decode(homeworkResponse.body);
      if (homeworkResponseObject.containsKey("status")) {
        if (homeworkResponseObject["status"] == "success") {
          List<dynamic> data = homeworkResponseObject['data'] as List<dynamic>;
          hideProgressDialog();
          showMultiAttachmentDialog(data);
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(homeworkResponseObject["message"]);
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

  void showMultiAttachmentDialog(List<dynamic> attachments) async {
    var dialog = SimpleDialog(
      title: const Text('Please Select Attachment'),
      children: getAttachmentWidgets(attachments),
    );
    await showDialog(
            context: context,
            builder: (BuildContext context) => dialog,
            barrierDismissible: false)
        .then((value) {
      var a = value as Map<String, dynamic>;
      switch (a['media_type']) {
        case "image":
          var photo = Photo(assetName: a['file_url']);
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
            return VideoDemo(a['file_url']);
          }));
          break;
        case "audio":
          showDialog(
            context: context,
            builder: (BuildContext context) => AudioPlayerDialog(a['file_url']),
          );
          break;
        case "audio":
          showDialog(
            context: context,
            builder: (BuildContext context) => AudioPlayerDialog(a['file_url']),
          );
          break;
        case "pdf":
          _launchURL(a['file_url']);
          break;
      }
    });
  }


  List<Widget> getAttachmentWidgets(List<dynamic> attachments) {
    List<Widget> widgets = List();
    for (Map<String, dynamic> aAttachment in attachments) {
      var f = aAttachment['file_url'];
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
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(
          "Homework",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      backgroundColor: Colors.blue.shade800,
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  (widget._homework.subjectName != null &&
                          widget._homework.subjectName.trim().length > 0)
                      ? widget._homework.subjectName
                      : "All Subjects",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.assignment,
                      size: 18,
                      color: Colors.white,
                    ),
                    Text("  Subject",
                        style: TextStyle(color: Colors.white, fontSize: 14))
                  ],
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: <Widget>[
                Text(
                  DateFormat()
                      .addPattern("dd MMMM, yyyy")
                      .format(DateTime.parse(widget._homework.submissionDate))
                      .toString(),
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.white,
                    ),
                    Text("  Submission Date",
                        style: TextStyle(color: Colors.white, fontSize: 14))
                  ],
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            SizedBox(
              height: 40,
            ),
            Flexible(
              child: Text(
                (widget._homework.content != null &&
                        widget._homework.content.trim().length > 0)
                    ? widget._homework.content
                    : "",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            SizedBox(
              height: (widget._homework.content != null &&
                      widget._homework.content.trim().length > 0)
                  ? 20
                  : 0,
            ),
            (widget._homework.attachmentCount > 0)
                ? GestureDetector(
                    onTap: () {
                      _getHomeworkAttachment();
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.attachment,
                          size: 22,
                          color: Colors.white,
                        ),
                        Text("  View Attachment",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  )
                : Container(
                    height: 0,
                  ),
            SizedBox(
              height: 40,
            ),
            Text(
              "Date : ${DateFormat().addPattern("dd MMMM, yyyy 'at' hh:mm a").format(DateTime.parse(widget._homework.timestampCreated)).toString()}",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            )
          ],
        ),
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
