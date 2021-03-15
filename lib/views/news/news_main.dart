import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/news/add_news.dart';
import 'package:click_campus_admin/views/news/news_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class NewsMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsMainState();
  }
}

class _NewsMainState extends State<NewsMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  List<dynamic> _newsData = [];

  void _getNews() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getNormalNewsRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _newsData = modulesResponseObject['data'];
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
        _getNews();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("News"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (b) => AddNews())).then((value) => _getNews());
        },
        child: Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(8),
        separatorBuilder: (context, position) {
          return Divider();
        },
        itemBuilder: (context, index) {
          List<dynamic> attachments = _newsData[index]['attachments'] ?? [];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                  body: NewsDetails(_newsData[index]),
                );
              }));
            },
            child: Container(
              height: getItemHeight(attachments),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  attachments.length > 0 ? getListImageWidget(attachments) : Container(width: 0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _newsData[index]['title'].toString().trim().length > 0
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Text(
                                  _newsData[index]['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              )
                            : Container(
                                height: 0,
                              ),
                        Text(
                          _newsData[index]['news'],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12),
                        ),
                        Align(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Text(
                              _newsData[index]['date'],
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          alignment: Alignment.centerRight,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
        itemCount: _newsData.length,
      ),
    );
  }

  Widget getListImageWidget(List<dynamic> data) {
    for (int i = 0; i < data.length; i++) {
      if (data[i]['media_type'] == 'image') {
        return Container(
          margin: const EdgeInsets.only(right: 8.0),
          width: 100.0,
          height: double.infinity,
          child: Image.network(
            data[i]['file_url'],
            fit: BoxFit.cover,
          ),
          color: Colors.red,
        );
      }
    }

    return Container(width: 0);
  }

  double getItemHeight(List<dynamic> data) {
    for (int i = 0; i < data.length; i++) {
      if (data[i]['media_type'] == 'image') {
        return 120;
      }
    }

    return 80;
  }
}
