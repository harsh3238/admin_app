import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';

class ActiveTasks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateActiveTasks();
  }
}

class StateActiveTasks extends State<ActiveTasks> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: ListView.builder(
          itemBuilder: (BuildContext context, int i) {
            return ListTile(
              leading: Radio(value: null, groupValue: null, onChanged: (nV){

              }),
              title: Text("Shiv Kumar"),
              subtitle: Text("2020-03-16 at 8:30 PM"),
              dense: true,
            );
          },
          itemCount: 20,
        )),
        Container(
          height: 60,
          padding: EdgeInsets.all(6),
          color: Colors.grey.shade300,
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "I want to..",
                      hasFloatingPlaceholder: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 0,
                            style: BorderStyle.none),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                  maxLines: 1,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              FloatingActionButton(
                child: Icon(Icons.add),
                elevation: 0,
                heroTag: null,
                mini: true,
              )
            ],
          ),
        )
      ],
    );
  }
}
