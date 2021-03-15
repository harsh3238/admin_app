import 'dart:async';
import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class SuperUserOtpDialog extends StatefulWidget {
  String usersMobileNumber;

  SuperUserOtpDialog(this.usersMobileNumber);

  @override
  State<StatefulWidget> createState() {
    return SuperUserOtpDialogState();
  }
}

class _LinkTextSpan extends TextSpan {
  _LinkTextSpan(SuperUserOtpDialogState state,
      {TextStyle style, String url, String text})
      : super(
            style: style,
            text: text ?? url,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                state.resendOtp();
              });
}

class SuperUserOtpDialogState extends State<SuperUserOtpDialog>
    with StateHelper {
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
        .post(GConstants.superUserOtpVerifyRoute(), body: {
      'mobile_no': widget.usersMobileNumber,
      'otp': _otpTextController.text
    });
    //print(otpResponse.body);

    if (otpResponse.statusCode == 200) {
      Map otpVerificationObject = json.decode(otpResponse.body);
      if (otpVerificationObject.containsKey("status")) {
        if (otpVerificationObject["status"] == "success") {
          hideProgressDialog();
          Navigator.pop(context, true);
        } else {
          showServerError();
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

  void resendOtp() async {
    /*showProgressDialog();

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
    hideProgressDialog();*/
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
