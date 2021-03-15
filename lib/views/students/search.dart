import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'student_detail/students_detail_main.dart';

class SearchList extends StatefulWidget {
  SearchList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchState();
}

class _SearchState extends State<SearchList> {
  final key = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();
  bool _isSearching = false;
  String _error;
  List<dynamic> _results = List();

  Timer debounceTimer;

  Future<List<dynamic>> _getStudents(String qry) async {

    var newActiveSession = await SessionDbProvider().getActiveSession();
    String sessionToken = await AppData().getSessionToken();

    var studentsResponse = await http.post(
        GConstants.getSearchStudentRoute(await AppData().getSchoolUrl()),
        body: {'query': qry, 'session_id': newActiveSession.sessionId.toString(), 'active_session': sessionToken,});

    log("${studentsResponse.request}:${studentsResponse.body}");

    if (studentsResponse.statusCode == 200) {
      Map studentsObject = json.decode(studentsResponse.body);
      if (studentsObject.containsKey("status")) {
        if (studentsObject["status"] == "success") {
          return studentsObject['data'];
        }
      }
    }
    return [];
  }

  _SearchState() {
    _searchQuery.addListener(() {
      if (debounceTimer != null) {
        debounceTimer.cancel();
      }
      debounceTimer = Timer(Duration(milliseconds: 500), () {
        if (this.mounted) {
          performSearch(_searchQuery.text);
        }
      });
    });
  }

  void performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _error = null;
        _results = List();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
      _results = List();
    });

    final repos = await _getStudents(query);

    if (this._searchQuery.text == query && this.mounted) {
      setState(() {
        _isSearching = false;
        if (repos != null) {
          _results = repos;
        } else {
          _error = 'Error searching';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          centerTitle: true,
          title: TextField(
            autofocus: true,
            controller: _searchQuery,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Searching...",
                hintStyle: TextStyle(color: Colors.white)),
          ),
        ),
        body: buildBody(context));
  }

  Widget buildBody(BuildContext context) {
    if (_isSearching) {
      return CenterTitle('Searching...');
    } else if (_error != null) {
      return CenterTitle(_error);
    } else if (_searchQuery.text.isEmpty) {
      return CenterTitle('Begin Search by typing on search bar');
    } else {
      return ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              child: Row(
                children: <Widget>[
                  Text(
                    "S. R. No.",
                    style: TextStyle(color: Colors.indigo),
                  ),
                  Text(
                    "Student Name",
                    style: TextStyle(color: Colors.indigo),
                  ),
                  Text(
                    "Class",
                    style: TextStyle(color: Colors.indigo),
                  ),
                  Text(
                    "Section",
                    style: TextStyle(color: Colors.indigo),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              color: Colors.white,
              padding: EdgeInsets.all(4),
            );
          }
          return GestureDetector(
            onTap: (){
              //StateHelper().showShortToast(context, _results[index - 1]['s_r_no'].toString());
              navigateToModule(StudentsDetailMain(_results[index - 1]));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _results[index - 1]['s_r_no'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _results[index - 1]['name']!=null?_results[index - 1]['name']:"-",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _results[index - 1]['class']!=null?_results[index - 1]['class']:"-",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _results[index - 1]['section']!=null?_results[index - 1]['section']:"-",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          );
        },
        itemCount: _results.length + 1,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      );
    }
  }
  void navigateToModule(Widget module) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        body: module,
      );
    }));
  }


}

class CenterTitle extends StatelessWidget {
  final String title;

  CenterTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        alignment: Alignment.center,
        child: Text(
          title,
          style: Theme.of(context).textTheme.body2,
          textAlign: TextAlign.center,
        ));
  }
}
