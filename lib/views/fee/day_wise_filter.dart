import 'package:flutter/material.dart';

class DayWiseFilter extends StatefulWidget {

  List<dynamic> _userList = [];
  List<dynamic> _classList = [];
  List<dynamic> _residenceList = [];

  DayWiseFilter(this._userList, this._classList, this._residenceList);

  @override
  State<StatefulWidget> createState() {
    return DayWiseFilterState();
  }
}

class DayWiseFilterState extends State<DayWiseFilter> {
  Map<String, dynamic> _selectedUser;
  Map<String, dynamic> _selectedClass;
  Map<String, dynamic> _selectedResidence;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text("Filter Data",
              style: TextStyle(fontSize: 16, color: Colors.black)),
          Divider(),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Text("User : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    items:widget._userList
                        .map((b) =>
                        DropdownMenuItem<dynamic>(
                          child: Text(
                            b['name'],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {

                      if (b == _selectedUser) {
                        return;
                      }
                      setState(() {
                        _selectedUser = b;
                      });
                    },
                    hint: Text(
                      'Select User',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: _selectedUser,
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
                  child: DropdownButton<dynamic>(
                    items:widget._classList
                        .map((b) =>
                        DropdownMenuItem<dynamic>(
                          child: Text(
                            b["class_name"],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {

                      if(b == _selectedClass){
                        return;
                      }
                      setState(() {
                        _selectedClass = b;
                      });
                    },
                    hint: Text(
                      'Select Class',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: _selectedClass,
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          Row(
            children: <Widget>[
              Text("Residence : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    items:widget._residenceList
                        .map((b) =>
                        DropdownMenuItem<dynamic>(
                          child: Text(
                            b["name"],
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {
                      setState(() {
                        _selectedResidence = b;
                      });
                    },
                    hint: Text(
                      'Select Reference',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: _selectedUser,
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
                  Navigator.pop(context, [_selectedUser, _selectedClass, _selectedResidence]);
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
          )
        ],
      ));
}
