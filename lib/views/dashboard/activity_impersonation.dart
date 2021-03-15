import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/views/dashboard/select_impersonation.dart';
import 'package:click_campus_admin/views/dashboard/super_user_otp_dialog.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImpersonationMain extends StatefulWidget {

  final schooldId;

  ImpersonationMain(this.schooldId);

  @override
  State<StatefulWidget> createState() {
    return StateImpersonationMain();
  }
}

class StateImpersonationMain extends State<ImpersonationMain> with StateHelper {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  final _stucareIdTextController = TextEditingController();
  final _userNameTextController = TextEditingController();

  Future<void> _loginRequest() async {
    showProgressDialog();

    var schoolDataResponse =
        await http.post(GConstants.superUserRoute(), body: {
      'stucare_emp_id': _stucareIdTextController.text,
      'user_name': _userNameTextController.text
    });
    //print(schoolDataResponse.body);

    if (schoolDataResponse.statusCode == 200) {
      Map responseObject = json.decode(schoolDataResponse.body);
      if (responseObject.containsKey("status")) {
        if (responseObject["status"] == "success") {
          var didOtpMatch = await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SuperUserOtpDialog(responseObject['mobile_no']),
                fullscreenDialog: true,
              ));
          if (didOtpMatch != null && didOtpMatch) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => SelectImpersonation(widget.schooldId, _stucareIdTextController.text)));
          }
          return null;
        } else {
          showSnackBar(responseObject["message"]);
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
    return Scaffold(
        key: _scaffoldState,
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  "In order to proceed in super user mode please fill out the form below.",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Stucare Id",
                      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                      labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    scrollPadding: EdgeInsets.all(0),
                    style: TextStyle(color: Colors.grey),
                    validator: (txt) {
                      RegExp regex = new RegExp("\\d+");
                      if (!regex.hasMatch(txt)) {
                        return "Enter valid stucare ID";
                      }
                      return null;
                    },
                    controller: _stucareIdTextController,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                        labelText: "User Name",
                        contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                        labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey))),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    scrollPadding: EdgeInsets.all(0),
                    style: TextStyle(color: Colors.grey),
                    validator: (txt) {
                      if (txt.isEmpty) {
                        return "Enter valid user name";
                      }
                      return null;
                    },
                    controller: _userNameTextController,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(
                    width: 150,
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _loginRequest();
                        }
                      },
                      disabledColor: Colors.indigo,
                      color: Colors.indigoAccent,
                      child: Text(
                        "Proceed",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
