import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../state_helper.dart';

class DiscountReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateDiscountReport();
  }
}

class StateDiscountReport extends State<DiscountReport> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  int page_no = 0;
  int limit = 5;
  bool isSearching = false;
  bool isLoading = false;
  List<dynamic> _studentList = [];
  List<dynamic> _statusTypeList = [];
  Map<String, dynamic> _selectedStatusType;

  List<Map<String, String>> contentData = [
    {"discount_amount": "Discount Amount : "},
    {"discount_type": "Discount Type : "},
    {"approved_status": "Approved Status : "},
  ];

  void _getStatusTypes() async {
    _statusTypeList.add({'key': 'pending', 'value': 'Pending'});
    _statusTypeList.add({'key': 'approved', 'value': 'Approved'});
    _statusTypeList.add({'key': 'approved_processed', 'value': 'Approved & Processed'});
    _statusTypeList.add({'key': 'approved_unprocessed', 'value': 'Approved & Unprocessed'});
    _statusTypeList.add({'key': 'disapproved', 'value': 'Disapproved'});
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

  void _loadDiscountRequests(int pageNo, int limit) async {
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
      'discount_status': _selectedStatusType != null ? _selectedStatusType["key"] : "pending",
      'active_session': sessionToken,
    };

    debugPrint("${requestBody}");
    modulesResponse =
        await http.post(GConstants.getDiscountRequestRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          List<dynamic> data = modulesResponseObject['data'];
          _studentList.clear();
          _studentList.addAll(data);
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
        title: Text("Discounts"),
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
                  _loadDiscountRequests(0, limit);
                },
                hint: Text("Select Discount Status"),
              ),
            ),
        _selectedStatusType==null?Container(
          child:Expanded(child: Center(child: Text("Please select discount status to load data")))
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
                Map student = _studentList[index]["student"];
                Map studentClass = student["class"];
                Map studentSection =student["section"];
                Map creator = _studentList[index]["creator"];
                Map reason = _studentList[index]["discount_reason"];

                return _studentList.length > 0
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
                                child: Text(student["student_name"],
                                  style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              GestureDetector(
                                onTapDown: (TapDownDetails details) {

                                  if(_selectedStatusType["key"] == "pending"){
                                    _showPopupMenu(details.globalPosition, _studentList[index]['id'].toString());
                                  }else if(_selectedStatusType["key"] == "approved") {
                                    _showDisapprovePopupMenu(details.globalPosition, _studentList[index]['id'].toString());
                                  }else if(_selectedStatusType["key"] == "approved_processed") {
                                    _showDisapprovePopupMenu(details.globalPosition, _studentList[index]['id'].toString());
                                  }else if(_selectedStatusType["key"] == "approved_unprocessed") {
                                    _showDisapprovePopupMenu(details.globalPosition, _studentList[index]['id'].toString());
                                  }else {

                                  }
                                },
                                child: Visibility(
                                  visible: getOptionButtonVisibility(index),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.assignment_return_outlined,
                                      color: Colors.white,
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
                              Text("Class:"),
                              SizedBox(
                                width: 10,
                              ),
                              Text('${studentClass != null ? studentClass["class_name"] : "Not Available"}'),
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
                                  '${studentSection != null ? studentSection["sec_name"] : "Not Available"}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Discount Amount: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(_studentList[index]['discount_amount']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Discount Type: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(_studentList[index]['discount_type']),
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
                              Text(_studentList[index]['approved_status']),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Processed: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(_studentList[index]['applied_status'] == 1 ? 'Yes' : 'No'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Text("Creator: "),
                              SizedBox(
                                width: 10,
                              ),
                              Text(creator != null ? creator["name"] : "Not Available"),
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
                              Text(reason != null ? reason["reason_value"] : "Not Available"),
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
              itemCount: _studentList.length,
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


  void _showDisapprovePopupMenu(Offset offset, String requestId) async {
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
                  _showConfirmationDialog(context, "disapproved", requestId);
                },
                child: Container(
                    alignment: Alignment.center,
                    width: 80,
                    height: 40,
                    child: Text('Disapprove'))
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
                  Text(
                    operation=="accept"?"Approve Discount ?":"Disapprove Discount ?",
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
                          _changeDiscountStatus("approved", selectedOption, _controller.text, requestId);
                          debugPrint("accepting discount request");

                        }else if(operation=="reject"){
                          _changeDiscountStatus("reject", selectedOption, _controller.text, requestId);
                          debugPrint("rejecting discount request");

                        }else{
                          _changeDiscountStatus("disapproved", selectedOption, _controller.text, requestId);
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

  void _changeDiscountStatus(String status, String confirmation, String confirmationValue, String requestId) async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();

    Map<String, String> requestBody = {
      'active_session': sessionToken,
      'status' : status,
      'confirmation' : confirmation,
      'confirmationValue' : confirmationValue,
      'request_id' : requestId,
    };

    debugPrint("${requestBody}");
    modulesResponse =
    await http.post(GConstants.getChangeDiscountStatusRoute(await AppData().getSchoolUrl()), body: requestBody);

    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          hideProgressDialog();
          setState(() {
            isLoading = false;
          });
          _loadDiscountRequests(0, limit);
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

  Widget contentTable(index, studentClass, creator, reason) => Padding(
        padding: EdgeInsets.all(0),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
          },
          children: <TableRow>[]..addAll(contentData.map<TableRow>((Map<String, String> d) {
              var theKey = d.keys.toList()[0];
              return _buildItemRow(d[theKey], _studentList[index][theKey].toString());
            })),
        ),
      );

  TableRow _buildItemRow(String left, String right) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            right,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  bool getOptionButtonVisibility(int position) {
    if(_selectedStatusType["key"] == "pending"){
      return true;
    }else if(_selectedStatusType["key"] == "approved"){
      if(_studentList[position]["applied_status"]==1){
          return false;
          //processed :Yes
      }else{
        return true;
        // processed: No
      }
    }else if(_selectedStatusType["key"] == "approved_processed"){
      return false;
    }else if(_selectedStatusType["key"] == "disapproved"){
      return false;
    }else{
      return true;
    }

  }
}

