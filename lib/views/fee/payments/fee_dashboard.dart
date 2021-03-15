import 'package:flutter/material.dart';

class FeeDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateFeeDashboard();
  }
}

class StateFeeDashboard extends State<FeeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
              child: Column(
                children: <Widget>[
                  Text(
                    "Today's Collection",
                    style: TextStyle(color: Colors.indigo, fontSize: 12),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "₹ 234354",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
              child: Column(
                children: <Widget>[
                  Text(
                    "Yesterday's Collection",
                    style: TextStyle(color: Colors.indigo, fontSize: 12),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "₹ 4354353",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
              child: Column(
                children: <Widget>[
                  Text(
                    "Months's Collection",
                    style: TextStyle(color: Colors.indigo, fontSize: 12),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "₹ 9789768987",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }
}
