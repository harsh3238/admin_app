import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/widgets/profile_tile.dart';
import 'package:flutter/material.dart';

import '../../state_helper.dart';

class StudentProfile extends StatefulWidget {
  final String stucareId;
  final Map<String, dynamic> _profileData;

  StudentProfile(this.stucareId, this._profileData);

  @override
  State<StatefulWidget> createState() {
    return StudentProfileState();
  }
}

class StudentProfileState extends State<StudentProfile> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _firstRunRoutineRan = false;
  var deviceSize;
  int currentlyViewedColumn = 0;

  Map<String, String> personalInfoData = Map();
  Map<String, String> classInfoData = Map();
  Map<String, String> contactInfoData = Map();

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
                      backgroundImage: widget._profileData != null
                          ? (widget._profileData['photo_student'] != null
                              ? NetworkImage(
                                  widget._profileData['photo_student'])
                              : AssetImage("assets/profile.png"))
                          : AssetImage("assets/profile.png"),
                      foregroundColor: Colors.black,
                      radius: 60.0,
                    ),
                  ),
                ),
                ProfileTile(
                  title: widget._profileData != null
                      ? widget._profileData['stu_full_name']
                      : '',
                  subtitle: widget._profileData != null
                      ? "S. R. No. : ${widget._profileData['s_r_no']}"
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
                color: currentlyViewedColumn == 0
                    ? Colors.grey.shade500
                    : Colors.transparent,
              ),
              FlatButton(
                child: Text("Class Info"),
                onPressed: () {
                  setState(() {
                    currentlyViewedColumn = 1;
                  });
                },
                color: currentlyViewedColumn == 1
                    ? Colors.grey.shade500
                    : Colors.transparent,
              ),
              FlatButton(
                child: Text("Contact Info"),
                onPressed: () {
                  setState(() {
                    currentlyViewedColumn = 2;
                  });
                },
                color: currentlyViewedColumn == 2
                    ? Colors.grey.shade500
                    : Colors.transparent,
              )
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
              child: Text("Personal Info"),
              onPressed: () {},
            ),
            FlatButton(
              child: Text("Class Info"),
              onPressed: () {},
            ),
            FlatButton(
              child: Text("Contact Info"),
              onPressed: () {},
            )
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
            ..addAll(personalInfoData.keys.map<TableRow>((keyName) {
              return _buildItemRow(keyName, personalInfoData[keyName]);
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
        return theClassInfoTable();
      case 2:
        return theContactInfoTable();
      default:
        return theInfoTable();
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    if (!_firstRunRoutineRan) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _firstRunRoutineRan = true;
        activeSession = await SessionDbProvider().getActiveSession();
      });
    }
    return _scaffold();
  }

  @override
  void initState() {
    ///personal Info
    personalInfoData['Father'] = widget._profileData['father_full_name'];
    personalInfoData['Mother'] = widget._profileData['mother_full_name'];
    personalInfoData['Gender'] =
        widget._profileData['gender'] == "M" ? "Male" : "Female";
    personalInfoData['Mobile'] = widget._profileData['primary_mobile']?? "Not Available";
    personalInfoData['DOB'] = widget._profileData['dob']?? "Not Available";

    ///class info
    classInfoData['Class'] = widget._profileData['class_name'];
    classInfoData['Section'] = widget._profileData['section_name'];
    classInfoData['Session'] = widget._profileData['session_name'];
    classInfoData['S. R. No.'] = widget._profileData['s_r_no'];
    classInfoData['Roll No.'] = widget._profileData['roll_no'] ?? "Not Available";

    ///contact info
    contactInfoData['Address'] = widget._profileData['p_address']?? "Not Available";
    contactInfoData['City'] = widget._profileData['p_city']?? "Not Available";
    contactInfoData['State'] = widget._profileData['p_state']?? "Not Available";
    contactInfoData['Pin Code'] = widget._profileData['p_postcode']?? "Not Available";

    super.initState();
    super.init(context, _scaffoldState, state: this);
  }
}
