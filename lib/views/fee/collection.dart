import 'dart:convert';
import 'dart:developer' as mLog;
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../state_helper.dart';

class FeeCollection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FeeCollectionState();
  }
}

class FeeCollectionState extends State<FeeCollection> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<ClassData> _collectionData = [];
  int totalCollection = 0;

  void _getData() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(
        GConstants.getFeeCollectionRoute(await AppData().getSchoolUrl()),
        body: {
          'active_session': sessionToken,
        });

    mLog.log("${modulesResponse.request}:${modulesResponse.body}");

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          List<dynamic> collectionData = modulesResponseObject['collection'];
          totalCollection = modulesResponseObject['total_collection'];

          collectionData.asMap().forEach((index, f) {
            final Random _random = Random();
            _collectionData.add(ClassData(
                double.parse(f['collection']),
                (totalCollection == 0)
                    ? 0
                    : (double.parse(f['collection']) / totalCollection * 100)
                        .toInt(),
                f['class_name'],
                charts.ColorUtil.fromDartColor(Color.fromRGBO(
                    _random.nextInt(256),
                    _random.nextInt(256),
                    _random.nextInt(256),
                    1))));
          });
          hideProgressDialog();
          setState(() {});
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(modulesResponseObject["message"]);
          return null;
        }
      } else {
        showServerError();
      }
    } else {
      showServerError();
    }
    hideProgressDialog();
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getData();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Collection"),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            DateFormat()
                .addPattern("dd MMMM yyyy")
                .format(DateTime.now())
                .toString(),
            style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          Container(
              height: 300,
              child: Stack(
                children: <Widget>[
                  DonutPieChart((totalCollection == 0) ? [] : _collectionData),
                  Center(
                    child: RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(
                          text: '₹ $totalCollection',
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                                text: '\nCollective Total',
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 9)),
                          ],
                        )),
                  )
                ],
              )),
          Expanded(
            child: ListView.separated(
              itemCount: _collectionData.length,
              itemBuilder: _buildFriendListTile,
              separatorBuilder: (context, position) {
                return Divider(
                  height: 0,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    int p = index % 14;

    return new ListTile(
        leading: new Container(
          width: 50.0,
          height: 50.0,
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(new Radius.circular(40.0)),
              color: Color.fromARGB(
                _collectionData[index].color.a,
                _collectionData[index].color.r,
                _collectionData[index].color.g,
                _collectionData[index].color.b,
              )),
          child: Center(
            child: Text(
              (index + 1).toString().toUpperCase(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: new Text(
          "Class : ${_collectionData[index].className}",
          style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        subtitle: new Text(
          "${_collectionData[index].percentage} %",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: new Text(
          "₹ ${_collectionData[index].collection}",
          style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ));
  }
}

class DonutPieChart extends StatelessWidget {
  List<charts.Series> seriesList;
  List<ClassData> _collectionData = [];

  DonutPieChart(this._collectionData) {
    seriesList = createSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: false,
        // Configure the width of the pie slices to 60px. The remaining space in
        // the chart will be left as a hole in the center.
        defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 50,
        ));
  }

  List<charts.Series<ClassData, int>> createSampleData() {
    return [
      new charts.Series<ClassData, int>(
          id: 'Sales',
          domainFn: (ClassData classData, _) => classData.collection.toInt(),
          measureFn: (ClassData classData, _) => classData.percentage,
          data: _collectionData,
          colorFn: (ClassData sales, __) {
            return sales.color;
          })
    ];
  }
}

/// Sample linear data type.
class ClassData {
  final double collection;
  final int percentage;
  final String className;
  final charts.Color color;

  ClassData(this.collection, this.percentage, this.className, this.color);
}
