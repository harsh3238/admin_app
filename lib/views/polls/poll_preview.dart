import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/models/option_model.dart';
import 'package:click_campus_admin/views/announcement/select_audience.dart';
import 'package:click_campus_admin/views/announcement/selected_audience.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PollPreview extends StatefulWidget{
  final String question, questionImage;
  List<Option> _optionList = [];

  PollPreview(this.question, this.questionImage, this._optionList);

  @override
  State createState() => StatePollPreview();
}

class StatePollPreview extends State<PollPreview> with StateHelper{
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  SelectedAudience _selectedAudience;


  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Poll"),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Applicable Classes",
              style: TextStyle(fontSize: 12),
            ),
            textColor: Colors.white,
            disabledColor: Colors.white,
            onPressed: () async {
              await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) {
                            return SelectAudience();
                          },
                          fullscreenDialog: true))
                  .then((rs) {
                _selectedAudience = rs as SelectedAudience;

              });
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      Align(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            widget.question,
                            style: TextStyle(
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                      widget.questionImage != null
                          ? Align(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Image.network(
                                  widget.questionImage,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              alignment: Alignment.center,
                            )
                          : Container(
                              height: 10,
                            ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      widget._optionList[index].option,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    subtitle: RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                            children: [
                          TextSpan(
                            text: "Option "+(index+1).toString(),
                          ),
                        ])),
                    trailing: widget._optionList[index].image != ""
                        ? Padding(
                            padding: EdgeInsets.all(4),
                            child: Image.network(
                              widget._optionList[index].image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ))
                        : Container(
                      width: 10,
                    ),
                  );
                }, childCount: widget._optionList.length))
              ],
            ),
          ),
          Align(
            child: Container(
              color: Colors.indigo,
              child: FlatButton(
                  onPressed: (){
                    checkValidation();
                  },
                  child: Text(
                    "PUBLISH",
                    style: TextStyle(color: Colors.white),
                  )),
              width: double.infinity,
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }

  void checkValidation(){
    if (_selectedAudience != null &&
        (_selectedAudience.checkedStaff.length > 0 ||
            _selectedAudience.checkedStudents.length > 0)) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Publish Poll?"),
              content:
              Text("Are you sure you want to publish this poll ? "),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _savePollMessage();
                  },
                  child: Text("Okay"),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                )
              ],
            );
          });

    }else{
      StateHelper().showShortToast(context,"Please select audience for this poll");
    }
  }


  Future<void> _savePollMessage() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    String options = convertToJson(widget._optionList);

    Map requestBody = {
      'question': widget.question!=null?widget.question:"",
      'question_image': widget.questionImage!=null?widget.questionImage:"",
      'options': options,
      'stucare_ids': json.encode(_selectedAudience.checkedStudents.toList()),
      'staff_ids': json.encode(_selectedAudience.checkedStaff.toList()),
      'classes': "[]",
      'session_id': "3",
      'active_session': sessionToken,
    };

    log("${requestBody}");

    var allClassesResponse = await http.post(
        GConstants.getSavePollQuestionRoute(await AppData().getSchoolUrl()),
        body: requestBody);

    log("${allClassesResponse.request}:${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("success")) {
        if (allClassesObject["success"] == true) {

          //showSnackBar('Poll Published Successfully', color: Colors.green);
          StateHelper().showShortToast(context, "Poll Published");
          hideProgressDialog();
          Navigator.pop(context);
          /*Future.delayed(Duration(seconds: 2),(){
            Navigator.of(context).pop(true);
          });*/

        } else {
          hideProgressDialog();
          showSnackBar(allClassesObject["message"]);
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

  String convertToJson(List<Option> options) {
    List<Map<String, dynamic>> jsonData = options.map((option) => option.toMap()).toList();
    return jsonEncode(jsonData);
  }


}
