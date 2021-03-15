import 'dart:async';
import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../state_helper.dart';

class NotificationsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MessagesMainState();
  }
}

class MessagesMainState extends State<NotificationsMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool didGetData = false;
  bool shouldLoadMore = true;
  List<dynamic> _notificationsData = List();
  var offset = 0;

  Future<void> _getNotifications(bool shouldShowProgressDialog) async {
    if (shouldShowProgressDialog) {
      showProgressDialog();
    }else{
      shouldLoadMore = false;
    }

    int userLoginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getNotificationsRoute(await AppData().getSchoolUrl()),
        body: {
          'login_row_id': userLoginId.toString(),
          'offset': offset.toString(),
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> data = modulesResponseObject['data'];
          if(data.length > 0){
            offset += 10;
            if (offset != 0) {
              _notificationsData.addAll(data);
              shouldLoadMore = true;
            } else {
              _notificationsData = data;
            }
          }else{
            shouldLoadMore = false;
          }
          if (shouldShowProgressDialog) {
            hideProgressDialog();
          }
          setState(() {});
          return null;
        } else {
          if (shouldShowProgressDialog) {
            hideProgressDialog();
          }
          showSnackBar(modulesResponseObject["message"]);
          return null;
        }
      } else {
        if (shouldShowProgressDialog) {
          hideProgressDialog();
        }
      }
    } else {
      if (shouldShowProgressDialog) {
        hideProgressDialog();
      }
    }
    if (shouldShowProgressDialog) {
      hideProgressDialog();
    }
  }

  Future<void> _handleRefresh() async {
    offset = 0;
    shouldLoadMore = true;
    _getNotifications(true);
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    var icon = "assets/dash_icons/ic_megaphone.png";
    switch (_notificationsData[index]['intent']) {
      case "gallery":
        icon = "assets/dash_icons/ic_gallery_p.png";
        break;
      case "video_gallery":
        icon = "assets/dash_icons/ic_video_gal.png";
        break;
      case "voice_call":
        icon = "assets/dash_icons/ic_voice_p.png";
        break;
      case "event_reminder":
        icon = "assets/dash_icons/ic_event.png";
        break;
      case "news":
        icon = "assets/dash_icons/ic_news.png";
        break;
      default:
        icon = "assets/dash_icons/ic_megaphone.png";
        break;
    }

    if (index == _notificationsData.length - 1 && shouldLoadMore) {
      _getNotifications(false);
    }

    return ListTile(
      leading: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
              color: Colors.indigo),
          alignment: Alignment.center,
          child: Container(
            child: Image.asset(
              icon,
              color: Colors.white,
            ),
            width: 30,
            height: 30,
          )),
      title: Text(
        _notificationsData[index]['title'],
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        _notificationsData[index]['body'],
        style: TextStyle(fontWeight: FontWeight.bold),
        maxLines: 10,
      ),
      trailing: Text(DateFormat()
          .addPattern("dd-MMM")
          .format(
              DateTime.parse(_notificationsData[index]['timestamp_created']))
          .toString()),
      onTap: () {},
      isThreeLine: true,
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
      didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getNotifications(true);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: ListView.builder(
          itemCount: _notificationsData.length,
          itemBuilder: _buildFriendListTile,
        ),
      ),
    );
  }
}
