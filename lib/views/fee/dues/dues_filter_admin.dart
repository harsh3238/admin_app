import 'package:click_campus_admin/data/db_all_class_section.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:flutter/material.dart';

class DuesFilterAdmin extends StatefulWidget {
  int classId, sectionId, modeId;
  List<dynamic> _allClasses = [];
  List<dynamic> _allSectionsForClass = [];
  List<dynamic> _allSections = [];
  List<dynamic> _allModes = [];
  List<dynamic> _reportTypeList = [];
  Map<String, dynamic> _filteredReportType;

  DuesFilterAdmin(this._allModes, this._allClasses, this._allSections, this._reportTypeList,
      this.modeId, this.classId, this.sectionId, this._filteredReportType);

  @override
  State<StatefulWidget> createState() {
    return DuesFilterAdminState();
  }

}

class DuesFilterAdminState extends State<DuesFilterAdmin> {
  //List<Map<String, dynamic>> _allClasses = List();
  //List<Map<String, dynamic>> _allSections = List();
  bool _didGetData = false;

  void populateSpinners() async {
    //_allClasses = await DBAllClassSection.db.getAllClasses();
    if(widget.classId != null && widget.sectionId != null){
      widget._allSectionsForClass = [];
      for(final item in widget._allSections){
        if(item["class_id"]== widget.classId){
          widget._allSectionsForClass.add(item);
        }
      }
    }
    setState(() {});
  }

  void getSectionsForClass(int classId) async {
    if(classId==null){
      return;
    }
    debugPrint("CLASS_ID:"+classId.toString());
    widget.sectionId = null;
    widget._allSectionsForClass = [];
    //_allSections = await DBAllClassSection.db.getSectionsByClassId(classId);
    for(final item in widget._allSections){
          if(item["class_id"]== classId){
            widget._allSectionsForClass.add(item);
          }
    }
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
        mainAxisAlignment: MainAxisAlignment.center,
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
              Text("Mode : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: widget.modeId,
                    items: widget._allModes
                        .map((b) => DropdownMenuItem<int>(
                      child: Text(
                        "Mode ${b['fee_mode_name']}",
                        style: TextStyle(
                            color: Colors.black, inherit: false),
                      ),
                      value: b['id'],
                    ))
                        .toList(),
                    hint: Text(
                      'Select Mode',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    onChanged: (b) {
                      if(widget.modeId==b){
                        return;
                      }
                      setState(() {
                        widget.modeId = b;
                      });

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
              Text("Class : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: widget.classId,
                    items: widget._allClasses
                        .map((b) => DropdownMenuItem<int>(
                      child: Text(
                        "Class ${b['class_name']}",
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
                      if(widget.classId==b){
                        return;
                      }
                      widget._allSectionsForClass = [];
                      setState(() {
                        widget.classId = b;
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
                    items: widget._allSectionsForClass
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
                    onChanged: (value) {
                      if(widget.sectionId==value){
                        return;
                      }
                      setState(() {
                        widget.sectionId = value;
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
              Text("Report : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    items:widget._reportTypeList
                        .map((b) =>
                        DropdownMenuItem<dynamic>(
                          child: Text(
                            b["value"],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {

                      if(b == widget._filteredReportType){
                        return;
                      }
                      setState(() {
                        widget._filteredReportType = b;
                      });
                    },
                    hint: Text(
                      'Select Report',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: widget._filteredReportType,
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
                onPressed: (){
                  Navigator.pop(context, [widget.modeId, widget.classId, widget.sectionId, widget._filteredReportType]);
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
                onPressed: (){
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
          ),
        ],
      ));
}
