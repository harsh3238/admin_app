import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoDemo extends StatefulWidget {
  var videoUrl;

  VideoDemo(this.videoUrl);

  @override
  _VideoDemoState createState() => _VideoDemoState();
}

class _VideoDemoState extends State<VideoDemo>
    with SingleTickerProviderStateMixin {
  VideoPlayerController beeController;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<void> connectedCompleter = Completer<void>();
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    beeController = VideoPlayerController.network(widget.videoUrl);
    Future<void> initController(
        VideoPlayerController controller, String name) async {

      controller.setLooping(true);
      controller.setVolume(1);
      controller.play();
      //await connectedCompleter.future;
      await controller.initialize();
      if (mounted) {

        setState(() {});
      }
    }

    initController(beeController, 'bee');
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //print('> VideoDemo dispose');
    isDisposed = true;
    beeController.dispose();
    //print('< VideoDemo dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: VideoPlayer(beeController),
    );
  }
}
