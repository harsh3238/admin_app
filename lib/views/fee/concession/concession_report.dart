import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/utils/debouncer.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multiselect_formfield/multiselect_dialog.dart';

class ConcessionReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateConcessionReport();
  }
}

class StateConcessionReport extends State<ConcessionReport> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  int page_no = 0;
  int limit = 5;
  bool isSearching = false;
  bool isLoading = false;
  List<dynamic> _concessionList = [];
  List<dynamic> filteredConcessionList = List();
  final _debouncer = Debouncer(milliseconds: 200);
  List<dynamic> _statusTypeList = [];
  Map<String, dynamic> _selectedStatusType;
  List<dynamic> _selectedModes = [];

  
  void _getStatusTypes() async {
    _statusTypeList.add({'key': 'pending', 'value': 'Pending'});
    _statusTypeList.add({'key': 'approved', 'value': 'Approved'});
    _statusTypeList.add({'key': 'reject', 'value': 'Rejected'});
    _statusTypeList.add({'key': 'cancel', 'value': 'Removed/Cancelled'});
    setState(() {});
  }

  List<DropdownMenuItem<Map<String, dynamic>>> getSelectableStatusType() {
    return _statusTypeList.map((item) {
      return DropdownMenuItem<Map<String, dynamic>>(
        child: Text(item['value']),
        value: item,
      );
    }).toList();
  }

  void _loadConcessionRequests(int pageNo, int limit) async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();
    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    Map<String, String> requestBody = {
      'session_id': activeSession.sessionId.toString(),
      'page_number': pageNo.toString(),
      'number_of_items': limit.toString(),
      'status': _selectedStatusType != null ? _selectedStatusType["key"] : "pending",//pending,approved,reject,cancel
      'active_session': sessionToken,
    };

    debugPrint("${requestBody}");
    modulesResponse =
        await http.post(GConstants.getConcessionRequestRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          List<dynamic> data = modulesResponseObject['data'];
          _concessionList.clear();
          filteredConcessionList.clear();

          _concessionList.addAll(data);
          filteredConcessionList.addAll(data);

          if (data.length == 0) {
            StateHelper().showShortToast(context, "No Data Available");
          }
          hideProgressDialog();
          setState(() {
            isLoading = false;
          });
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["error"]);
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

  void _loadConcessionModes(String stucareId, String requestId) async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();

    Map<String, String> requestBody = {

      'session_id': activeSession.sessionId.toString(),
      'stucare_id':stucareId,
      'active_session': sessionToken,
    };

    debugPrint("${requestBody}");
    modulesResponse =
    await http.post(GConstants.getConcessionModesRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          hideProgressDialog();
          List<dynamic> modeList = modulesResponseObject['data'];
          if (modeList.length == 0) {
            StateHelper().showShortToast(context, "No Data Available");
          }
          _showModesDialog(modeList, stucareId, requestId);
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["error"]);
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
         activeSession = await SessionDbProvider().getActiveSession();
        _getStatusTypes();
        //_loadDiscountRequests(0, limit);
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Concession"),
        actions: <Widget>[
          //IconButton(tooltip: 'Search', icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: DropdownButtonFormField(
                items: getSelectableStatusType(),
                value: _selectedStatusType,
                onChanged: (val) {
                  if (val == _selectedStatusType) {
                    return;
                  }
                  setState(() {
                    _selectedStatusType = val;
                  });
                  _loadConcessionRequests(0, limit);
                },
                hint: Text("Select Concession Status"),
              ),
            ),

        _searchBar(),
        _selectedStatusType==null?Container(
          child:Expanded(child: Center(child: Text("Please select concession status to load data")))
        ):
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                if (isSearching) {
                  return true;
                }
                /*setState(() {
                      isLoading = true;
                      page_no++;
                    });
                    _loadStudentData(page_no, limit);*/
              }
              return true;
            },
            child: ListView.separated(
              padding: EdgeInsets.all(8),
              separatorBuilder: (context, position) {
                return Container(
                  height: 4,
                );
              },
              itemBuilder: (context, index) {

                List<dynamic> amount = filteredConcessionList[index]["amount"];
                List<dynamic> concessionHead = filteredConcessionList[index]["concession_head"];

                return filteredConcessionList.length > 0
                    ? GestureDetector(
                  onTap: () {},
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                 filteredConcessionList[index]["student_name"],
                                  style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  if(_selectedStatusType["key"] == "pending"){
                                    _showPopupMenu(details.globalPosition, filteredConcessionList[index]['request_id'].toString());
                                  }else if(_selectedStatusType["key"] == "approved") {
                                    _showDisapprovePopupMenu(details.globalPosition, filteredConcessionList[index]['request_id'].toString(),
                                        filteredConcessionList[index]['student_stucare_id'].toString());
                                  }
                                },
                                child: Visibility(
                                  visible: getOptionButtonVisibility(index),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.assignment_return_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          width: double.infinity,
                          color: Colors.indigo,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("S.R. No: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(filteredConcessionList[index]['student_s_r_no'] != null ? filteredConcessionList[index]['student_s_r_no'] : "Not Available"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Class:"),
                              SizedBox(
                                width: 10,
                              ),
                              Text('${filteredConcessionList[index]['class'] != null ? filteredConcessionList[index]['class'] : "Not Available"}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Section:"),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                  '${filteredConcessionList[index]['section'] != null ? filteredConcessionList[index]['section'] : "Not Available"}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Concession Amount: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(amount[0]),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Concession Head: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(concessionHead!=null && concessionHead.length>0?concessionHead[0]:"Not Available"),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Approved Status: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(filteredConcessionList[index]['approved_status']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Mode: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(filteredConcessionList[index]['mode']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("Reason: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(filteredConcessionList[index]['concession_reason'] != null ? filteredConcessionList[index]['concession_reason']  : "Not Available"),
                            ],
                          ),
                        ),
                        //contentTable(index, '${studentClass["class_name"]}-${studentSection["sec_name"]}', creator["name"], reason["reason_value"])
                      ],
                    ),
                  ),
                )
                    : Container(
                  child: Text("No Data Found"),
                );
              },
              itemCount: filteredConcessionList.length,
            ),
          ),
        ),
            Container(
              height: isLoading ? 50.0 : 0,
              color: Colors.transparent,
              child: Center(
                child: new CircularProgressIndicator(),
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }

  _searchBar() {
    return Visibility(
      visible: _selectedStatusType!=null && _selectedStatusType["key"] == "approved"?true:false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search Here...',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white70,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.black26, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
          onChanged: (string) {
            _debouncer.run(() {
              setState(() {
                filteredConcessionList = _concessionList.where((u) => (u["student_name"].toLowerCase().contains(string.toLowerCase())
                || u["student_s_r_no"].toLowerCase().contains(string.toLowerCase()))).toList();
              });
            });
          },
        ),
      ),
    );
  }


  void _showDisapprovePopupMenu(Offset offset, String requestId, String stucareId) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _loadConcessionModes(stucareId, requestId);
                  //_showConfirmationDialog(context, "cancel", requestId);
                },
                child: Container(
                    alignment: Alignment.center,
                    height: 45,
                    child: Text('Remove Concession'))
            ),
            value: 'disapproved'),
      ],
      elevation: 8.0,
    );
  }


  void _showPopupMenu(Offset offset, String requestId) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
            child: InkWell(
              onTap: (){
                Navigator.of(context).pop();
                _showConfirmationDialog(context, "accept", requestId);
              },
              child: Container(
                alignment: Alignment.center,
                width: 80,
                height: 40,
                  child: Text("Accept"),
              ),
            ),
            value: 'accept'),
        PopupMenuItem<String>(
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showConfirmationDialog(context, "reject", requestId);
                },
                child: Container(
                    alignment: Alignment.center,
                    width: 80,
                    height: 40,
                    child: Text('Reject'))
            ),
            value: 'reject'
        ),
      ],
      elevation: 8.0,
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String operation, String requestId) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 60,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(getConfirmationMessage(operation),
                    style: TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.black38,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.redAccent,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                    _showOptionDialog(context, operation, requestId);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _showOptionDialog(BuildContext context, String operation, String requestId) async {
    return showDialog(
        context: context,
        builder: (context) {
          String selectedOption = null;
          String hint = "";
          TextEditingController _controller = TextEditingController();

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: selectedOption == null ? false : true,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: _controller,
                          autofocus: true,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xff0E9447), width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade300, width: 2.0),
                            ),
                            labelText: hint,
                            //hintStyle: TextStyle(color: AppColors.primaryColorLight),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: selectedOption == null ? true : false,
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade300,
                        size: 60,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: selectedOption == null ? true : false,
                      child: Text(
                        'Confirm one of these options',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.blue.shade300,
                  textColor: Colors.white,
                  child: Text(
                    selectedOption != null ? 'Confirm' : 'Password',
                  ),
                  onPressed: () {
                    setState(() {
                      if (selectedOption != null) {
                        Navigator.pop(context);
                        if(operation=="accept"){
                          _changeConcessionStatus("approved", selectedOption, _controller.text, requestId);
                          debugPrint("accepting discount request");

                        }else if(operation=="reject"){
                          _changeConcessionStatus("reject", selectedOption, _controller.text, requestId);
                          debugPrint("rejecting discount request");

                        }else{
                          _changeConcessionStatus("disapproved", selectedOption, _controller.text, requestId);
                          debugPrint("disapproving discount request");
                        }
                      } else {
                        hint = "Password";
                        selectedOption = "password";
                      }
                    });
                  },
                ),
                FlatButton(
                  color: Colors.blue.shade300,
                  textColor: Colors.white,
                  child: Text(
                    selectedOption != null ? 'Close' : 'OTP',
                  ),
                  onPressed: () {
                    setState(() {
                      if (selectedOption != null) {
                        Navigator.pop(context);
                      } else {
                        hint = "OTP";
                        selectedOption = "otp";
                      }
                    });
                  },
                ),
              ],
            );
          });
        });
  }


  _showModesDialog(List<dynamic> modeList, String stucareId, String requestId) async {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog(
            items: modeList.map((e) {
              Map mode = e["fee_mode"];
              return MultiSelectDialogItem(e['id'], mode['fee_mode_name']+" - "+e['discount_value']);
            }).toList(),
            title: "Select Modes",
            cancelButtonLabel: "Cancel",
            okButtonLabel: "Done",
          );
        }).then((value) {
      if(value!=null){
        setState(() {
          _selectedModes = value;
        });
        debugPrint("${ jsonEncode(_selectedModes)}");
        if(_selectedModes.length==modeList.length){
          _removeConcession(requestId, stucareId, null);
        }else{
          _removeConcession(requestId, stucareId, jsonEncode(_selectedModes));
        }
       }

    });
  }


  void _removeConcession(String requestId, String stucareId, String concessionIds) async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();

    Map<String, String> requestBody = {
      'active_session': sessionToken,
      'status' : "cancel",
      'request_id' : requestId,
      'stucare_id' : stucareId,

    };

    if(concessionIds!=null){
      requestBody.putIfAbsent('concession_id', () => concessionIds);
    }

    debugPrint("${requestBody}");
    modulesResponse =
    await http.post(GConstants.getChangeConcessionStatusRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          hideProgressDialog();
          setState(() {
            isLoading = false;
          });
          _loadConcessionRequests(0, limit);
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["message"]);
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


  void _changeConcessionStatus(String status, String confirmation, String confirmationValue, String requestId) async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();

    Map<String, String> requestBody = {
      'active_session': sessionToken,
      'status' : status, //pending,approved,reject,cancel
      'confirmation' : confirmation,
      'confirmationValue' : confirmationValue,
      'request_id' : requestId,
    };

    debugPrint("${requestBody}");
    modulesResponse =
    await http.post(GConstants.getChangeConcessionStatusRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          hideProgressDialog();
          setState(() {
            isLoading = false;
          });
          _loadConcessionRequests(0, limit);
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["message"]);
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


  bool getOptionButtonVisibility(int position) {
    if(_selectedStatusType["key"] == "pending"){
      return true;
    }else if(_selectedStatusType["key"] == "approved"){
      return true;
    }else if(_selectedStatusType["key"] == "reject"){
      return false;
    }else if(_selectedStatusType["key"] == "cancel"){
      return false;
    }else{
      return true;
    }

  }

  String getConfirmationMessage(String operation) {

    if(operation == "accept"){
      return "Approve Concession ?";
    }else if(operation == "reject"){
      return "Disapprove Concession ?";
    }else{
      return "Remove Concession ?";
    }
  }
}

