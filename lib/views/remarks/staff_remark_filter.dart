import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StaffRemarkFilter extends StatefulWidget {
  List<dynamic> _remarkTypeList = [];
  List<dynamic> _deptList = [];
  List<dynamic> _empList = [];
  Map<String, dynamic> _selectedRemarkType;
  Map<String, dynamic> _selectedDepartment;
  Map<String, dynamic> _selectedEmployee;

  StaffRemarkFilter(this._remarkTypeList, this._selectedRemarkType, this._deptList,
      this._selectedDepartment, this._selectedEmployee);

  @override
  State<StatefulWidget> createState() {
    return StaffRemarkFilterState();
  }
}

class StaffRemarkFilterState extends State<StaffRemarkFilter> {
  bool _didGetData = false;


  Future<void> _getStaff() async {

    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getStaffByDepartmentRoute(await AppData().getSchoolUrl()),
        body: {'department_id': widget._selectedDepartment['id'].toString(), 'active_session': sessionToken,});

    log("${modulesResponse.request} : ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> data = modulesResponseObject['data'];
          widget._empList.clear();
          data.forEach((theItem) {
            widget._empList.add(theItem);
          });

          setState(() {});
          return null;
        } else {
          return null;
        }
      } else {
      }
    } else {
    }
  }



  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        if(widget._selectedDepartment!=null){
          setState(() {
            widget._selectedEmployee=null;
          });
          _getStaff();
        }
      });
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: _buildPlayer(),
        ),
      ],
    );
  }

  Widget _buildPlayer() => Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Filter Records",
              style: TextStyle(fontSize: 16, color: Colors.black)),
          Divider(),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Text("Category : ", style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    items: widget._remarkTypeList
                        .map((b) => DropdownMenuItem<dynamic>(
                      child: Text(
                        b['remark'],
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      value: b,
                    ))
                        .toList(),
                    onChanged: (b) {
                      if (b == widget._selectedRemarkType) {
                        return;
                      }
                      setState(() {
                        widget._selectedRemarkType = b;
                      });
                    },
                    hint: Text(
                      'Select Remark Type',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: widget._selectedRemarkType,
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          Row(
            children: <Widget>[
              Text("Dept. : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    value: widget._selectedDepartment,
                    items: widget._deptList
                        .map((b) => DropdownMenuItem<dynamic>(
                      child: Text(
                        b['name'],
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      value: b,
                    ))
                        .toList(),
                    hint: Text(
                      'Select Department',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    onChanged: (b) {

                      if(widget._selectedDepartment == b){
                        return;
                      }
                      widget._empList.clear();
                      widget._selectedEmployee = null;
                      setState(() {
                        widget._selectedDepartment = b;
                      });
                      _getStaff();
                    },
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          Row(
            children: <Widget>[
              Text("Employee : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    value: widget._selectedEmployee,
                    items: widget._empList
                        .map((b) => DropdownMenuItem<dynamic>(
                      child: SizedBox(
                        width: 150,
                        child: Text(
                          b['name'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      value: b,
                    ))
                        .toList(),
                    onChanged: (b) {
                      setState(() {
                        widget._selectedEmployee = b;
                      });
                    },
                    hint: Text(
                      'Select Employee',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context, [widget._selectedRemarkType, widget._selectedDepartment, widget._selectedEmployee]);
                },
                disabledColor: Colors.indigo,
                color: Colors.indigoAccent,
                child: Text(
                  "Apply",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                width: 30,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                disabledColor: Colors.indigo,
                color: Colors.indigoAccent,
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ],
      ));
}
