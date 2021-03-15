import 'package:flutter/material.dart';

enum SortBy { name, rollno }
enum SortOrder { asc, desc }

class StudentHeadwiseFilter extends StatefulWidget {
  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  StudentHeadwiseFilter();

  @override
  State<StatefulWidget> createState() {
    return StudentHeadwiseFilterState();
  }
}

class StudentHeadwiseFilterState extends State<StudentHeadwiseFilter> {
  String _selectedUser;

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
                  child: DropdownButton<String>(
                    items:["option 1","option 2","option 3"]
                        .map((b) =>
                        DropdownMenuItem<String>(
                          child: Text(
                            b,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {
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
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            children: <Widget>[
              Text("Class : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items:["option 1","option 2","option 3"]
                        .map((b) =>
                        DropdownMenuItem<String>(
                          child: Text(
                            b,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {
                      setState(() {
                        _selectedUser = b;
                      });
                    },
                    hint: Text(
                      'Select Class',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: _selectedUser,
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            children: <Widget>[
              Text("Payment Mode : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items:["Cash","Check","Online"]
                        .map((b) =>
                        DropdownMenuItem<String>(
                          child: Text(
                            b,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {
                      setState(() {
                        _selectedUser = b;
                      });
                    },
                    hint: Text(
                      'Select Payment Mode',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: _selectedUser,
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            children: <Widget>[
              Text("Receipt Type : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items:["option 1","option 2","option 3"]
                        .map((b) =>
                        DropdownMenuItem<String>(
                          child: Text(
                            b,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {
                      setState(() {
                        _selectedUser = b;
                      });
                    },
                    hint: Text(
                      'Select Receipt Type',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    value: _selectedUser,
                  ))
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            children: <Widget>[
              Text("Residence : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items:["option 1","option 2","option 3"]
                        .map((b) =>
                        DropdownMenuItem<String>(
                          child: Text(
                            b,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          value: b,
                        ))
                        .toList(),
                    onChanged: (b) {
                      setState(() {
                        _selectedUser = b;
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
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: (){
                  Navigator.pop(context, [widget._sortBy, widget._sortOrder]);
                },
                disabledColor: Colors.indigo,
                color: Colors.indigoAccent,
                child: Text(
                  "Apply",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                width: 20,
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
