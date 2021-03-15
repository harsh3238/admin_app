
import 'package:click_campus_admin/views/video_player/video_player.dart';
import 'package:flutter/material.dart';


import '../state_helper.dart';

class VideosList extends StatefulWidget {
  final List<dynamic> _videosList;

  VideosList(this._videosList);

  @override
  State<StatefulWidget> createState() {
    return _VideosListState();
  }
}

class _VideosListState extends State<VideosList> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Videos"),
      ),
      body: ListView.separated(
          padding: EdgeInsets.all(8),
          separatorBuilder: (context, position) {
            return Divider();
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                      return VideoPlayer(widget._videosList[index]['video_url']);
                    }));
              },
              child: Container(
                height: getItemHeight(widget._videosList[index]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    getListImageWidget(widget._videosList[index]),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: Text(
                              widget._videosList[index]['file_name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          (widget._videosList[index]['caption'] != null)
                              ? Text(
                            widget._videosList[index]['caption'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          )
                              : Container(
                            height: 0,
                          ),
                          Align(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: Text(
                                widget._videosList[index]['duration'],
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
          itemCount: widget._videosList.length),
    );
  }

  Widget getListImageWidget(Map<String, dynamic> data) {
    if (data['thumbnail'] != null) {
      return Container(
        margin: const EdgeInsets.only(right: 8.0),
        width: 100.0,
        height: double.infinity,
        child: Image.network(
          data['thumbnail'],
          fit: BoxFit.cover,
        ),
        color: Colors.red,
      );
    }
    return Container(width: 0);
  }

  double getItemHeight(Map<String, dynamic> data) {
    if (data['thumbnail'] != null || data['caption'] != null) {
      return 100;
    }

    return 70;
  }
}
