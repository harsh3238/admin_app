
import 'package:click_campus_admin/views/message/audio_player_dialog.dart';
import 'package:click_campus_admin/views/message/msg_video_player.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/util_widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetails extends StatefulWidget {
  final Map<String, dynamic> newsData;

  NewsDetails(this.newsData);

  @override
  State<StatefulWidget> createState() {
    return _NewsDetailsState();
  }
}

class _NewsDetailsState extends State<NewsDetails> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> attachments = widget.newsData['attachments'] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text("News")),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: attachments.length > 0
                ? Stack(
                    children: <Widget>[
                      Container(
                        height: 180,
                        width: double.infinity,
                        child: PageView(
                          children: <Widget>[]..addAll(attachments.map((i) {
                              if (i['media_type'] == 'image') {
                                return GestureDetector(
                                  onTap: () {
                                    var photo = Photo(assetName: i['file_url']);
                                    Navigator.push(context,
                                        MaterialPageRoute<void>(builder: (BuildContext context) {
                                          return Scaffold(
                                            body: SizedBox.expand(
                                              child: Hero(
                                                tag: photo.tag,
                                                child: GridPhotoViewer(photo: photo),
                                              ),
                                            ),
                                          );
                                        }));
                                  },
                                  child: Container(
                                    child: Image.network(
                                      i['file_url'],
                                      fit: BoxFit.cover,
                                    ),
                                    color: Colors.black,
                                  ),
                                );
                              }

                              if (i['media_type'] == 'video') {
                                return Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Video Attachment',
                                        textAlign: TextAlign.center,
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            Icons.play_circle_outline,
                                            size: 48,
                                          ),
                                          onPressed: (){
                                            Navigator.push(context,
                                                MaterialPageRoute<void>(builder: (BuildContext context) {
                                                  return VideoDemo(i['file_url']);
                                                }));
                                          })
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                  ),
                                  color: Colors.grey,
                                );
                              }
                              if (i['media_type'] == 'audio') {
                                return Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Audio Attachment',
                                        textAlign: TextAlign.center,
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            Icons.play_circle_outline,
                                            size: 48,
                                          ),
                                          onPressed: (){
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) => AudioPlayerDialog(i['file_url']),
                                            );
                                          })
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                  ),
                                  color: Colors.grey,
                                );
                              }

                              if (i['media_type'] == 'pdf') {
                                return Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'PDF Attachment',
                                        textAlign: TextAlign.center,
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            Icons.picture_as_pdf,
                                            size: 48,
                                          ),
                                          onPressed: (){
                                            _launchURL(i['file_url']);
                                          })
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                  ),
                                  color: Colors.grey,
                                );
                              }
                              return Container(
                                color: Colors.grey,
                              );
                            })),
                        ),
                      ),
                      Container(
                        height: 180,
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(widget.newsData['title'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  )
                : Container(
                    height: 0,
                  ),
          ),
          SliverToBoxAdapter(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(widget.newsData['news'],
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  _launchURL(String theUrl) async {
    if (await canLaunch(theUrl)) {
      await launch(theUrl);
    } else {
      throw 'Cannot open browser for this $theUrl';
    }
  }
}
