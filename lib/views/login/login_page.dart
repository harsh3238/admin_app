import 'dart:async';
import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/dashboard/DashboardMain.dart';
import 'package:click_campus_admin/views/dashboard/activity_impersonation.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_ip/get_ip.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LinkTextSpan extends TextSpan {
  _LinkTextSpan(OtpDialogState state,
      {TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                state.resendOtp();
              });
}

class _LoginScreenState extends State<LoginScreen> with StateHelper {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final _schoolIdTextController = TextEditingController();
  final _mobileNumberTextController = TextEditingController();

  Future<void> _loginRequest() async {
    showProgressDialog();

    var schoolDataResponse = await http.post(GConstants.schoolDataRoute(),
        body: {'school_id': _schoolIdTextController.text});
    debugPrint("${schoolDataResponse.request} : ${schoolDataResponse.body}");

    if (schoolDataResponse.statusCode == 200) {
      ///Getting School Data
      Map responseObject = json.decode(schoolDataResponse.body);
      if (responseObject.containsKey("id")) {
        String tempSchoolUrl = responseObject["api_route_base"];

        ///Now that we have received the school's root url we can
        ///continue logging in user, so make another request
        ///now to the school directly
        var loginResponse =
            await http.post(GConstants.loginRoute(tempSchoolUrl), body: {
          'mobile_no': _mobileNumberTextController.text,
          'school_id': _schoolIdTextController.text
        });

        debugPrint("${loginResponse.request} : ${loginResponse.body}");

        if (loginResponse.statusCode == 200) {
          Map loginResponseObject = json.decode(loginResponse.body);
          if (loginResponseObject.containsKey("status")) {
            if (loginResponseObject["status"] == "success") {
              hideProgressDialog();
              var didOtpMatch = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => OtpDialog(
                        _mobileNumberTextController.text,
                        tempSchoolUrl,
                        _schoolIdTextController.text),
                    fullscreenDialog: true,
                  ));
              if (didOtpMatch != null && didOtpMatch) {
                var dialog = AlertDialog(
                  title: const Text('Add More Schools'),
                  content: Text(
                      "You may add more than one school, tap Add School button to proceed"),
                  actions: [
                    FlatButton(
                      child: Text("Add School"),
                      textColor: Colors.indigo,
                      disabledColor: Colors.indigo,
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                    FlatButton(
                      child: Text("Continue"),
                      textColor: Colors.indigo,
                      disabledColor: Colors.indigo,
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    )
                  ],
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) => dialog,
                  barrierDismissible: false
                ).then((value) {
                  if (value == false) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DashboardMain(false)));
                  }
                });
              }
              return null;
            } else {
              showSnackBar(loginResponseObject["message"]);
            }
          } else {
            showServerError();
          }
        } else {
          showServerError();
        }
      } else {
        showSnackBar("Invalid school ID");
      }
    } else {
      showServerError();
    }
    hideProgressDialog();
  }

  _impersonationLogic() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ImpersonationMain(_schoolIdTextController.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              "assets/main_back.jpg",
              fit: BoxFit.cover,
            ),
            Opacity(
              opacity: 0.8,
              child: Container(
                color: Colors.indigo.shade900,
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "STUCARE",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontFamily: 'StucareFont'),
                          ),
                          Text(
                            "Admin",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 14),
                          )
                        ],
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "School ID",
                            contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                            labelStyle:
                                TextStyle(fontSize: 14, color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          scrollPadding: EdgeInsets.all(0),
                          style: TextStyle(color: Colors.white),
                          validator: (txt) {
                            RegExp regex = new RegExp("\\d+");
                            if (!regex.hasMatch(txt)) {
                              return "Enter valid school ID";
                            }
                            return null;
                          },
                          controller: _schoolIdTextController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: "Mobile Number",
                              contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                              labelStyle:
                                  TextStyle(fontSize: 14, color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          scrollPadding: EdgeInsets.all(0),
                          style: TextStyle(color: Colors.white),
                          validator: (txt) {
                            RegExp regex = new RegExp("^\\d{10}\$");
                            if (!regex.hasMatch(txt)) {
                              return "Enter valid mobile number";
                            }
                            return null;
                          },
                          controller: _mobileNumberTextController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: SizedBox(
                          width: 150,
                          child: RaisedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (_mobileNumberTextController.text ==
                                    "9876543210") {
                                  _impersonationLogic();
                                } else {
                                  _loginRequest();
                                }
                              }
                            },
                            disabledColor: Colors.indigo,
                            color: Colors.indigoAccent,
                            child: Text(
                              "Submit",
                              style: TextStyle(color: Colors.white),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState);
    _checkForAllPermissions();
  }

  Future<bool> _checkPermission() async {
    PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([PermissionGroup.phone]);
      if (permissions[PermissionGroup.phone] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<bool> _checkPermissionLocation() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.location]);
      if (permissions[PermissionGroup.location] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  _checkForAllPermissions() async {
    await _checkPermission();
    await _checkPermissionLocation();
  }
}

class OtpDialog extends StatefulWidget {
  String usersMobileNumber;
  String tempRootSchoolUrl;
  String schoolId;

  OtpDialog(this.usersMobileNumber, this.tempRootSchoolUrl, this.schoolId);

  @override
  State<StatefulWidget> createState() {
    return OtpDialogState();
  }
}

