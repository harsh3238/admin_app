import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class EventsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventsMainState();
  }
}

class _EventsMainState extends State<EventsMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  List<dynamic> _upcomingEvents = <dynamic>[];
  List<dynamic> _passedEvents = <dynamic>[];
  List<DateTime> _selectedDates = [];

  void _getEventsData(String monthT, String year) async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getEventsRoute(await AppData().getSchoolUrl()),
        body: {'month': monthT, 'year': year, 'active_session': sessionToken,});

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _upcomingEvents = modulesResponseObject['upcoming'];
          _passedEvents = modulesResponseObject['passed'];
          _selectedDates.clear();
          _upcomingEvents.forEach((i) {
            _selectedDates.add(DateTime.parse(
                "$year-${monthT.padLeft(2, '0')}-${i['day'].toString().padLeft(2, '0')}"));
          });
          _passedEvents.forEach((i) {
            _selectedDates.add(DateTime.parse(
                "$year-${monthT.padLeft(2, '0')}-${i['day'].toString().padLeft(2, '0')}"));
          });
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
    CalendarCarousel _calendarCarouselNoHeader = CalendarCarousel(
      daysHaveCircularBorder: false,
      todayButtonColor: Colors.transparent,
      todayTextStyle: TextStyle(color: Colors.black),
      markedDateWidget: Align(
        alignment: Alignment.topCenter,
        child: Container(
          color: Colors.indigoAccent,
          height: 8.0,
          width: 8.0,
          margin: EdgeInsets.only(top: 4),
        ),
      ),
      weekendTextStyle:
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      headerTextStyle: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      weekdayTextStyle: TextStyle(color: Colors.indigo),
      height: 450,
      markedDateShowIcon: true,
      markedDateIconBuilder: (v) {
        return Container(
          color: Colors.red,
          height: 8,
          width: 8,
        );
      },
      thisMonthDayBorderColor: Colors.grey,
      onCalendarChanged: (DateTime d) {
        _getEventsData(d.month.toString(), d.year.toString());
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(("Events")),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _calendarCarouselNoHeader,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Upcoming Events",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
              delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    leading: Text((index + 1).toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12)),
                    title: Text(_upcomingEvents[index]['event_name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12)),
                    subtitle: Text(
                      _upcomingEvents[index]['event_description'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                    trailing: Text(
                        '${_upcomingEvents[index]['day']} ${_upcomingEvents[index]['month']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12)),
                    dense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  elevation: 0,
                );
              }, childCount: _upcomingEvents.length)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Passed Events",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
              delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    leading: Text((index + 1).toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12)),
                    title: Text(_passedEvents[index]['event_name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12)),
                    subtitle: Text(
                      _passedEvents[index]['event_description'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12),
                    ),
                    trailing: Text(
                        '${_passedEvents[index]['day']} ${_passedEvents[index]['month']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12)),
                    dense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  elevation: 0,
                );
              }, childCount: _passedEvents.length))
        ],
      ),
    );
  }
}
