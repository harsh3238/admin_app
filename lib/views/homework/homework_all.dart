import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/model_homework.dart';
import 'package:click_campus_admin/views/homework/homework_one_teacher.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeworkAll extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeworkAllState();
  }
}

///Class is extending [StateHelper] class
///for easy access to the **sessions data** and util methods to show, hide progress
///dialog and Snackbars
///
///we call constructor for [StateHelper] in the [init(context, scaffoldState)]
///method with the reference to this State object, so that the Helper class
///initialises all the data
class _HomeworkAllState extends State<HomeworkAll> with StateHelper {
  ///Global key to manage scaffold of this screen,
  ///mainly used to show snackbar
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  List<Color> items = [
    Colors.red.shade700,
    Colors.blue.shade900,
    Colors.yellow.shade900,
    Colors.pink.shade700,
    Colors.lightBlue.shade700,
    Colors.green.shade700,
    Colors.deepOrange.shade700,
    Colors.lightGreen.shade700,
    Colors.teal.shade700,
    Colors.pink.shade700,
    Colors.purple.shade700,
    Colors.teal.shade900
  ];

  List<ModelHomework> _homeworkList = List();

  Future<void> _getHomeworkData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var homeworkResponse = await http.post(
        GConstants.getHomeworkCurrentRoute(await AppData().getSchoolUrl()),
        body: {
          'session_id': activeSession.sessionId.toString(),
          'active_session': sessionToken,
        });

    //print(homeworkResponse.body);

    if (homeworkResponse.statusCode == 200) {
      Map homeworkResponseObject = json.decode(homeworkResponse.body);
      if (homeworkResponseObject.containsKey("status")) {
        if (homeworkResponseObject["status"] == "success") {
          List<dynamic> data = homeworkResponseObject['data'];
          _homeworkList.clear();
          data.forEach((i) {
            _homeworkList.add(ModelHomework.fromJson(i));
          });
          hideProgressDialog();
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
        _getHomeworkData();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(
            leading: GestureDetector(
              child: CircleAvatar(
                backgroundImage: (_homeworkList[index].givenByPhoto != null
                    ? NetworkImage(_homeworkList[index].givenByPhoto)
                    : AssetImage("assets/profile.png")),
                foregroundColor: Colors.black,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return HomeworkOneTeacher(_homeworkList[index].id.toString());
                }));
              },
            ),
            title: Text(
              _homeworkList[index].assignmentTitle,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${_homeworkList[index].givenBy} | ${_homeworkList[index].classSection} | ${_homeworkList[index].subjectName}",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            trailing: Text(
              DateFormat()
                  .addPattern("hh:mm a")
                  .format(DateTime.parse(_homeworkList[index].timestampCreated))
                  .toString(),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            dense: true,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return HomeworkOneTeacher(_homeworkList[index].id.toString());
                  }));
            },
          );
        },
        itemCount: _homeworkList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 0,
          );
        },
      ),
    );
  }
}
