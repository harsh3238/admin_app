import 'package:flutter/material.dart';

enum SortBy { name, rollno }
enum SortOrder { asc, desc }

class SortDialog extends StatefulWidget {
  SortBy _sortBy = SortBy.name;
  SortOrder _sortOrder = SortOrder.asc;

  SortDialog(this._sortBy, this._sortOrder);

  @override
  State<StatefulWidget> createState() {
    return SortDialogState();
  }
}

class SortDialogState extends State<SortDialog> {

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
          Text("Sort Configuration",
              style: TextStyle(fontSize: 16, color: Colors.black)),
          Divider(),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Text("Sort By :      ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              Radio<SortBy>(
                value: SortBy.name,
                groupValue: widget._sortBy,
                onChanged: (SortBy value) {
                  setState(() {
                    widget._sortBy = value;
                  });
                },
              ),
              Text(
                "Name",
                style: TextStyle(fontSize: 11),
              ),
              Radio<SortBy>(
                value: SortBy.rollno,
                groupValue: widget._sortBy,
                onChanged: (SortBy value) {
                  setState(() {
                    widget._sortBy = value;
                  });
                },
              ),
              Text(
                "Roll No.",
                style: TextStyle(fontSize: 11),
              ),
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            children: <Widget>[
              Text("Sort Order : ",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              Radio<SortOrder>(
                value: SortOrder.asc,
                groupValue: widget._sortOrder,
                onChanged: (SortOrder value) {
                  setState(() {
                    widget._sortOrder = value;
                  });
                },
              ),
              Text(
                "Asc.",
                style: TextStyle(fontSize: 11),
              ),
              Radio<SortOrder>(
                value: SortOrder.desc,
                groupValue: widget._sortOrder,
                onChanged: (SortOrder value) {
                  setState(() {
                    widget._sortOrder = value ;
                  });
                },
              ),
              Text(
                "Desc.",
                style: TextStyle(fontSize: 11),
              ),
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          SizedBox(
            height: 10,
          ),
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
          )
        ],
      ));
}
