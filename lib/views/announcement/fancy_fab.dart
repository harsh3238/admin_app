import 'package:click_campus_admin/views/announcement/add_sms.dart';
import 'package:click_campus_admin/views/announcement/add_voice_sms.dart';
import 'package:flutter/material.dart';

import 'add_announcement.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final int _msgFromApp;

  FancyFab(this._msgFromApp, {this.onPressed, this.tooltip, this.icon});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.indigo,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: Row(
        children: <Widget>[
          Visibility(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  'Message',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            visible: isOpened,
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                  body: AddAnnouncement(),
                );
              }));
            },
            tooltip: 'Message',
            child: Icon(Icons.message),
          )
        ],
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
      ),
    );
  }

  Widget image() {
    return Container(
      child: Row(
        children: <Widget>[
          Visibility(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  'SMS',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            visible: isOpened,
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                  body: AddSms(),
                );
              }));
            },
            tooltip: 'SMS',
            child: Icon(Icons.sms),
          )
        ],
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: Row(
        children: <Widget>[
          Visibility(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  'Voice Message',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            visible: isOpened,
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                  body: AddVoiceMessage(),
                );
              }));
            },
            tooltip: 'Voice Message',
            child: Icon(Icons.voice_chat),
          )
        ],
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: Row(
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            backgroundColor: _buttonColor.value,
            onPressed: animate,
            tooltip: 'Toggle',
            child: Icon(Icons.add),
          )
        ],
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 3.0,
            0.0,
          ),
          child: Visibility(
            child: image(),
            visible: (widget._msgFromApp == 1),
          ),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: add(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: inbox(),
        ),
        toggle(),
      ],
    );
  }
}
