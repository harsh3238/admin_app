import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_all_class_section.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/fee/dues_filter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class StudentLedger extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStudentLedger();
  }
}

class StateStudentLedger extends State<StudentLedger> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  int _page_no = 0;
  int _limit = 10;
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isNoData = true;
  List<dynamic> _studentList = [];
  List<dynamic> _classList = [];
  List<dynamic> _sectionList = [];
  int _filterClassId, _filterSectionId;

  List<Map<String, String>> contentData = [
    {"student_name": "Student Name : "},
    {"class_name": "Class : "},
    {"total_fee": "Total Fee : "},
    {"arrears": "Arrears : "},
    {"other_fee": "Other Fee: "},
    {"concession": "Concession : "},
    {"gross_fee": "Gross Fee : "},
    {"total_discount": "Discount : "},
    {"payable_amount": "Payable Amount : "},
    {"paid_amount": "Paid Amount : "},
    {"balance": "Balance : "},
  ];

  void _loadStudentData(int pageNo, int limit) async {
    showProgressDialog();
    var modulesResponse;
    String sessionToken = await AppData().getSessionToken();
    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    Map requestBody = {
      'session_id': activeSession.sessionId.toString(),
      'page_number': pageNo.toString(),
      'number_of_items': limit.toString(),
      'active_session': sessionToken,
    };

    if(_filterClassId!=null){
      requestBody.putIfAbsent("class_id", () => _filterClassId.toString());
    }
    if(_filterSectionId!=null){
      requestBody.putIfAbsent("section_id", () => _filterSectionId.toString());
    }

    modulesResponse = await http.post(GConstants.getStudentLedgerRoute(
        await AppData().getSchoolUrl()), body: requestBody);

    debugPrint("${requestBody}");
    log("${modulesResponse.request} ; ${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("success")) {
        if (modulesResponseObject["success"] == true) {
          List<dynamic> data = modulesResponseObject['data'];
          if(pageNo==0){
            _studentList.clear();
            setState(() {
            });
          }

          _studentList.addAll(data);
          if (pageNo==0 && data.length == 0) {
            _studentList.clear();
            _isNoData = true;
            StateHelper().showShortToast(context, "No Data Available");
          }
          hideProgressDialog();
          setState(() {
            _isLoading=false;
          });
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

  void _getAllClassesAndSections() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getAllClassesAndSectionRoute(await AppData().getSchoolUrl()),
        body: {
          'active_session': sessionToken,
        });

    log("${allClassesResponse.request} ; ${allClassesResponse.body}");

    if (allClassesResponse.statusCode == 200) {
      hideProgressDialog();
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _classList = allClassesObject['data']['class'];
          _sectionList = allClassesObject['data']['sections'];
          //await DBAllClassSection.db.insertClassesSections(classes, sections);
          _loadStudentData(0, _limit);
        } else{
          StateHelper().showShortToast(context, "Unable to get filter data");
        }
      }
    }else{
      hideProgressDialog();
      StateHelper().showShortToast(context, "Unable to get filter data");
    }
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
        _getAllClassesAndSections();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Student Ledger"),
        actions: <Widget>[
          GestureDetector(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text("FILTER", style: TextStyle(fontSize: 16)),
                ),
                ImageIcon(
                  AssetImage("assets/sort.png"),
                  size: 18,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    DuesFilter(_classList, _sectionList,_filterClassId, _filterSectionId),
              ).then((onValue) {
                if(onValue!=null){
                  _filterClassId = onValue[0];
                  _filterSectionId = onValue[1];
                  _page_no=0;
                  _loadStudentData(0, _limit);
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: <Widget>[
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!_isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    if (_isSearching) {
                      return true;
                    }
                    setState(() {
                      _isLoading = true;
                      _page_no++;
                    });
                    _loadStudentData(_page_no, _limit);
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
                                          child: Text(
                                            "S.R. No.: " + _studentList[index]["s_r_no"],
                                            style: TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    width: double.infinity,
                                    color: Colors.indigo,
                                  ),
                                  contentTable(index)
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
              height: _isLoading ? 50.0 : 0,
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

  Widget contentTable(index) => Padding(
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
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({Key key, this.child, this.labelText, this.valueText, this.valueStyle, this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: new UnderlineInputBorder(borderSide: new BorderSide(color: Colors.transparent)),
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
