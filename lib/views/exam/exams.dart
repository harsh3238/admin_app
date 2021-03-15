import 'dart:convert';


import 'package:click_campus_admin/config/AppColors.dart';
import 'package:click_campus_admin/config/AppConstant.dart';
import 'package:click_campus_admin/config/AppWidget.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../state_helper.dart';

class Exams extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExamsState();
  }
}

class _ExamsState extends State<Exams> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool didWeGetData = false;
  var width;
  var height;
  List<Color> colors = [appCat1, appCat2, appCat3];
  List<dynamic> _list = [];


  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if(!didWeGetData){
      didWeGetData = true;
      getListData();
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(("Exam Section")),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(16),
              child: Image.asset("assets/images/app_bg_cover_image.jpg", height: height / 4),
            ),
            _list.length>0?_buildList():Container(height: 10,)
          ],
        ),
      ),
    );
  }

  Widget _buildList(){
    return AnimationLimiter(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _list.length,
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: height * 0.5,
              child: GestureDetector(
                onTap: () {
                  /*if(index==0){
                    navigateModule(ExamMain(), context);
                  }else if(index==1){
                    navigateModule(AttendanceFeedingMain(), context);
                  }else if(index==2){
                    navigateModule(RemarkFeedingMain(), context);
                  }*/
                },
                child: Container(
                  margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: width / 6,
                        height: 80,
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(width / 25),
                        child: Image.asset("assets/dash_icons/"+_list[index]["icon"], color: appWhite),
                        decoration: boxDecoration(bgColor: colors[index % colors.length], radius: 4),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: <Widget>[
                            Container(
                              width: width,
                              height: 80,
                              padding: EdgeInsets.only(left: 16, right: 16),
                              margin: EdgeInsets.only(right: width / 28),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      text('${_list[index]["title"]}', textColor: Color(0xff212121), fontFamily: fontMedium, fontSize: textSizeMedium, maxLine: 2),
                                      text(_list[index]["title"], textColor: Color(0xff5a5c5e), fontFamily: fontRegular, fontSize: textSizeSmall),
                                    ],
                                  ).expand(),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 25,
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    //decoration: widget.list[index].type.isNotEmpty ? boxDecoration(bgColor: appDarkRed, radius: 4) : BoxDecoration(),
                                    child: text(_list[index]["title"], fontSize: textSizeSmall, textColor: whiteColor),
                                  )
                                ],
                              ),
                              decoration: boxDecoration(bgColor: Color(0xffffffff), radius: 4, showShadow: true),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              child: Icon(Icons.keyboard_arrow_right, color: appWhite),
                              decoration: BoxDecoration(color: colors[index % colors.length], shape: BoxShape.circle),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

  }

  void getListData() {
    _list.add({"title":"Marks Feeding", "icon":"ic_result.png"});
    _list.add({"title":"Attendance", "icon":"ic_attendance_p.png"});
    _list.add({"title":"Remark", "icon":"ic_remark.png"});
    _list.add({"title":"Marks Status", "icon":"ic_remark.png"});
    _list.add({"title":"Teacher wise Marks Status", "icon":"ic_remark.png"});
  }
}
