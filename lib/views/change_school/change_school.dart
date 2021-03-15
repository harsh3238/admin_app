import 'dart:async';

import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';

import '../state_helper.dart';

class ChangeSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MessagesMainState();
  }
}

class MessagesMainState extends State<ChangeSchool> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool didGetData = false;
  List<dynamic> _schoolsData = List();

  Future<void> _getAvailbleSchools() async {
    showProgressDialog();

    var schools = await AppData().getAvailableSchools();
    if (schools.length > 0) {
      schools.keys.forEach((element) {
        _schoolsData.add(schools[element]);
      });
    }
    setState(() {});
    hideProgressDialog();
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    return ListTile(
      title: Text(
        "School ID : ${_schoolsData[index]['schoolId']}",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        "School URL : ${_schoolsData[index]['schoolUrl']}",
        style: TextStyle(fontWeight: FontWeight.bold),
        maxLines: 10,
      ),
      onTap: () async {
        var dialog = AlertDialog(
          title: const Text('Change School?'),
          content: Text(
              "Changing school requires to clear the App's cached data, this e.g. clears the saved attendance data. Are you sure to proceed?"),
          actions: [
            FlatButton(
              child: Text("Yes"),
              textColor: Colors.indigo,
              disabledColor: Colors.indigo,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            FlatButton(
              child: Text("Cancel"),
              textColor: Colors.indigo,
              disabledColor: Colors.indigo,
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
        showDialog(
                context: context,
                builder: (BuildContext context) => dialog,
                barrierDismissible: false)
            .then((value) async {
          if (value) {
            await AppData()
                .setCurrentlyActiveSchool(_schoolsData[index]['schoolId']);
            Navigator.of(context).pop(true);
          }
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    if (!didGetData) {
      didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getAvailbleSchools();
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Change School"),
      ),
      body: ListView.builder(
        itemCount: _schoolsData.length,
        itemBuilder: _buildFriendListTile,
      ),
    );
  }
}
