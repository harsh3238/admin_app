import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class SettingsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MessagesMainState();
  }
}

class MessagesMainState extends State<SettingsMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _didGetData = false;
  List<dynamic> _notificationPreferences = [];

  void _getNotificationsPreferences() async {
    showProgressDialog();
    var loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getNotificationsPrefsRoute(await AppData().getSchoolUrl()),
        body: {
          'login_id': loginId.toString(),
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _notificationPreferences = modulesResponseObject['data'];
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

  void _changeNotificationPrefs(bool optOut, String notificationType) async {
    showProgressDialog();
    var loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getChangeNotificationsPrefsRoute(
            await AppData().getSchoolUrl()),
        body: {
          'login_id': loginId.toString(),
          'notification_type': notificationType,
          'opt_out': optOut ? "1" : "0",
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          hideProgressDialog();
          _getNotificationsPreferences();
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
    super.init(context, _scaffoldKey, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getNotificationsPreferences();
      });
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            child: Text(
              'Notifications Preferences',
              style: TextStyle(color: Colors.indigo),
            ),
            padding: EdgeInsets.all(6),
          ),
          SwitchListTile(
            value: !_notificationPreferences.contains("general_content_posted"),
            title: Text("General Content Posted"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'general_content_posted');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("homework_posted"),
            title: Text("Homework Posted"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'homework_posted');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("attendance_marked"),
            title: Text("Attendance Marked"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'attendance_marked');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("fee_transaction"),
            title: Text("Fee Transaction"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'fee_transaction');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("new_message"),
            title: Text("New Message"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'new_message');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("new_reference"),
            title: Text("New Reference"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'new_reference');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("new_visitor"),
            title: Text("New Visitor"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'new_visitor');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("new_enquiry"),
            title: Text("New Admission Enquiry"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'new_enquiry');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("new_form_sale"),
            title: Text("New Admission Form Sale"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'new_form_sale');
            },
          ),
          Divider(height: 0),
          SwitchListTile(
            value: !_notificationPreferences.contains("admission_registration"),
            title: Text("New Admission Registration"),
            onChanged: (value) {
              _changeNotificationPrefs(!value, 'admission_registration');
            },
          )
        ],
      ),
    );
  }
}
