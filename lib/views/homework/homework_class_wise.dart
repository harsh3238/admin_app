import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/data/models/model_homework.dart';
import 'package:click_campus_admin/views/homework/add_homework.dart';
import 'package:click_campus_admin/views/homework/homework_details.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/util_widgets/custom_drop_down.dart';
import 'package:click_campus_admin/views/util_widgets/select_class_section.dart';
import 'package:click_campus_admin/views/util_widgets/select_classes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeworkClassWise extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeworkClassWiseState();
  }
}

///Class is extending [StateHelper] class
///for easy access to the **sessions data** and util methods to show, hide progress
///dialog and Snackbars
///
///we call constructor for [StateHelper] in the [init(context, scaffoldState)]
///method with the reference to this State object, so that the Helper class
///initialises all the data
class _HomeworkClassWiseState extends State<HomeworkClassWise> with StateHelper {
  ///Global key to manage scaffold of this screen,
  ///mainly used to show snackbar
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

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

  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  List<ModelHomework> _homeworkList = List();

  Future<void> _getHomeworkData(String classId) async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var homeworkResponse = await http.post(
        GConstants.getHomeworkRoute(await AppData().getSchoolUrl()),
        body: {
          'class_id': classId,

          ///class id is received from the SelectionClass and is passed here
          'session_id': activeSession.sessionId.toString(),
          'date_from': DateFormat().addPattern("yyyy-MM-dd").format(dateFrom),
          'date_to': DateFormat().addPattern("yyyy-MM-dd").format(dateTo),
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
    return Scaffold(
      key: _scaffoldState,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: CustomInputDropdown(
                    labelText: "From",
                    valueText: DateFormat.yMMMd().format(dateFrom),
                    valueStyle: Theme.of(context)
                        .textTheme
                        .subhead
                        .apply(color: Colors.white),
                    onPressed: () async {
                      final DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: dateFrom,

                        ///Only 30 days older date can be selected from calender,
                        ///however it is not clear, I have not talked to anybody
                        ///as to what the requirement is. I decided to go with 30
                        ///because it feel appropriate for now
                        ///Same is true for future date, 30 days from now in the
                        ///future
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (picked != null)
                        setState(() {
                          dateFrom = picked;
                        });
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: CustomInputDropdown(
                    labelText: "To",
                    valueText: DateFormat.yMMMd().format(dateTo),
                    valueStyle: Theme.of(context).textTheme.subhead.apply(
                          color: Colors.white,
                        ),
                    onPressed: () async {
                      final DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: dateTo,

                        ///Only 30 days older date can be selected from calender,
                        ///however it is not clear, I have not talked to anybody
                        ///as to what the requirement is. I decided to go with 30
                        ///because it feel appropriate for now
                        ///Same is true for future date, 30 days from now in the
                        ///future
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (picked != null)
                        setState(() {
                          dateTo = picked;
                        });
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                FlatButton(
                  child: Text(
                    "GO",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  shape: CircleBorder(side: BorderSide(color: Colors.white54)),
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return SelectClasses();
                                },
                                fullscreenDialog: true))
                        .then((v) {
                      if (v != null) {
                        var a = v as int;

                        ///Only one class can be selected as of now
                        ///I am not sure if we select multiple classes
                        ///hoe we would implement that. No discussion has bee
                        ///done over this choice but it seems rational thing to do
                        _getHomeworkData(a.toString());
                      } else {
                        ///If no class is selected, what do we do?
                        ///Showing a snackbar for now.
                        showSnackBar("Please select class to see homework",
                            color: Colors.black);
                      }
                    });
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            color: Colors.indigo,
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) {
                        return SelectClassSection();
                      },
                      fullscreenDialog: true))
              .then((v) async {
            if (v != null && (v as Set<int>).length > 0) {
              var a = v.toString();

              ///getting section ids combined with class ids individually,
              ///so we can easily use it in the api call
              var classSections = await DbClassSection()
                  .getClassesForSection(a.substring(1, a.length - 1));
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AddHomework(classSections);
              }));
            }

            ///If length is zero, it means user closed the class section dialog intentionally
            else if ((v as Set<int>).length == 0) {
              showSnackBar("Please select class/section to add homework",
                  color: Colors.black);
            }
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.deepOrange,
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
