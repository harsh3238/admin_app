import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/model_homework.dart';
import 'package:click_campus_admin/views/homework/homework_details.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeworkOneTeacher extends StatefulWidget {
  final String homeworkId;

  HomeworkOneTeacher(this.homeworkId);

  @override
  State<StatefulWidget> createState() {
    return _HomeworkOneTeacherState();
  }
}

///Class is extending [StateHelper] class
///for easy access to the **sessions data** and util methods to show, hide progress
///dialog and Snackbars
///
///we call constructor for [StateHelper] in the [init(context, scaffoldState)]
///method with the reference to this State object, so that the Helper class
///initialises all the data
class _HomeworkOneTeacherState extends State<HomeworkOneTeacher>
    with StateHelper {
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
        GConstants.getHomeworkOneTeacherRoute(await AppData().getSchoolUrl()),
        body: {
          ///class id is received from the SelectionClass and is passed here
          'session_id': activeSession.sessionId.toString(),
          'homework_id': widget.homeworkId,
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

    ///Must be called to have access to Sessions data and
    ///other util methods
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
      appBar: AppBar(title: Text("Homework"),),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),

                  ///If homework data list is empty we just show text widget
                  ///notifying user that no data could be found for
                  ///selected date and session combination
                  sliver: (_homeworkList.length > 0)
                      ? _bodyList()
                      : SliverToBoxAdapter(
                          child: Container(
                            child: Center(
                              child: Text(
                                "No homework records available.",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                            margin: EdgeInsets.all(10),
                            height: 100,
                          ),
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bodyList() => SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
        return _listItem(index);
      }, childCount: _homeworkList.length));

  Widget _listItem(int position) {
    ///We do this so that we can use this int variable to get
    ///colors from  colors array [items] recursively after every
    ///10 items
    int p = position % 10;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (b) => HomeworkDetails(_homeworkList[position])));
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(DateFormat().add_jm().format(
                DateTime.parse(_homeworkList[position].timestampCreated))),
          ),
          Expanded(
            child: Card(
              color: items[p],
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _homeworkList[position].assignmentTitle,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    Container(height: 10),
                    Text(
                      ///Concatenating Class Section name with subject name
                      ///If subject is empty/null, we show "All Subjects"
                      ///This is the business logic (lol)
                      ///Prashant Sir or Mohan decided it to be so, so...
                      ///Just doing my job
                      "${_homeworkList[position].classSection} ${(_homeworkList[position].subjectName != null && _homeworkList[position].subjectName.trim().length > 0) ? _homeworkList[position].subjectName : "All Subjects"}",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
