import 'dart:convert';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class PollResult extends StatefulWidget {
  Map pollQuestion;

  PollResult(this.pollQuestion);

  @override
  State createState() => StatePollResult();
}

class StatePollResult extends State<PollResult> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool isAttempted = true;
  bool didWeGetData= false;
  int selectedItemIndex = -1;


  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if(!didWeGetData){
      didWeGetData = true;
      //checkUserAttempt();

    }
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Poll"),
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
                            widget.pollQuestion['poll_question'],
                            style: TextStyle(
                              fontSize: 22,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                      widget.pollQuestion['poll_question_image'] != null
                          ? Align(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Image.network(
                                  widget.pollQuestion['poll_question_image'],
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

                  List<dynamic> _optionList = widget.pollQuestion['options'];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: (selectedItemIndex != -1 && selectedItemIndex== index)?Colors.green: Colors.white, spreadRadius: 3),
                        ],
                      ),
                      child: ListTile(
                        onTap: (){

                          if(!isAttempted){
                            selectedItemIndex = index;
                            setState(() {});
                          }
                        },
                        title: Text(
                          _optionList[index]['option'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        subtitle: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                    text: "Votes Received : ",
                                  ),
                                  TextSpan(
                                    text: "\n${ _optionList[index]['percentage'].toString()}% Votes(${_optionList[index]['total_option_answer']}/${_optionList[index]['total_question_answer']})",
                                    style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.normal),
                                  ),
                            ])),
                        trailing: _optionList[index]['option_image'] != null && _optionList[index]['option_image'] != ""
                            ? Padding(
                                padding: EdgeInsets.all(4),
                                child: Image.network(
                                  _optionList[index]['option_image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ))
                            : Container(
                                width: 10,
                              ),
                      ),
                    ),
                  );
                }, childCount: widget.pollQuestion['options'].length))
              ],
            ),
          ),
          Visibility(
            visible: !isAttempted,
            child: Align(
              child: Container(
                color: Colors.indigo,
                child: FlatButton(
                    onPressed: () {
                      checkValidation();
                    },
                    child: Text(
                      "Submit Your Poll",
                      style: TextStyle(color: Colors.white),
                    )),
                width: double.infinity,
              ),
              alignment: Alignment.bottomCenter,
            ),
          )
        ],
      ),
    );
  }

  void checkValidation() {
    if (selectedItemIndex != -1) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Submit Poll?"),
              content: Text("Are you sure you want to submit the poll ? "),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Submit"),
                )
              ],
            );
          });
    } else {
      StateHelper()
          .showShortToast(context, "Please select answer for this poll by tapping on your choice");
    }
  }
  void checkUserAttempt(){
    List<dynamic> _optionList = widget.pollQuestion['options'];

    for(int i=0; i<_optionList.length; i++){
      List<dynamic> _answerList = _optionList[i]['option_answer'];
      if(_answerList.isNotEmpty){
        selectedItemIndex = i;
        isAttempted = true;
      }
    }
    setState(() { });
  }
}
