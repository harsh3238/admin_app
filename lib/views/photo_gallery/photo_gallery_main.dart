import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/views/photo_gallery/all_photos.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state_helper.dart';

typedef BannerTapCallback = void Function(Photo photo);

class Photo {
  Photo({
    this.assetName,
    this.title,
    this.caption
  });

  final String assetName;
  final String title;
  final String caption;


  String get tag =>
      assetName +
      DateTime.now().toString(); // Assuming that all asset names are unique.
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
            child: Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 12),
          textAlign: TextAlign.start,
          maxLines: 2,
        ))
      ],
    );
  }
}

class GridDemoPhotoItem extends StatelessWidget {
  final Map<String, dynamic> item;

  GridDemoPhotoItem(this.item);


  void showPhoto(BuildContext context) {
    Navigator.push(context, MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AllPhotosPage((item['photos'] != null) ? item['photos'] : []);
        }
    ));
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = GestureDetector(
      onTap: () {
        showPhoto(context);
      },
      child: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: CachedNetworkImage(
              imageUrl: item['thumbnail_url'],
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            child: Container(
              height: 20,
              width: 70,
              decoration: new BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    item['date_to_show'],
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            right: 10,
            top: 10,
          )
        ],
      ),
    );

    return GridTile(
      footer: GestureDetector(
        onTap: () {},
        child: GridTileBar(
          backgroundColor: Colors.white70,
          title: _GridTitleText(item['gallery_name']),
        ),
      ),
      child: image,
    );
  }
}

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({Key key}) : super(key: key);

  @override
  PhotoGalleryState createState() => PhotoGalleryState();
}

class PhotoGalleryState extends State<PhotoGallery> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;

  List<dynamic> _photoGalleryData = <dynamic>[];

  void _getGallery() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var modulesResponse = await http.post(GConstants.getPhotoGalleryRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _photoGalleryData = modulesResponseObject['data'];
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
      key: _scaffoldState,
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                padding: const EdgeInsets.all(4.0),
                childAspectRatio: 1.0,
                children: _photoGalleryData.map<Widget>((item) {
                  return GridDemoPhotoItem(item);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
