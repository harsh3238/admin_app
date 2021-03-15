import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class StaffAttendanceDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StaffAttendanceDetailState();
  }
}

class _StaffAttendanceDetailState extends State<StaffAttendanceDetail> {
  @override
  Widget build(BuildContext context) {
    CalendarCarousel _calendarCarouselNoHeader = CalendarCarousel(
      weekendTextStyle:
          TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      headerTextStyle: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      iconColor: Colors.black,
      showWeekDays: false,
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
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: _calendarCarouselNoHeader,
          ),
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
                          "0",
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
                          "0",
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
                          "0",
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
                          "0",
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
    );
  }
}
