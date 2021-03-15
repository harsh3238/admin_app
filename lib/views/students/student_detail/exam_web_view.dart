import 'dart:async';
import 'dart:developer';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExamWebView extends StatefulWidget {
  String sessionId;
  String sessionToken;
  String termId;
  String examId;
  String classId;
  String sectionId;
  String calcType;
  String studentId;
  String rootUrl;

  Uri theuri;

  ExamWebView( this.sessionToken, this.sessionId, this.termId, this.examId, this.classId,
      this.sectionId, this.calcType, this.studentId, this.rootUrl) {
    var queryParameters = {
      'session_id': sessionId,
      'term_id': termId,
      'class_id': classId,
      'section_id': sectionId,
      'exam_id': examId,
      'student_id': studentId,
      'calc_type': calcType,
      'current_session': sessionId
    };

    theuri = Uri.https(rootUrl, '/api/app-report-card', queryParameters);
    log(theuri.toString());
  }

  @override
  _ExamWebViewState createState() => _ExamWebViewState();
}

class _ExamWebViewState extends State<ExamWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Card'),
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.theuri.toString(),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onPageFinished: (String url) {
            //print('Page finished loading: $url');
          },
        );
      }),
    );
  }
}
