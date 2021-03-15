import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/polls/add_poll.dart';
import 'package:click_campus_admin/views/polls/add_question_poll.dart';
import 'package:click_campus_admin/views/polls/poll_details.dart';
import 'package:click_campus_admin/views/polls/poll_result.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PollsMain extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return StatePollsMain();
  }
}


class StatePollsMain extends State<PollsMain> with StateHelper{
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool didWeGetData = false;
  List<dynamic> pollList = [];


  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }


  @override
  Widget build(BuildContext context) {
    if(!didWeGetData){
      didWeGetData = true;
      Future.delayed(Duration(milliseconds: 200),(){
        _getPolls();
      });

    }
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Polls"),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Add Poll",
              style: TextStyle(fontSize: 10),
            ),
            textColor: Colors.white,
            disabledColor: Colors.white,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext con) {
                return AddQuestionPoll();
              }));
            },
          )
        ],
      ),
      body: pollList.length>0?
      ListView.separated(
        itemCount: pollList.length,
        itemBuilder: (BuildContext context, int index) {

          Map questionDetails = pollList[index]['question_details'];
          Map creator = questionDetails['creator'];
          DateTime date = DateTime.parse(questionDetails['created_at']);
          String mDate = DateFormat().addPattern("yyyy-MM-dd h:mm:a").format(date);

          return ListTile(
            title: Text(
              questionDetails['poll_question'],
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            subtitle: SizedBox(
              width: double.infinity,
              height: 20,
              child: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      children: [
                        TextSpan(
                          text: "Added By : ",
                        ),
                        TextSpan(
                          text: creator['name'],
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextSpan(text: "  |  Date : "),
                        TextSpan(
                          text: mDate,
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      ])),
            ),
            trailing: questionDetails['poll_question_image']!=null
                && questionDetails['poll_question_image']!=""?CachedNetworkImage(
              placeholder: (context, url) => Container(
                child: Image(
                  image: AssetImage("assets/dash_icons/ic_poll_p.png"),
                  width: 50,
                  height: 50,
                  color: Colors.black45,
                  fit: BoxFit.contain,
                ),
              ),
              imageUrl: questionDetails['poll_question_image'],
              imageBuilder: (context, imageProvider) => Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ):Image(
              image: AssetImage("assets/dash_icons/ic_poll_p.png"),
              width: 50,
              height: 50,
              color: Colors.black45,
              fit: BoxFit.contain,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext con) {
                    return PollResult(questionDetails);
                  }));
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 4,
          );
        },
      ):Center(child: Text("No Data Available")),
    );
  }

  Future<void> _getPolls() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var loginId = await AppData().getUserLoginId();
    if(activeSession==null){
      StateHelper().showShortToast(context, "Please select active session and try again...");
      hideProgressDialog();
      return;
    }

    Map requestBody = {
      'stucare_id': loginId.toString(),
      'session_id': activeSession.sessionId.toString(),
      'active_session': sessionToken,
    };

    log("${requestBody}");

    var apiResponse = await http.post(
        GConstants.getPollQuestionsRoute(await AppData().getSchoolUrl()),
        body: requestBody);

    log("${apiResponse.request}:${apiResponse.body}");

    if (apiResponse.statusCode == 200) {
      Map allClassesObject = json.decode(apiResponse.body);
      if (allClassesObject.containsKey("success")) {
        if (allClassesObject["success"] == true) {
          pollList = allClassesObject["data"];
          if(pollList!=null && pollList.length==0){
            showSnackBar("No Poll Available", color: Colors.indigo);
          }
          hideProgressDialog();
          setState(() {});
          return null;

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

}
