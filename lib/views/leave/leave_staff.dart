import 'package:flutter/material.dart';

class LeaveStaff extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LeaveState();
  }
}

class LeaveState extends State<LeaveStaff> {
  List<String> contentData = [
    "Reason",
    "Date From",
    "Date To",
    "Date Applied",
    "Status"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Applications"),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(8),
        separatorBuilder: (context, position) {
          return Container(
            height: 8,
          );
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Mr. Nitish Gaur",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    width: double.infinity,
                    color: Colors.grey.shade700,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
                    child: Text(
                      "Ma'am, I am unable to attend the school today due to health issues, please grant me leave for today.",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                    TextSpan(text: "Leave Date : "),
                                    TextSpan(
                                        text: "16-04-2019",
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal))
                                  ]))),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                    TextSpan(text: "Applied at : "),
                                    TextSpan(
                                        text: "12-03-2019 at 6:12 AM",
                                        style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal))
                                  ])))
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 12, 8),
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  children: [
                                TextSpan(text: "Status :   "),
                                TextSpan(
                                    text: "Approved",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        background: Paint()
                                          ..color = Colors.green
                                          ..strokeWidth = 14
                                          ..style = PaintingStyle.stroke
                                          ..strokeJoin = StrokeJoin.round))
                              ])))
                    ],
                  ),
                  Divider(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: ButtonTheme(
                            minWidth: 60.0,
                            height: 30,
                            child: RaisedButton(
                              onPressed: () {},
                              child: Text(
                                "Reject",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 11),
                              ),
                              disabledColor: Colors.grey.shade400,
                              color: Colors.grey.shade400,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: ButtonTheme(
                            minWidth: 60.0,
                            height: 30,
                            child: RaisedButton(
                              onPressed: () {},
                              child: Text(
                                "Approve",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                              disabledColor: Colors.indigo,
                              color: Colors.indigo,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ))
                    ],
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          );
        },
        itemCount: 4,
      ),
    );
  }
}
