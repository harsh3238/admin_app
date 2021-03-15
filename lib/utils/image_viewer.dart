import 'dart:io';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';


class GridPhotoViewer extends StatefulWidget {
  GridPhotoViewer({this.photo});

  final Photo photo;

  _GridPhotoViewerState theState;

  @override
  _GridPhotoViewerState createState() {
    theState = _GridPhotoViewerState();
    return _GridPhotoViewerState();
  }

  void takeScreenShot(){
    theState.takeScreenShot();
  }
}

const double _kMinFlingVelocity = 800.0;

class _GridPhotoViewerState extends State<GridPhotoViewer>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  ScreenshotController screenshotController = ScreenshotController();
  bool showWhiteBoard = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = _controller.drive(Tween<Offset>(
      begin: _offset,
      end: _clampOffset(_offset + direction * distance),
    ));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }


  void takeScreenShot() async {
    setState(() {
      _offset = Offset.zero;
      _scale = 1.0;
    });
    setState(() {
      showWhiteBoard = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    screenshotController.capture().then((File image) async {
      setState(() {
        showWhiteBoard = false;
      });
      image.readAsBytes().then((data) async{
        await Share.file('Title', '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg', data, 'image/jpeg');
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: Stack(
            children: <Widget>[
              Screenshot(
                controller: screenshotController,
                child: Column(
                  children: <Widget>[
                    Image.network(
                      widget.photo.assetName,
                      fit: BoxFit.contain,
                    ),
                    Visibility(
                      child: Container(
                        child: Text(
                         "",
                          textAlign: TextAlign.center,
                        ),
                        color: Colors.white,
                        width: double.infinity,
                      ),
                      visible: showWhiteBoard,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ),
              Visibility(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Text('Please wait...'),
                  ),
                ),
                visible: showWhiteBoard,
              )
            ],
          ),
        ),
      ),
    );
  }
}