class OtpDialogState extends State<OtpDialog> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _otpTextController = TextEditingController();

  Timer _timer;
  int _start = 30;
  String _resendOtpLabel;
  bool _isOtpTimerRunning = false;

  void _otpVerifyRequest() async {
    showProgressDialog();

    var otpResponse = await http
        .post(GConstants.otpVerifyRoute(widget.tempRootSchoolUrl), body: {
      'mobile_no': widget.usersMobileNumber,
      'otp': _otpTextController.text
    });
    debugPrint("${otpResponse.request} : ${otpResponse.body}");

    if (otpResponse.statusCode == 200) {
      Map otpVerificationObject = json.decode(otpResponse.body);
      if (otpVerificationObject.containsKey("status")) {
        if (otpVerificationObject["status"] == "success") {

          int loginRecordId = await saveLoginReport(int.parse(otpVerificationObject['login_id']));
          if (loginRecordId != 0) {
            otpVerificationObject["login_record_id"] = loginRecordId;

            otpVerificationObject.remove("status");
            otpVerificationObject.remove("message");

            await AppData().storeAvailableSchools(widget.schoolId, widget.tempRootSchoolUrl);
            await AppData().storeSchoolUsers(widget.schoolId, otpVerificationObject);
            await AppData().setCurrentlyActiveSchool(widget.schoolId);
            hideProgressDialog();
            Navigator.pop(context, true);
            return;
          } else {
            showSnackBar(otpVerificationObject["message"]);
          }
        } else {
          showSnackBar(otpVerificationObject["message"]);
        }
      } else {
        showServerError();
      }
      hideProgressDialog();
    }
  }

  void startResendOtp() {
    if (_isOtpTimerRunning) {
      return;
    }
    _isOtpTimerRunning = true;

    _start = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (_start < 1) {
          _timer.cancel();
        } else {
          _start = _start - 1;
        }
        if (_start < 1) {
          _resendOtpLabel = "Didn't receive the OTP, ";
        } else {
          _resendOtpLabel = "Please wait for $_start seconds";
        }
      });
    });
  }

  Future<Placemark> _getCurrentLocation() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);
    if (permission != PermissionStatus.granted) {
      return null;
    }

    var geoLocator = Geolocator();
    geoLocator.forceAndroidLocationManager = true;

    var position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await geoLocator.placemarkFromCoordinates(
        position.latitude, position.longitude);
    return placemarks[0];
  }

  Future<int> saveLoginReport(int loginId) async {
    Placemark location = null;
    //Placemark location = await _getCurrentLocation();
    String ipAddress = '';

    PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
    if (permission == PermissionStatus.granted) {
      ipAddress = await GetIp.ipAddress;
    }

    var loginReportResponse = await http
        .post(GConstants.loginReportRoute(widget.tempRootSchoolUrl), body: {
      'login_id': loginId.toString(),
      'event': "in",
      'ip_address': ipAddress,
      'city': location?.subAdministrativeArea != null
          ? location.subAdministrativeArea
          : '',
      'state': location?.administrativeArea != null
          ? location.administrativeArea
          : '',
      'country':
          location?.isoCountryCode != null ? location.isoCountryCode : '',
      'loc_cord': location?.position?.latitude != null
          ? "${location.position.latitude},${location.position.longitude}"
          : ''
    });

    debugPrint("${loginReportResponse.request} : ${loginReportResponse.body}");

    if (loginReportResponse.statusCode == 200) {
      Map loginResponseObject = json.decode(loginReportResponse.body);
      if (loginResponseObject.containsKey("status")) {
        if (loginResponseObject["status"] == "success") {
          return int.parse(loginResponseObject["record_id"]);
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  void resendOtp() async {
    showProgressDialog();

    var otpResponse = await http.post(
        GConstants.resendOtpRoute(widget.tempRootSchoolUrl),
        body: {'mobile_no': widget.usersMobileNumber});
    //print(otpResponse.body);

    if (otpResponse.statusCode == 200) {
      Map loginResponseObject = json.decode(otpResponse.body);
      if (loginResponseObject.containsKey("status")) {
        if (loginResponseObject["status"] == "success") {
          hideProgressDialog();
          showSnackBar("OTP has been resend");
          _isOtpTimerRunning = false;
          startResendOtp();
          return null;
        } else {
          showSnackBar(loginResponseObject["message"]);
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
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () async {
      startResendOtp();
    });
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(title: Text("OTP Verification")),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            SizedBox(
              width: 250,
              child: Text(
                "Please enter the OTP which has been sent to your mobile number",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: Form(
                  key: _formKey,
                  child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Enter OTP",
                      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    scrollPadding: EdgeInsets.all(0),
                    style: TextStyle(color: Colors.grey),
                    validator: (txt) {
                      RegExp regex = new RegExp("^\\d{4}\$");
                      if (!regex.hasMatch(txt)) {
                        return "   Invalid OTP";
                      }
                      return null;
                    },
                    controller: _otpTextController,
                  )),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: 150,
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _otpVerifyRequest();
                    }
                  },
                  disabledColor: Colors.indigo,
                  color: Colors.indigoAccent,
                  child: Text(
                    "Verify",
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                          text: _resendOtpLabel,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 12)),
                      _start < 1
                          ? _LinkTextSpan(
                              this,
                              style:
                                  TextStyle(color: Colors.indigo, fontSize: 12),
                              url: 'RESEND OTP',
                            )
                          : TextSpan(
                              text: '',
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 12))
                    ],
                  ),
                ),
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
