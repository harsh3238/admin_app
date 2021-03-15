import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceMain extends StatefulWidget {
  final String studentId;

  AttendanceMain(this.studentId);

  @override
  State<StatefulWidget> createState() {
    return _AttendanceMainState();
  }
}

class _AttendanceMainState extends State<AttendanceMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _firstRunRoutineRan = false;
  EventList<EventInterface> _selectedDates = new EventList<EventInterface>();

  List<dynamic> _attList = [];
  String pCount = '0';
  String aCount = '0';
  String lCount = '0';
  String ltCount = '0';
  String hdCount = '0';

  void _getAttendanceData(String date) async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    var modulesResponse =
        await http.post(GConstants.getAttendanceRoute(await AppData().getSchoolUrl()), body: {
      'stucare_id': widget.studentId,
      'session_id': activeSession.sessionId.toString(),
      'first_date_month': date,
      'active_session': sessionToken,
    });

    log(modulesResponse.body, name:"${modulesResponse.request}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _attList = modulesResponseObject['data'];
          _selectedDates.clear();

          _attList.forEach((i) {
            _selectedDates.add(
                DateTime.parse(i['att_date']),
                Event(
                  date: DateTime.parse(i['att_date']),
                  title: i['att_status'],
                  icon: _eventIcon(i['att_status']),
                ));
          });

          if (_attList.length > 0) {
            pCount = modulesResponseObject['present_count'];
            aCount = modulesResponseObject['absent_count'];
            lCount = modulesResponseObject['leave_count'];
            ltCount = modulesResponseObject['late_count'];
            hdCount = modulesResponseObject['half_day_count'];
          } else {
            pCount = '0';
            aCount = '0';
            lCount = '0';
            ltCount = '0';
            hdCount = '0';
          }
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

  Widget _eventIcon(String status) {
    switch (status) {
      case 'AB':
        return Container(
          color: Colors.red.withOpacity(0.5),
          height: 8,
          width: 8,
        );
      case 'LV':
        return Container(
          color: Colors.blue.withOpacity(0.5),
          height: 8,
          width: 8,
        );
      case 'LT':
        return Container(
          color: Colors.orange.withOpacity(0.5),
          height: 8,
          width: 8,
        );
      case 'HD':
        return Container(
          color: Colors.lightGreenAccent.withOpacity(0.5),
          height: 8,
          width: 8,
        );
    }
    return Container(
      color: Colors.green.withOpacity(0.5),
      height: 8,
      width: 8,
    );
  }
/*
  Widget _eventIcon(String status) {
    switch (status) {
      case 'AB':
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.red,
            height: 8.0,
            width: 8.0,
            margin: EdgeInsets.only(top: 4),
          ),
        );
      case 'LV':
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.blue,
            height: 8.0,
            width: 8.0,
            margin: EdgeInsets.only(top: 4),
          ),
        );
      case 'LT':
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.orange,
            height: 8.0,
            width: 8.0,
            margin: EdgeInsets.only(top: 4),
          ),
        );
      case 'HD':
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.lightGreenAccent,
            height: 8.0,
            width: 8.0,
            margin: EdgeInsets.only(top: 4),
          ),
        );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.green,
        height: 15.0,
        width: 15.0,
        margin: EdgeInsets.only(top: 4),
      ),
    );
  }
*/

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _firstRunRoutineRan = true;
        activeSession = await SessionDbProvider().getActiveSession();
        _getAttendanceData(DateFormat()
            .addPattern("yyyy-MM-dd")
            .format(DateTime.now())
            .toString());
      });
    }

    CalendarCarousel _calendarCarouselNoHeader = CalendarCarousel(
      weekendTextStyle:
          TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      headerTextStyle: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      iconColor: Colors.black,
      showWeekDays: false,
      markedDatesMap: _selectedDates,
      markedDateWidget: Align(
        alignment: Alignment.topCenter,
        child: Container(
          color: Colors.indigoAccent,
          height: 8.0,
          width: 8.0,
          margin: EdgeInsets.only(top: 4),
        ),
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      height: 400,
      headerMargin: EdgeInsets.symmetric(vertical: 4),
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateShowIcon: true,
      showHeader: true,
      markedDateIconBuilder: (event) {
        return event.getIcon();
      },
      todayTextStyle: TextStyle(color: Colors.black),
      todayButtonColor: Colors.transparent,
      selectedDayTextStyle: TextStyle(
        color: Colors.yellow,
      ),
      onCalendarChanged: (DateTime d) {
        if (_firstRunRoutineRan) {
          _getAttendanceData(
              DateFormat().addPattern("yyyy-MM-dd").format(d).toString());
        }
      },
    );

    return Scaffold(
      key: _scaffoldState,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 410,
              child: _calendarCarouselNoHeader,
            ),
            SizedBox(height: 20,),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  /*ROW 1
                * */
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: new BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "PRESENT",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 45.0,
                        height: 18.0,
                        decoration: new BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(9))),
                        child: Center(
                          child: Text(
                            pCount,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),

                  /* ROW 2
                * */
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "ABSENT",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 45.0,
                        height: 18.0,
                        decoration: new BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(9))),
                        child: Center(
                          child: Text(
                            aCount,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),

                  /* ROW 3
                * */
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: new BoxDecoration(
                              color: Colors.blue.shade800,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "LEAVE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 45.0,
                        height: 18.0,
                        decoration: new BoxDecoration(
                            color: Colors.blue.shade800,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(9))),
                        child: Center(
                          child: Text(
                            lCount,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),

                  /* ROW 4
                * */
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: new BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "LATE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 45.0,
                        height: 18.0,
                        decoration: new BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(9))),
                        child: Center(
                          child: Text(
                            ltCount,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
