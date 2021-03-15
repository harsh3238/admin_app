import 'dart:convert';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/video_gallery/videos_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

class VideoGalleryMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VideoGalleryMainState();
  }
}


class _VideoGalleryMainState extends State<VideoGalleryMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  List<dynamic> _videoGalleryData = <dynamic>[];

  void _getGallery() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getVideoGalleryRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _videoGalleryData = modulesResponseObject['data'];
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
        _getGallery();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Video Gallery"),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(8),
        separatorBuilder: (context, position) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return VideosList(_videoGalleryData[index]['videos'] != null ? _videoGalleryData[index]['videos'] : []);
                  }));
            },
            child: Container(
              child: Column(
                children: <Widget>[
                  Image.network(
                    _videoGalleryData[index]['thumbnail_url'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _videoGalleryData[index]['gallery_name'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _videoGalleryData[index]['description'],
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Align(
                    child: Text(
                      _videoGalleryData[index]['date_to_display'],
                      style: TextStyle(fontSize: 10),
                    ),
                    alignment: Alignment.centerRight,
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          );
        },
        itemCount: _videoGalleryData.length,
      ),
    );
  }
}
