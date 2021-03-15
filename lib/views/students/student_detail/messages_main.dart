import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/students/student_detail/message_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MessagesMain extends StatefulWidget {
  final String studentId;

  MessagesMain(this.studentId);

  @override
  State<StatefulWidget> createState() {
    return MessagesMainState();
  }
}

class MessagesMainState extends State<MessagesMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  bool didGetData = false;
  List<dynamic> _msgData = List();

  Future<void> _getMessagesData() async {
    showProgressDialog();

    String sessionToken = await AppData().getSessionToken();


    var modulesResponse = await http.post(GConstants.getMessageThreadsRoute(await AppData().getSchoolUrl()),
        body: {'stucare_id': widget.studentId,
          'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _msgData = modulesResponseObject['data'];
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

  Future<void> _handleRefresh() async {

    _getMessagesData();
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    return new ListTile(
      leading:_msgData[index]['sender_image']!=null?Container(
        width: 50.0,
        height: 50.0,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new NetworkImage(_msgData[index]['sender_image']),
            fit: BoxFit.cover,
          ),
          borderRadius: new BorderRadius.all(new Radius.circular(40.0)),
          border: new Border.all(
            color: Colors.white,
            width: 2.0,
          ),
        ),
      ):SizedBox(width: 50, height: 50,
        child: Image.asset('assets/dash_icons/ic_message_p.png', color: Colors.orange)),
      title: new Text(_msgData[index]['sender_name'] ?? ""),
      subtitle: new Text(
        (_msgData[index]['message_media_type'] == 'Text') ? _msgData[index]['message_text'] : "Has Attachment",
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: new Text(DateFormat().addPattern("dd-MMM").format(DateTime.parse(_msgData[index]['date'])).toString()),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (b) => MessageDetail(_msgData[index]['sender_name'], _msgData[index]['sender'], widget.studentId)));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    if (!didGetData) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _getMessagesData();
        didGetData = true;
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: ListView.builder(
          itemCount: _msgData.length,
          itemBuilder: _buildFriendListTile,
        ),
      ),
    );
  }
}
