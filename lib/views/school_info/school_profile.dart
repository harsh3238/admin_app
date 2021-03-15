import 'dart:convert';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/splash/splash_screen.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SchoolProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SchoolProfileState();
  }
}

class SchoolProfileState extends State<SchoolProfile> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  var deviceSize;
  int currentlyViewedColumn = 0;
  Map<String, dynamic> _profileData;
  Map<String, String> personalInfoData = Map();
  Map<String, String> classInfoData = Map();
  Map<String, String> contactInfoData = Map();
  Map<String, String> schoolInfoData = Map();
  Map<String, String> schoolData = Map();
  bool _didGetData = false;


  void _getSchoolInfo() async {
    String sessionToken = await AppData().getSessionToken();

    var schoolInfoRs = await http.post(GConstants.getSchoolInfoRoute(await AppData().getSchoolUrl()),
        body: {
          'active_session': sessionToken,
        });

    debugPrint("${schoolInfoRs.request} : ${schoolInfoRs.body}");

    if (schoolInfoRs.statusCode == 200) {
      Map schoolInfoRsObject = json.decode(schoolInfoRs.body);
      if (schoolInfoRsObject.containsKey("status")) {
        if (schoolInfoRsObject["status"] == "success") {
          Map<String, dynamic> modulesData = schoolInfoRsObject['data'];

          schoolData['logo_path'] = modulesData['logo_path'] ?? '';
          schoolData['school_name'] = modulesData['school_name'] ?? '';

          schoolInfoData['Affiliation No'] = modulesData['affiliation_no'] ?? '';
          schoolInfoData['School Code'] = modulesData['school_code'] ?? '';
          schoolInfoData['Contact No'] = modulesData['contact_no'] ?? '';
          schoolInfoData['Email Id'] = modulesData['email'] ?? '';
          schoolInfoData['Address'] = modulesData['address'] ?? '';
          setState(() {});

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



  //Column1
  Widget profileColumn() => Container(
    height: deviceSize.height * 0.24,
    child: FittedBox(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                  new BorderRadius.all(new Radius.circular(60.0)),
                  border: new Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: schoolData['logo_path'] != null
                      ? NetworkImage(schoolData['logo_path'])
                      : AssetImage("assets/profile.png"),
                  foregroundColor: Colors.black,
                  radius: 60.0,
                ),
              ),
            ),
            ProfileTile(
              title:
              schoolData.containsKey('school_name') ? schoolData['school_name'] : '',
              subtitle: "",
            ),
          ],
        ),
      ),
    ),
  );

  //column2

  Widget bodyData() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          profileColumn(),
          tabColumn(deviceSize),
          getActiveColumn(),
        ],
      ),
    );
  }

  Widget _scaffold() => Scaffold(
    key: _scaffoldState,
    appBar: AppBar(
      title: Text("School Info"),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
         if(schoolInfoData['Contact No']!=null){
           await launch(
               "https://wa.me/91${schoolInfoData['Contact No']}");
         }
      },
      child: Icon(
        FontAwesomeIcons.whatsapp,
        color: Colors.white,
      ),
      backgroundColor: Colors.green,
    ),
    body: bodyData(),
  );

  Widget tabColumn(Size deviceSize) => Padding(
    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
    child: Container(
      height: deviceSize.height * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            child: Text("School Info"),
            onPressed: () {
              setState(() {
                currentlyViewedColumn = 0;
              });
            },
            color: currentlyViewedColumn == 0
                ? Colors.grey.shade500
                : Colors.transparent,
          ),
          FlatButton(
            child: Text("About School"),
            onPressed: () {
              setState(() {
                currentlyViewedColumn = 1;
              });
            },
            color: currentlyViewedColumn == 1
                ? Colors.grey.shade500
                : Colors.transparent,
          ),
        ],
      ),
      color: Colors.grey.shade300,
    ),
  );

  Widget personalInfoColumn() => Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          child: Text("School Info"),
          onPressed: () {},
        ),
        FlatButton(
          child: Text("About School"),
          onPressed: () {},
        ),
      ],
    ),
  );

  Widget theInfoTable() => Padding(
    padding: EdgeInsets.all(20),
    child: Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
      },
      children: <TableRow>[]
        ..addAll(schoolInfoData.keys.map<TableRow>((keyName) {
          return _buildItemRow(keyName, schoolInfoData[keyName]);
        })),
      border: TableBorder.all(color: Colors.grey.shade300),
    ),
  );

  Widget theClassInfoTable() => Padding(
    padding: EdgeInsets.all(20),
    child: Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
      },
      children: <TableRow>[]
        ..addAll(classInfoData.keys.map<TableRow>((keyName) {
          return _buildItemRow(keyName, classInfoData[keyName]);
        })),
      border: TableBorder.all(color: Colors.grey.shade300),
    ),
  );

  Widget theContactInfoTable() => Padding(
    padding: EdgeInsets.all(20),
    child: Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
      },
      children: <TableRow>[]
        ..addAll(contactInfoData.keys.map<TableRow>((keyName) {
          return _buildItemRow(keyName, contactInfoData[keyName]);
        })),
      border: TableBorder.all(color: Colors.grey.shade300),
    ),
  );

  TableRow _buildItemRow(String left, String right) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            right != null ? right : '',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget getActiveColumn() {
    switch (currentlyViewedColumn) {
      case 1:
        return theClassInfoTable();
      case 2:
        return theContactInfoTable();
      default:
        return theInfoTable();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _getSchoolInfo();
      });
      _didGetData = true;
    }
    deviceSize = MediaQuery.of(context).size;
    return _scaffold();
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState);
  }
}
