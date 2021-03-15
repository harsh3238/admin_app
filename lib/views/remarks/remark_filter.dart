import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:flutter/material.dart';

class RemarkFilter extends StatefulWidget {
  int classId, sectionId;
  List<dynamic> _userList = [];
  Map<String, dynamic> _selectedRemarkType;

  RemarkFilter(this._userList, this._selectedRemarkType, this.classId, this.sectionId);

  @override
  State<StatefulWidget> createState() {
    return RemarkFilterState();
  }
}

class RemarkFilterState extends State<RemarkFilter> {
  List<Map<String, dynamic>> _allClasses = List();
  List<Map<String, dynamic>> _allSections = List();
  bool _didGetData = false;

  void populateSpinners() async {
    _allClasses = await DbClassSection().getAllClasses();
    if(widget.classId != null && widget.sectionId != null){
      _allSections = await DbClassSection().getSectionsByClassId(widget.classId);
    }
    setState(() {});
  }

  void getSectionsForClass(int classId) async {
    widget.sectionId = null;
    _allSections = await DbClassSection().getSectionsByClassId(classId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        populateSpinners();
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
              Text("Class : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: widget.classId,
                    items: _allClasses
                        .map((b) => DropdownMenuItem<int>(
                      child: Text(
                        "${b['class_name']}",
                        style: TextStyle(
                            color: Colors.black, inherit: false),
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
                        widget.classId = _allClasses
                            .where((Map<String, dynamic> item) =>
                        item['id'] == b)
                            .toList()[0]['id'];
                      });
                      getSectionsForClass(widget.classId);
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
              Text("Section : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: widget.sectionId,
                    items: _allSections
                        .map((b) => DropdownMenuItem<int>(
                      child: Text(
                        "${b['sec_name']}",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      value: b['id'],
                    ))
                        .toList(),
                    onChanged: (b) {
                      setState(() {
                        widget.sectionId = _allSections
                            .where((Map<String, dynamic> item) =>
                        item['id'] == b)
                            .toList()[0]['id'];
                      });
                    },
                    hint: Text(
                      'Select Section',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          Row(
            children: <Widget>[
              Text("Category : ", style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    items: widget._userList
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
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context, [widget._selectedRemarkType, widget.classId, widget.sectionId]);
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
