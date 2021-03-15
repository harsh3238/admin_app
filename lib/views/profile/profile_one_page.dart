import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileOnePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileOnePageState();
  }
}

class ProfileOnePageState extends State<ProfileOnePage> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  var deviceSize;
  int currentlyViewedColumn = 0;
  Map<String, dynamic> _profileData;
  Map<String, String> personalInfoData = Map();
  Map<String, String> contactInfoData = Map();
  bool _didGetData = false;

  void _getProfileData() async {
    showProgressDialog();

    int userLoginRowId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var profileResponse = await http.post(GConstants.getProfileRoute(await AppData().getSchoolUrl()), body: {
      'login_row_id': userLoginRowId.toString(),
      'active_session': sessionToken,
    });

    //print(profileResponse.body);

    if (profileResponse.statusCode == 200) {
      Map profileResponseObject = json.decode(profileResponse.body);
      if (profileResponseObject.containsKey("status")) {
        if (profileResponseObject["status"] == "success") {
          hideProgressDialog();
          setState(() {
            ///personal Info
            personalInfoData['Employee ID'] =
                profileResponseObject['data']['employee_id'];
            personalInfoData['Primary Mobile'] =
                profileResponseObject['data']['primary_contact'];
            personalInfoData['Alt. Mobile'] =
            profileResponseObject['data']['phone_no'];
            personalInfoData['Gender'] =
                profileResponseObject['data']['gender'];
            personalInfoData['Martial Status'] =
                profileResponseObject['data']['marital_status'];
            personalInfoData['Designation'] = profileResponseObject['data']['designation'];
            personalInfoData['Department'] = profileResponseObject['data']['department'];

            ///contact info
            contactInfoData['Address'] =
                profileResponseObject['data']['address'];
            contactInfoData['City'] = profileResponseObject['data']['city'];
            contactInfoData['State'] = profileResponseObject['data']['state'];
            contactInfoData['Country'] =
                profileResponseObject['data']['country'] ?? '';

            _profileData = profileResponseObject['data'];
          });
          return null;
        } else {
          showSnackBar(profileResponseObject["message"]);
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
                      backgroundImage: _profileData != null
                          ? (_profileData['emp_photo'] != null
                              ? NetworkImage(_profileData['emp_photo'])
                              : AssetImage("assets/profile.png"))
                          :  AssetImage("assets/profile.png"),
                      foregroundColor: Colors.black,
                      radius: 60.0,
                    ),
                  ),
                ),
                ProfileTile(
                  title:
                      _profileData != null ? _profileData['name'] : '',
                  subtitle: _profileData != null
                      ? "Employee ID : ${_profileData['employee_id']}"
                      : '',
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
          getActiveColumn()
        ],
      ),
    );
  }

  Widget _scaffold() => Scaffold(
        key: _scaffoldState,
        body: bodyData(),
        appBar: AppBar(
          title: Text("Profile"),
        ),
      );

  Widget tabColumn(Size deviceSize) => Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
          height: deviceSize.height * 0.06,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text("Personal Info"),
                onPressed: () {
                  setState(() {
                    currentlyViewedColumn = 0;
                  });
                },
              ),
              FlatButton(
                child: Text("Contact Info"),
                onPressed: () {
                  setState(() {
                    currentlyViewedColumn = 1;
                  });
                },
              )
            ],
          ),
          color: Colors.grey.shade300,
        ),
      );

  Widget theInfoTable() => Padding(
        padding: EdgeInsets.all(20),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
          },
          children: <TableRow>[]
            ..addAll(personalInfoData.keys.map<TableRow>((keyName) {
              return _buildItemRow(keyName, personalInfoData[keyName]);
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
            right,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget getActiveColumn() {
    switch (currentlyViewedColumn) {
      case 1:
        return theContactInfoTable();
      default:
        return theInfoTable();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _getProfileData();
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
