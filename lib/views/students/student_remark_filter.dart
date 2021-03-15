import 'package:flutter/material.dart';

class StudentRemarkFilter extends StatefulWidget {

  List<dynamic> _userList = [];
  int filterUserId;
  Map<String, dynamic> _selectedRemarkType;

  StudentRemarkFilter(this._userList, this._selectedRemarkType);

  @override
  State<StatefulWidget> createState() {
    return StudentRemarkFilterState();
  }
}

class StudentRemarkFilterState extends State<StudentRemarkFilter> {

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
          Text("Filter Remarks",
              style: TextStyle(fontSize: 16, color: Colors.black)),
          Divider(),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Text("Category : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    items: widget._userList
                        .map((b) =>
                        DropdownMenuItem<dynamic>(
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
                onPressed: (){
                  Navigator.pop(context, [widget._selectedRemarkType]);
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
