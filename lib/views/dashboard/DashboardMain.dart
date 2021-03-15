import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_school_info.dart';
import 'package:click_campus_admin/data/models/the_session.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/admission/admission_main.dart';
import 'package:click_campus_admin/views/announcement/announcement_tab_page.dart';
import 'package:click_campus_admin/views/attendance/students/student_attendance_main.dart';
import 'package:click_campus_admin/views/attendance/teacher/staff_attendance_main.dart';
import 'package:click_campus_admin/views/change_school/change_school.dart';
import 'package:click_campus_admin/views/events/events_main.dart';
import 'package:click_campus_admin/views/exam/exams.dart';
import 'package:click_campus_admin/views/fee/fee_dash.dart';
import 'package:click_campus_admin/views/homework/homework_tab_activity.dart';
import 'package:click_campus_admin/views/leave/leave_staff.dart';
import 'package:click_campus_admin/views/leave/leave_student.dart';
import 'package:click_campus_admin/views/leave/leave_teacher.dart';
import 'package:click_campus_admin/views/live_classes/live_classes_main.dart';
import 'package:click_campus_admin/views/message/message_detail.dart';
import 'package:click_campus_admin/views/message/message_staff.dart';
import 'package:click_campus_admin/views/message/messages_inbox.dart';
import 'package:click_campus_admin/views/news/news_main.dart';
import 'package:click_campus_admin/views/notifications/notification_main.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/polls/polls_main.dart';
import 'package:click_campus_admin/views/profile/profile_one_page.dart';
import 'package:click_campus_admin/views/references/references_main_list.dart';
import 'package:click_campus_admin/views/remarks/staff_remark.dart';
import 'package:click_campus_admin/views/remarks/student_remark.dart';
import 'package:click_campus_admin/views/school_info/school_profile.dart';
import 'package:click_campus_admin/views/settings/settings_main.dart';
import 'package:click_campus_admin/views/splash/splash_screen.dart';
import 'package:click_campus_admin/views/staff/staff_main.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/students/students_main.dart';
import 'package:click_campus_admin/views/syllabus/syllabus_main.dart';
import 'package:click_campus_admin/views/tc/tc_main.dart';
import 'package:click_campus_admin/views/timetable/student/stu_timetable.dart';
import 'package:click_campus_admin/views/timetable/teacher/teacher_timetable.dart';
import 'package:click_campus_admin/views/video_gallery/video_gallery_main.dart';
import 'package:click_campus_admin/views/visitors/visitor_main.dart';
import 'package:click_campus_admin/views/voice_calls/voice_call_main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'flyer_dialog.dart';
import 'marquee_widget.dart';

class DashItem {
  String itemName;
  String itemIdentifier;
  String iconPath;
  Color color;

  DashItem(this.itemName, this.itemIdentifier, this.iconPath, this.color);

  factory DashItem.fromJson(Map<String, dynamic> parsedJson) {
    return DashItem(
        parsedJson['name_to_show'],
        parsedJson['module_name'],
        parsedJson['icon_name'] != null && parsedJson['icon_name'] != ""
            ? "assets/dash_icons/${parsedJson['icon_name']}"
            : "assets/dash_icons/ic_attention_outline.png",
        parsedJson['icon_name'] != null && parsedJson['icon_name'] != ""
            ? Color(int.parse(parsedJson['color']))
            : Color(int.parse("0xFFC2185B")));
  }
}

class DashboardMain extends StatefulWidget {
  final bool skipSessionValidation;

  DashboardMain(this.skipSessionValidation);

  @override
  State<StatefulWidget> createState() {
    return StateDashboardMain();
  }
}

class StateDashboardMain extends State<DashboardMain> with StateHelper {
  List<DashItem> items = List();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _firstRunRoutineRan = false;
  TheSession _activeSession;
  List<TheSession> _allSesions = List();
  List<dynamic> _dashSliders = List();
  List<dynamic> _flyers = List();
  bool _shouldShowFlyer = true;
  bool isSessionSet=false;

  Future<void> _validateLogIn() async {
    if (widget.skipSessionValidation) {
      return null;
    }
    int userLoginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();
    String schoolId = await AppData().getSchoolId();
    String schoolUrl = await AppData().getSchoolUrl();

    log("TOKEN: " + sessionToken);

    var loginResponse = await http.post(GConstants.validateLoginRoute(await AppData().getSchoolUrl()),
        body: {'login_id': userLoginId.toString(), 'active_session': sessionToken, 'school_id': schoolId});

    log("${loginResponse.request} : ${loginResponse.body}");

    if (loginResponse.statusCode == 200) {
      Map loginResponseObject = json.decode(loginResponse.body);
      if (loginResponseObject.containsKey("status")) {
        if (loginResponseObject["status"] == "success") {
          return null;
        } else {
          hideProgressDialog();
          showSessionDialog(loginResponseObject["message"]);
          return null;
        }
      }
    }
  }

