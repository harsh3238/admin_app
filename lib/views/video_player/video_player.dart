import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class VideoPlayer extends StatelessWidget {
  BuildContext _context;
  String videoUrl;
  bool areWeDone = false;
  YoutubePlayerController _controller;

  VideoPlayer(String url, {Key key}) : super(key: key) {
    videoUrl = url;
    _controller = YoutubePlayerController(
      initialVideoId: videoUrl,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true
      ),
    );
  }

  void listener() {
    if (_controller.value.playerState == PlayerState.ended) {
      Navigator.pop(_context);
    }
    if (_controller.value.playerState == PlayerState.playing) {
      if (!_controller.value.isFullScreen) {
        _controller.toggleFullScreenMode();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {
          //print('Player is ready.');
        },
      ),
    );
  }
}
