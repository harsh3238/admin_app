import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../state_helper.dart';

class StudentExams extends StatefulWidget {
  final String stucareId;
  final List<dynamic> _examTerms;

  StudentExams(this.stucareId, this._examTerms);

  @override
  State<StatefulWidget> createState() {
    return StudentExamsState();
  }
}

class StudentExamsState extends State<StudentExams> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  Map<String, dynamic> _selectedTerm;

  List<dynamic> _examMarksData = [];

  void _getExamMarks(String termId) async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    if(activeSession==null || activeSession.sessionId==null){
      StateHelper().showShortToast(context, "Please Select Active Session");
      return;
    }

    var examMarksResponse = await http.post(
        GConstants.getStudentExamDateRoute(await AppData().getSchoolUrl()),
        body: {
          'stucare_id': widget.stucareId,
          'session_id': activeSession.sessionId.toString(),
          'term_id': termId,
          'active_session': sessionToken,
        });

    //print(examMarksResponse.body);

    if (examMarksResponse.statusCode == 200) {
      Map marksObject = json.decode(examMarksResponse.body);
      if (marksObject.containsKey("status")) {
        if (marksObject["status"] == "success") {
          setState(() {
            _examMarksData = marksObject['exams'];
          });
          hideProgressDialog();
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(marksObject["message"]);
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

  Widget _scaffold() => Scaffold(
        key: _scaffoldState,
        body: Column(children: <Widget>[
          Container(
            child: Theme(
                data: Theme.of(context).copyWith(brightness: Brightness.dark),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<dynamic>(
                  items: widget._examTerms
                      .map((b) => DropdownMenuItem<dynamic>(
                            child: Text(
                              b['term_name'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            value: b,
                          ))
                      .toList(),
                  onChanged: (b) {
                    if (b == _selectedTerm) {
                      return;
                    }

                    setState(() {
                      _selectedTerm = b;
                    });
                    _getExamMarks(_selectedTerm['id']);
                  },
                  hint: Text(
                    'Select Term',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  value: _selectedTerm,
                  isExpanded: true,
                ))),
            color: Colors.indigo,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          ),
          Expanded(
              child: CustomScrollView(
            slivers: _examMarksData.map((examItem) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: Column(
                    children: <Widget>[
                      Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.grey.shade300,
                          child: Text(examItem['exam_name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                              textAlign: TextAlign.center)),
                      Table(
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(1)
                          },
                          children: getExamRows(examItem),
                          border: TableBorder.all(color: Colors.grey.shade300))
                    ],
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  ),
                ),
              );
            }).toList(),
          ))
        ]),
      );

  List<TableRow> getExamRows(Map<String, dynamic> exam) {
    List<TableRow> listToReturn = [];

    listToReturn.add(TableRow(children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Text(
          'Subjet Name',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey.shade900),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Text(
          'Max. Marks',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey.shade900),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Text(
          'Marks/Grade',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey.shade900),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        child: Text(
          'Practical',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey.shade900),
          textAlign: TextAlign.center,
        ),
      ),
    ]));

    listToReturn.addAll(exam['marks'].map<TableRow>((marks) {
      return _buildItemRowWithPractical(marks);
    }));
    return listToReturn;
  }

  TableRow _buildItemRowWithPractical(Map<String, dynamic> marks) {
    return TableRow(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.transparent,
          child: Text(
            marks['subject_name'],
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.transparent,
          child: Text(
            marks['max_marks'] == null
                ? marks['marks_type'] == 'grade' ? 'Grade' : 'NA'
                : marks['max_marks'],
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.transparent,
          child: Text(
            marks['marks'] ?? '',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.transparent,
          child: Text(
            int.tryParse(marks['practical']) == 1
                ? marks['practical_marks'] ?? ''
                : 'NA',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _scaffold();
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }
}
