import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/live_classes/add_live_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../state_helper.dart';
import 'add_live_class.dart';

class LiveClassesMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LiveClassesMainState();
  }
}

class _LiveClassesMainState extends State<LiveClassesMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _classData = [];
  DateTime _selectedData = DateTime.now();

  void _getClasses() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    int userLoginId = await AppData().getUserLoginId();
    String schoolId = await AppData().getSchoolId();


    var modulesResponse = await http.post(GConstants.getZoomClassRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
      'user_id': userLoginId.toString(),
      'school_id': schoolId,
      'date': DateFormat().addPattern("yyyy-MM-dd").format(_selectedData)
    });

    debugPrint("${modulesResponse.request} : ${modulesResponse.statusCode}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _classData = modulesResponseObject['data'];
          hideProgressDialog();
          _getZoomAuth();
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else if(modulesResponse.statusCode == 404){
      showSnackBar("API Not Available");
    }else{
      showServerError();
    }
    hideProgressDialog();
  }

  void _getZoomAuth() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    int userLoginId = await AppData().getUserLoginId();
    String schoolId = await AppData().getSchoolId();
    var modulesResponse = await http.post(GConstants.getZoomAuthRoute(await AppData().getSchoolUrl()),
        body: {'active_session': sessionToken, 'user_id': userLoginId.toString(), 'school_id': schoolId});

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          var zoomAuth = modulesResponseObject['data'];
          var platform = MethodChannel("com.stucare.cloud_admin.default_channel");
          platform.invokeMethod("initZoom", zoomAuth);
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar("Zoom auth error");
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

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getClasses();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Live Classes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (b) => AddLiveClasses())).then((value) => _getClasses());
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_left,
                    color: Colors.white,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _selectedData = _selectedData.subtract(Duration(days: 1));
                    });
                    _getClasses();
                  },
                ),
                Text(
                  DateFormat().addPattern("dd-MM-yyyy").format(_selectedData),
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_right,
                    color: Colors.white,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _selectedData = _selectedData.add(Duration(days: 1));
                    });
                    _getClasses();
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            color: Colors.indigo,
          ),
          Expanded(
              child: ListView.separated(
            padding: EdgeInsets.all(8),
            separatorBuilder: (context, position) {
              return Divider();
            },
            itemBuilder: (context, index) {
              var dateTime = DateTime.parse("${_classData[index]['date_of_class']} ${_classData[index]['start_time']}");
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_classData[index]['has_passed'] == "0" && dateTime.difference(DateTime.now()).inMinutes < 3) {
                  } else {
                    showSnackBar("Class can only be started 3 minutes before time");
                  }
                },
                child: Container(
                  height: (_classData[index]['has_passed'] == "0" && dateTime.difference(DateTime.now()).inMinutes < 3) ? 100 : 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: Text(
                            DateFormat().addPattern("hh:mm a").format(DateTime.parse("0000-00-00 ${_classData[index]['start_time']}")),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        decoration: new BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.indigo, width: 2)),
                      ),
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _classData[index]['topic'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("${_classData[index]['class_name']}-${_classData[index]['section_name']}"),
                            Text(
                                "Ends At : ${DateFormat().addPattern("hh:mm a").format(DateTime.parse("0000-00-00 ${_classData[index]['end_time']}"))}"),
                            Visibility(
                              child: FlatButton(
                                onPressed: () {
                                  var platform = MethodChannel("com.stucare.cloud_admin.default_channel");
                                  if(_classData[index]['is_mine'] == "1"){
                                    platform.invokeMethod("start_class", {"meetingId": _classData[index]['live_link']});
                                  }else{
                                    platform.invokeMethod("join_class", {"meetingId": _classData[index]['live_link'], 'password': _classData[index]['live_password']});
                                  }
                                },
                                child: Text(
                                  "Start",
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.indigo,
                              ),
                              visible: (_classData[index]['has_passed'] == "0" && dateTime.difference(DateTime.now()).inMinutes < 3),
                            )
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
              );
            },
            itemCount: _classData.length,
          ))
        ],
      ),
    );
  }

  Widget getListImageWidget(List<dynamic> data) {
    for (int i = 0; i < data.length; i++) {
      if (data[i]['media_type'] == 'image') {
        return Container(
          margin: const EdgeInsets.only(right: 8.0),
          width: 100.0,
          height: double.infinity,
          child: Image.network(
            data[i]['file_url'],
            fit: BoxFit.cover,
          ),
          color: Colors.red,
        );
      }
    }

    return Container(width: 0);
  }


}