  Future<void> _getSessions() async {
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getSessionsRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    log("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      String response = modulesResponse.body;
      if (response != null && response == "auth error") {
        return;
      }

      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> modulesData = modulesResponseObject['data'];
          await SessionDbProvider().insertSession(modulesData);
          _activeSession = await SessionDbProvider().getActiveSession();
          _allSesions = await SessionDbProvider().getAllSessions();
          if (this.mounted) {
            setState(() {});
          }
          return null;
        } else {
          return null;
        }
      }
    }
  }

  Future<void> _getActiveModules() async {
    showProgressDialog();
    /*var cachedModules = await AppData().getActiveModules();
    if (cachedModules != null) {
      Map cachedModulesObject = json.decode(cachedModules);
      List<dynamic> modulesData = cachedModulesObject['data'];
      items.clear();
      modulesData.forEach((item) {
        items.add(DashItem.fromJson(item));
      });
      setState(() {});
    }*/

    int userLoginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getActiveModulesRoute(await AppData().getSchoolUrl()), body: {
      'login_row_id': userLoginId.toString(),
      'active_session': sessionToken,
    });

    log("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      String response = modulesResponse.body;
      if (response != null && response == "auth error") {
        showSessionDialog("Session Expired");
        return;
      }
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          await AppData().saveModulesOffline(modulesResponse.body);
          List<dynamic> modulesData = modulesResponseObject['data'];
          items.clear();
          modulesData.forEach((item) {
            items.add(DashItem.fromJson(item));
          });
          hideProgressDialog();
          if (this.mounted) {
            setState(() {});
          }
          return null;
        }
      }
    }
    hideProgressDialog();
  }

  void _setActiveSession(TheSession theSession) async {
    await SessionDbProvider().setActiveSession(theSession.sessionId);
    _activeSession = await SessionDbProvider().getActiveSession();
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> _getSliders() async {
    String sessionToken = await AppData().getSessionToken();

    var dashSlidersResponse = await http.post(GConstants.getDashSliderRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    log("${dashSlidersResponse.request} : ${dashSlidersResponse.body}");

    if (dashSlidersResponse.statusCode == 200) {
      String response = dashSlidersResponse.body;
      if (response != null && response == "auth error") {
        return;
      }

      Map dashSlidersResponseObject = json.decode(dashSlidersResponse.body);
      if (dashSlidersResponseObject.containsKey("status")) {
        if (dashSlidersResponseObject["status"] == "success") {
          _dashSliders = dashSlidersResponseObject['data'];
          if (this.mounted) {
            setState(() {});
          }
          return null;
        }
      }
    }
  }

  Future<void> _getFlashNews() async {
    String sessionToken = await AppData().getSessionToken();

    var dashSlidersResponse = await http.post(GConstants.getFlashNewsRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    log("${dashSlidersResponse.request} : ${dashSlidersResponse.body}");

    if (dashSlidersResponse.statusCode == 200) {
      String response = dashSlidersResponse.body;
      if (response != null && response == "auth error") {
        return;
      }

      Map dashSlidersResponseObject = json.decode(dashSlidersResponse.body);
      if (dashSlidersResponseObject.containsKey("status")) {
        if (dashSlidersResponseObject["status"] == "success") {
          _flashNews = dashSlidersResponseObject['data'];
          if (this.mounted) {
            setState(() {});
          }
          return null;
        }
      }
    }
  }

  Future<void> _getSchoolInfo() async {
    String sessionToken = await AppData().getSessionToken();
    var schoolInfoResponse = await http.post(GConstants.getSchoolInfoRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    log("${schoolInfoResponse.request} : ${schoolInfoResponse.body}");

    if (schoolInfoResponse.statusCode == 200) {
      String response = schoolInfoResponse.body;
      if (response != null && response == "auth error") {
        return;
      }

      Map schoolInfoRsObject = json.decode(schoolInfoResponse.body);
      if (schoolInfoRsObject.containsKey("status")) {
        if (schoolInfoRsObject["status"] == "success") {
          Map<String, dynamic> modulesData = schoolInfoRsObject['data'];

          if (modulesData.containsKey("access_key")) {
            AppData().setAccessKey(modulesData['access_key']);
            AppData().setSecretKey(modulesData['secrety_key']);
            modulesData.remove('access_key');
            modulesData.remove('secrety_key');
          }

          if (modulesData.containsKey("aws_bucket_name")) {
            AppData().setBucketName(modulesData['aws_bucket_name']);
            AppData().setBucketRegion(modulesData['aws_bucket_region']);
            AppData().setBucketUrl(modulesData['aws_bucket_url']);
            modulesData.remove('aws_bucket_name');
            modulesData.remove('aws_bucket_region');
            modulesData.remove('aws_bucket_url');
          }

          await DbSchoolInfo().insertSchoolInfo(modulesData);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
    }
  }

  Future<void> _getFlyers() async {
    String sessionToken = await AppData().getSessionToken();

    var flyersResponse = await http.post(GConstants.getFlyersRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    log("${flyersResponse.request} : ${flyersResponse.body}");

    if (flyersResponse.statusCode == 200) {
      String response = flyersResponse.body;
      if (response != null && response == "auth error") {
        return;
      }

      Map flyersResponseObject = json.decode(flyersResponse.body);
      if (flyersResponseObject.containsKey("status")) {
        if (flyersResponseObject["status"] == "success") {
          _flyers = flyersResponseObject['data'];
          if (_flyers.length > 0 && _shouldShowFlyer) {
            _shouldShowFlyer = false;
            if (context != null) {
              showDialog(
                context: context,
                builder: (BuildContext context) => FlyerDialog(_flyers),
              );
            }
          }
          return null;
        }
      }
    }
  }

  void _logUserOut() async {
    showProgressDialog();
    Future.delayed(Duration(milliseconds: 1500), () async {
      await AppData().deleteAllUsers();
      hideProgressDialog();
      //Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          body: SplashScreen(),
        );
      }));
    });
  }

  Future<void> _handleRefresh() async {
    items.clear();
    _dashSliders.clear();
    _flyers.clear();
    _startupRoutine(true);
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void _setFirebaseId(String firebaseToken) async {
    int userLoginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var firebaseIdUploadRs = await http.post(GConstants.getSetFirebaseIdRoute(await AppData().getSchoolUrl()), body: {
      'login_id': userLoginId.toString(),
      'firebase_id': firebaseToken,
      'active_session': sessionToken,
    });
    //print(firebaseIdUploadRs.body);
  }

  void setUpFirebase() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      //print("FIREBASE ID = " + token);
      _setFirebaseId(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //print('on message $message');
        _showNotification(message['notification']['title'], message['notification']['body']);
      },
      onResume: (Map<String, dynamic> message) async {
        //print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        //print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      //print("Settings registered: $settings");
    });
  }

  Future<void> _showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  void _startupRoutine(shouldShowProgress) async {
    /* if (shouldShowProgress) {
      showProgressDialog();
    }*/

    await _getActiveModules();
    //await _validateLogIn();
    await _getSessions();
    await _getSliders();
    await _getFlashNews();
    await _getSchoolInfo();
    await _getFlyers();
    /*if (shouldShowProgress) {
      hideProgressDialog();
    }*/
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState);
    setUpFirebase();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      _firstRunRoutineRan = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _startupRoutine(false);
      });
    }
    int i = 0;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: <Widget>[
          FlatButton(
            child: _activeSession != null
                ? Text(_activeSession.sessionName)
                : Container(
                    height: 0,
                  ),
            textColor: Colors.white,
            disabledColor: Colors.white,
            onPressed: () {
              var dialog = SimpleDialog(
                title: const Text('Change Session'),
                children: _allSesions.map((oneSessionItem) {
                  return SimpleDialogOption(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        oneSessionItem.sessionName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, oneSessionItem);
                    },
                  );
                }).toList(),
              );
              showDialog(
                context: context,
                builder: (BuildContext context) => dialog,
              ).then((value) {
                //print(value);
                _setActiveSession(value);
              });
            },
          ),
          PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    const PopupMenuItem<String>(
                      value: 'Change School',
                      child: Text('Change School'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Settings',
                      child: Text('Settings'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Test Preview',
                      child: Text('Test Preview'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Video Lesson Preview',
                      child: Text('Video Lesson  Preview'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Logout',
                      child: Text('Logout'),
                    ),
                  ],
              onSelected: (v) {
                if (v == "Test Preview") {
                  openModuleMappedPage("test_preview");
                }
                if (v == "Video Lesson Preview") {
                  openModuleMappedPage("video_lesson_preview");
                }
                if (v == "Logout") {
                  _logUserOut();
                }
                if (v == "Settings") {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                    return SettingsMain();
                  }));
                }
                if (v == "Change School") {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) {
                                return ChangeSchool();
                              },
                              fullscreenDialog: true))
                      .then((value) {
                    if (value) {
                      _handleRefresh();
                    }
                  });
                }
              })
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: <Widget>[bodyList(), gridView()],
        ),
      ),
    );
  }

  PageController _pageController = PageController(initialPage: 0, keepPage: false);
  List<dynamic> _flashNews = List();

  Widget bodyList() => SliverToBoxAdapter(
        child: Stack(
          alignment: FractionalOffset.bottomCenter,
          children: <Widget>[
            _dashSliders.length > 0
                ? CarouselSlider(
                    height: 250.0,
                    autoPlay: true,
                    viewportFraction: 1.0,
                    autoPlayInterval: Duration(seconds: 2),
                    items: _dashSliders.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: CachedNetworkImage(
                              imageUrl: i['file_url'],
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    pauseAutoPlayOnTouch: Duration(seconds: 2),
                  )
                : Container(
                    height: 250,
                  ),
            Container(
                height: 30,
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: ImageIcon(
                        AssetImage("assets/ic_megaphone.png"),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        child: IgnorePointer(
                          ignoring: true,
                          child: PageView.builder(
                            reverse: true,
                            controller: _pageController,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, position) {
                              return Center(
                                  child: MarqueeWidget(
                                direction: Axis.horizontal,
                                child: Text(
                                  _flashNews[position],
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(color: Colors.blue.shade900),
                                ),
                                pageController: _pageController,
                                myIndex: position,
                                noOfNews: _flashNews.length,
                              ));
                            },
                            itemCount: _flashNews.length,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.indigo,
                      ),
                      onPressed: () {
                        double a = _pageController.page;
                        int cPage = a.floor();
                        if (cPage == _flashNews.length - 1) {
                          _pageController.jumpToPage(0);
                        } else {
                          _pageController.jumpToPage(_pageController.page.floor() + 1);
                        }
                      },
                      padding: EdgeInsets.all(4),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ))
          ],
        ),
      );

  Widget gridView() {
    return SliverGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      childAspectRatio: 1,
      children: getGridItems(),
    );
  }

  List<Widget> getGridItems() {
    return items.map((DashItem item) {
      return FlatButton(
        onPressed: () {
          openModuleMappedPage(item.itemIdentifier);
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(6),
              child: Image.asset(
                item.iconPath,
                color: item.color,
                height: 40,
              ),
            ),
            Text(
              item.itemName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
        color: Colors.white,
        shape: Border.all(width: 0.1),
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      );
    }).toList();
  }

  void openModuleMappedPage(String moduleName) async {
    if(!isSessionSet){
      isSessionSet=true;
      try{activeSession = await SessionDbProvider().getActiveSession();}catch(_){}

    }
    switch (moduleName) {
      case "test_preview":
        int userLoginId = await AppData().getUserLoginId();
        String sessionToken = await AppData().getSessionToken();
        String schoolUrl = await AppData().getSchoolUrl();
        var platform = MethodChannel("com.stucare.cloud_admin.default_channel");
        platform.invokeMethod(
            "test_preview", {"userId": userLoginId.toString(), "sessionToken": sessionToken, "schoolUrl": schoolUrl});
        break;
      case "video_lesson_preview":
        int userLoginId = await AppData().getUserLoginId();
        String schoolId = await AppData().getSchoolId();
        String sessionToken = await AppData().getSessionToken();
        String schoolUrl = await AppData().getSchoolUrl();
        var platform = MethodChannel("com.stucare.cloud_admin.default_channel");
        platform.invokeMethod("video_lesson_preview", {
          "userId": userLoginId.toString(),
          "sessionToken": sessionToken,
          "schoolId": schoolId,
          "schoolUrl": schoolUrl
        });
        break;
      case "tasks":
        // navigateToModule(TasksTabsMain());
        break;
      case "announcement":
        navigateToModule(AnnouncementTabsMain());
        break;
      case "homework":
        navigateToModule(HomeworkTabsMain());
        break;
      case "messages":
        var dialog = SimpleDialog(
          title: const Text('Select Messages Type'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "My Inbox",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "0");
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Students",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "1");
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Staff", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              ),
              onPressed: () {
                Navigator.pop(context, "2");
              },
            ),
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) => dialog,
        ).then((value) {
          if (value == "0") {
            navigateToModule(MessageInbox());
          } else if (value == "1") {
            navigateToModule(MsgStudents());
          } else if (value == "2") {
            navigateToModule(MsgStaff());
          }
        });
        break;
      case "attendance":
        var dialog = SimpleDialog(
          title: const Text('Select Attendance Type'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Students",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "0");
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Staff", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              ),
              onPressed: () {
                Navigator.pop(context, "1");
              },
            ),
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) => dialog,
        ).then((value) {
          if (value == "0") {
            navigateToModule(StudentAttendanceMain());
          } else if (value == "1") {
            navigateToModule(StaffAttendanceMain());
          }
        });
        break;
      case "timetable":
        var dialog = SimpleDialog(
          title: const Text('Select Timetable Type'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Students",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "0");
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Staff", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              ),
              onPressed: () {
                Navigator.pop(context, "1");
              },
            ),
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) => dialog,
        ).then((value) {
          if (value == "0") {
            navigateToModule(StuTimeTable());
          } else if (value == "1") {
            navigateToModule(TeacherTimetable());
          }
        });
        break;
      case "fee":
        /*var dialog = SimpleDialog(
          title: const Text('Select Fee Type'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Payment",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "0");
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Dues",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
              ),
              onPressed: () {
                Navigator.pop(context, "1");
              },
            ),
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) => dialog,
        ).then((value) {
          if (value == "0") {
            navigateToModule(FeesMain());
          } else if (value == "1") {
            navigateToModule(DueFeesMain());
          }
        });*/
        navigateToModule(FeeDash());
        break;
      case "events":
        navigateToModule(EventsMain());
        break;
      case "news":
        navigateToModule(NewsMain());
        break;
      case "staff":
        navigateToModule(StaffMain());
        break;
      case "gallery":
        navigateToModule(PhotoGallery());
        break;
      case "video_gallery":
        navigateToModule(VideoGalleryMain());
        break;
      case "voice_call":
        navigateToModule(VoiceCallMain());
        break;
      case "leave":
        var dialog = SimpleDialog(
          title: const Text('Select Leave Type'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Student",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "0");
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Staff", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              ),
              onPressed: () {
                Navigator.pop(context, "1");
              },
            ),
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) => dialog,
        ).then((value) {
          if (value == "0") {
            navigateToModule(LeaveStudent());
          } else if (value == "1") {
            navigateToModule(LeaveTeacher());
          }
        });
        break;
      case "facebook":
        String url = await DbSchoolInfo().getFacebookUrl();
        _launchURL(url);
        break;
      case "feedback":
        navigateToModule(dummyPage());
        break;
      case "website":
        String url = await DbSchoolInfo().getWebUr();
        if (url.startsWith("www")) {
          url = "http://$url";
        }
        _launchURL(url);
        break;
      case "study_zone":
        _launchURL("https://play.google.com/store/apps/details?id=org.flipacademy");
        break;
      case "school_info":
        navigateToModule(SchoolProfile());
        break;
      case "syllabus":
        navigateToModule(SyllabusMain());
        break;
      case "track":
        navigateToModule(dummyPage());
        break;
      case "polls":
        navigateToModule(PollsMain());
        break;
      case "references":
        navigateToModule(ReferencesMainList());
        break;
      case "exam":
        navigateToModule(Exams());
        break;
      case "students":
        navigateToModule(StudentsMain());
        break;
      case "visitors":
        navigateToModule(VisitorMain());
        break;
      case "profile":
        navigateToModule(ProfileOnePage());
        break;
      case "tc":
        navigateToModule(TcMainList());
        break;
      case "admission":
        navigateToModule(AdmissionMain());
        break;
      case "notifications":
        navigateToModule(NotificationsMain());
        break;
      case "live_classes":
        navigateToModule(LiveClassesMain());
        break;
      case "remark":
        var dialog = SimpleDialog(
          title: const Text('Select Remark Type'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "Student Remark",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "0");
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text("Staff Remark", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              ),
              onPressed: () {
                Navigator.pop(context, "1");
              },
            ),
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) => dialog,
        ).then((value) {
          if (value == "0") {
            navigateToModule(StudentRemark());
          } else if (value == "1") {
            navigateToModule(StaffRemark());
          }
        });
        break;
        break;
    }
  }

  Widget dummyPage() => Container(color: Colors.blue);

  void navigateToModule(Widget module) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        body: module,
      );
    }));
  }

  _launchURL(String theUrl) async {
    if (await canLaunch(theUrl)) {
      await launch(theUrl);
    } else {
      throw 'Cannot open browser for this $theUrl';
    }
  }

  void showSessionDialog(String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Authentication Failed"),
            content: Text(msg + ", Please login again to continue using application"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logUserOut();
                },
                child: Text("Login"),
              )
            ],
          );
        });
  }
}
