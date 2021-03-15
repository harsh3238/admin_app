import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/message/audio_player_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class VoiceCallMain extends StatefulWidget {
  @override
  State createState() {
    return VoiceCallMainState();
  }
}

class VoiceCallMainState extends State<VoiceCallMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  List<dynamic> _voiceCallsData = <dynamic>[];

  void _getVoiceCalls() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getVoiceCallsRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _voiceCallsData = modulesResponseObject['data'];
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
        _getVoiceCalls();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Voice Call"),
      ),
      body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                  delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                    return GestureDetector(
                      child: Card(
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
                                    color: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(4)))),
                              ),
                              Container(
                                width: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  Text(_voiceCallsData[index]['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 12)),
                                  Text(_voiceCallsData[index]['date_to_show'],
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
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AudioPlayerDialog(_voiceCallsData[index]['file_url']),
                        );
                      },
                    );
                  }, childCount: _voiceCallsData.length))
            ],
          )),
    );
  }
}
