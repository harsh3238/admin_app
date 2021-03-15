
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'absentees_list.dart';
import 'mark_attendance.dart';

class AbsenteesTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AbsenteesTabState();
  }
}

class AbsenteesTabState extends State<AbsenteesTab> {
  bool _firstRunRoutineRan = false;

  List<Map<String, dynamic>> _allClasses = List();
  List<Map<String, dynamic>> _allSections = List();

  int _selectedClass, _selectedSection;
  String _selectedClassName, _selectedSectionName;

  String _selecteDate = "Select Date";

  void _getAllClassesAndSections() async {
    _firstRunRoutineRan = true;
    _allClasses = await DbClassSection().getAllClasses();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _getAllClassesAndSections();
      });
    }

    return Padding(
      child: Column(
        children: <Widget>[
          Container(
            child: Image.asset(
              "assets/dash_icons/ic_attendance_p.png",
              fit: BoxFit.cover,
              color: Colors.red,
            ),
            width: 70,
            margin: EdgeInsets.all(10),
          ),
          Padding(
            child: Text(
              'Absentees',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
          ),
          DropdownButton<int>(
            isExpanded: true,
            value: _selectedClass,
            items: _allClasses
                .map((b) => DropdownMenuItem<int>(
                      child: Text(
                        "Class ${b['class_name']}",
                        style: TextStyle(color: Colors.black, inherit: false),
                      ),
                      value: b['id'],
                    ))
                .toList(),
            hint: Text(
              'Select Class',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onChanged: (b) {
              _allSections = [];
              setState(() {
                var theClass = _allClasses
                    .where((Map<String, dynamic> item) => item['id'] == b)
                    .toList()[0];
                _selectedClass = theClass['id'];
                _selectedClassName = theClass['class_name'];
              });
              getSectionsForClass(_selectedClass);
            },
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12.0),
          DropdownButton<int>(
            isExpanded: true,
            value: _selectedSection,
            items: _allSections
                .map((b) => DropdownMenuItem<int>(
                      child: Text(
                        "Section ${b['sec_name']}",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      value: b['id'],
                    ))
                .toList(),
            onChanged: (b) {
              setState(() {
                var theSection = _allSections
                    .where((Map<String, dynamic> item) => item['id'] == b)
                    .toList()[0];
                _selectedSection = theSection['id'];
                _selectedSectionName = theSection['sec_name'];
              });
            },
            hint: Text(
              'Select Section',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          GestureDetector(
            child: DropdownButton<int>(
              isExpanded: true,
              items: [],
              onChanged: (b) {},
              hint: Text(
                _selecteDate,
                style: TextStyle(
                  color: _selecteDate == "Select Date" ? Colors.grey : Colors.black,
                ),
              ),
            ),
            onTap: () async {
              final DateTime picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 30)),
                lastDate: DateTime.now().add(Duration(days: 30)),
              );
              if (picked != null) {
                setState(() {
                  _selecteDate =
                      DateFormat().addPattern("yyyy-MM-dd").format(picked);
                });
              }
            },
          ),
          Container(
            height: 20,
          ),
          FlatButton(
            child: Text("SUBMIT"),
            color: Colors.indigo,
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return AbsenteesScreen(_selectedClass, _selectedSection,
                    _selectedClassName, _selectedSectionName, _selecteDate);
              }));
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22))),
            padding: EdgeInsets.symmetric(horizontal: 50),
          )
        ],
      ),
      padding: EdgeInsets.all(40),
    );
  }

  void getSectionsForClass(int classId) async {
    _selectedSection = null;
    _allSections = await DbClassSection().getSectionsByClassId(classId);
    setState(() {});
  }
}
