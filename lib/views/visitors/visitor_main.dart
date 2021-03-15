import 'package:flutter/material.dart';

class VisitorMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateVisitorMain();
  }
}

class StateVisitorMain extends State<VisitorMain> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Visitors"),
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: <Widget>[
            Container(
              child: GestureDetector(
                child: Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "Filter",
                              style: TextStyle(color: Colors.indigo),
                            ),
                            Text(
                              "16-04-2019",
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 12),
                            )
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text("Total : 8"),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                onTap: () async {
                  DateTime firstDate =
                      DateTime.now().subtract(Duration(minutes: 10));

                  final DateTime picked = await showDatePicker(
                    context: context,
                    initialDate: dateFrom,
                    firstDate: firstDate,
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                },
              ),
              color: Colors.white,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.all(4),
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              width: 100.0,
                              height: 100,
                              child: Image.asset(
                                "assets/main_back.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              child: Center(
                                child: Text(
                                  "LEFT",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              color: Colors.indigo,
                              width: 100,
                              margin: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                            )
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Text(
                                  "Ajeet Singh is visiting Priniciple",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                              Text(
                                "Visitor Mo. : 7854786478",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "Date : 04-04-2019",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "Time : 09:37 AM",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "Left at : 10:05 AM",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "Time Spent. : 00:54:26",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 4,
                  );
                },
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }
}
