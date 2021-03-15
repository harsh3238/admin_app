import 'dart:convert';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/dashboard/DashboardMain.dart';
import 'package:click_campus_admin/views/dashboard/select_impersonation.dart';
import 'package:click_campus_admin/views/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool areWeDone = false;

  Future<void> checkForUpdate() async {

    try {
      if (Platform.isAndroid) {
        InAppUpdate.checkForUpdate().then((_info) {
          if (_info.updateAvailable == true) {
            debugPrint("Update Available");
            InAppUpdate.startFlexibleUpdate().then((value) {
              _getSchoolInfo();
            }).catchError((e) {
              _getSchoolInfo();
              debugPrint("error: " + e.toString());
            });
          } else {
            debugPrint("No Update Available");
            _getSchoolInfo();
          }

        }).catchError((e) {
          _getSchoolInfo();
          debugPrint("error: " + e.toString());
        });
      } else if (Platform.isIOS) {
        //ios update goes here
      } else {}
    } catch (_) {}
  }

  void _getSchoolInfo() async {
    var modulesResponse = await http.post(GConstants.getAppUpdateRoute());
    int newAppVersion;

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          Map<String, dynamic> modulesData = modulesResponseObject['data'];
          newAppVersion = int.parse(modulesData['current_admin_app_version']);
        }
      }
    }

    if (areWeDone) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String buildNumber = packageInfo.buildNumber;
      String packageName = packageInfo.packageName;
      if (int.parse(buildNumber) < newAppVersion) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("App Update Available"),
                content: Text(
                    'A newer version of the app is available and must be installed in order to continue using the app.'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Text("Download"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Text("Later"),
                  )
                ],
              );
            }).then((v) {
          if (v == 0) {
            _launchURL("https://play.google.com/store/apps/details?id=$packageName");
            SystemNavigator.pop();
          } else {
            _whatScreenToLauch();
          }
        });
      } else {
        _whatScreenToLauch();
      }
    } else {
      Future.delayed(Duration(seconds: 1), () async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String buildNumber = packageInfo.buildNumber;
        String packageName = packageInfo.packageName;
        if (int.parse(buildNumber) < newAppVersion) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("App Update Available"),
                  content: Text(
                      'A newer version of the app is available and must be installed in order to continue using the app.'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context, 0);
                      },
                      child: Text("Download"),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context, 1);
                      },
                      child: Text("Later"),
                    )
                  ],
                );
              }).then((v) {
            if (v == 0) {
              _launchURL("https://play.google.com/store/apps/details?id=$packageName");
              SystemNavigator.pop();
            } else {
              _whatScreenToLauch();
            }
          });
        } else {
          _whatScreenToLauch();
        }
      });
    }
  }

  _launchURL(String theUrl) async {
    if (await canLaunch(theUrl)) {
      await launch(theUrl);
    } else {
      throw 'Cannot open browser for this $theUrl';
    }
  }

  _whatScreenToLauch() async {
    var rWeLoggedIn = await AppData().areWeLoggedIn();
    if (!rWeLoggedIn) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ));
    } else {
      var impersonatedSchool = await AppData().getImpersonatedSchool();
      var stucareEmpId = await AppData().getStucareEmpId();
      if (impersonatedSchool != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => SelectImpersonation(impersonatedSchool, stucareEmpId)));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DashboardMain(false),
            ));
      }
    }
  }

  Future<void> initController(
    VideoPlayerController controller,
  ) async {
    controller.setLooping(false);
    controller.setVolume(0.0);
    controller.play();
    await controller.initialize();
  }

  @override
  void initState() {
    //checkForUpdate();
    _getSchoolInfo();
    Future.delayed(Duration(milliseconds: 2000), () async {
      areWeDone = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController butterflyController = VideoPlayerController.asset(
      'assets/videos/splash_video.mp4',
    );
    initController(butterflyController);

    return Container(
      child: SizedBox.expand(
        child: VideoPlayer(butterflyController),
      ),
      color: Colors.indigo,
    );
  }
}
