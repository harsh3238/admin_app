import 'package:flutter/material.dart';

class TeacherTimetable extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateTeacherTimetable();
  }
}

class StateTeacherTimetable extends State<TeacherTimetable> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();

  var data = new Map();

  void createData() {
    data["Maths"] = "Mr. Murari Lal";
    data["English"] = "Mr. Murari Lal";
    data["Hindi"] = "Mr. Murari Lal";
    data["SST"] = "Mr. Murari Lal";
    data["Computer/Sports"] = "Mr. Murari Lal/Ram Mohan Sharma";
    data["Physics"] = "Mr. Murari Lal";
    data["Chemistry"] = "Mr. Murari Lal";
    data["Biology"] = "Mr. Murari Lal";
  }

  @override
  Widget build(BuildContext context) {
    createData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher's Timetable"),
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Theme(
                            data: Theme.of(context)
                                .copyWith(brightness: Brightness.dark),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              items: [1, 2, 3, 4]
                                  .map((b) => DropdownMenuItem<String>(
                                        child: Text(
                                          "Mr. Murari Lal",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        value: "Mr. Murari Lal",
                                      ))
                                  .toList(),
                              onChanged: (b) {},
                              hint: Text(
                                'Select Teacher',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ))),
                      ),
                      const SizedBox(width: 12.0),
                      FlatButton(
                        child: Text(
                          "GO",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        shape: CircleBorder(
                            side: BorderSide(color: Colors.white54)),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                              child: Text(
                                "MON",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            splashColor: Colors.white,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                              child: Text(
                                "TUE",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            splashColor: Colors.white,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                              child: Text(
                                "WED",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            splashColor: Colors.white,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                              child: Text(
                                "THE",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            splashColor: Colors.white,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                              child: Text(
                                "FRI",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            splashColor: Colors.white,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: Text(
                                "SAT",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            splashColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              color: Colors.indigo,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: theClassInfoTable(),
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }

  Widget theClassInfoTable() => Padding(
        padding: EdgeInsets.all(20),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
          },
          children: getTableItems(),
        ),
      );

  List<TableRow> getTableItems() {
    List<TableRow> tablesRows = List();
    /*data.keys.forEach((key) {
      tablesRows.add(_buildItemRow(data[key], "okay"));
    });*/
    tablesRows.add(_buildItemRow(0, "Class", "Section", "Subject"));
    for (int i = 0; i < data.keys.length; i++) {
      tablesRows.add(
          _buildItemRow(i + 1, "Class 1", "A", data[data.keys.elementAt(i)]));
    }
    return tablesRows;
  }

  TableRow _buildItemRow(
      int index, String className, String sectionName, String subjectName) {
    return TableRow(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            (index == 0) ? "Period" : index.toString(),
            style: (index == 0)
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                  )
                : TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            className,
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            sectionName,
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            subjectName,
            style: (index == 0)
                ? TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
