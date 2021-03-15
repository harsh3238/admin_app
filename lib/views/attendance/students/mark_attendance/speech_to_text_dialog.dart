import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';

class SpeechToTextDialog extends StatefulWidget {
  SpeechToTextDialog();

  @override
  State<StatefulWidget> createState() {
    return SpeechToTextDialogState();
  }
}

class SpeechToTextDialogState extends State<SpeechToTextDialog> {
  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String _searchQueryVoice = '';

  bool areWePopped = false;

  void activateSpeechRecognizer() {
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    //print('_MyAppState.onCurrentLocale... $locale');
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) => _searchQueryVoice = text;

  void onRecognitionComplete(String text) {
    setState(() {
      _isListening = false;
    });
    if (_searchQueryVoice.length > 0 && !areWePopped) {
      areWePopped = true;
      Navigator.pop(context, [true, _searchQueryVoice]);
    }
  }

  void start() async {
    bool doWeHavePer = await _checkMicPermission();
    if (doWeHavePer) {
      _speech
          .listen(locale: "en_IN")
          .then((result) => debugPrint('_MyAppState.start => result $result'));
    } else {
      Navigator.pop(context, [false, ""]);
    }
  }

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: _mainUi(),
        ),
      ],
    );
  }

  Widget _mainUi() => Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Speech To Text",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          Divider(),
          SizedBox(
            height: 20,
          ),
          IconButton(
              icon: Icon(
                Icons.mic,
                size: 48,
                color: _isListening ? Colors.redAccent : Colors.grey.shade600,
              ),
              onPressed: _speechRecognitionAvailable && !_isListening
                  ? () => start()
                  : null),
          SizedBox(
            height: 10,
          ),
          Text(
            _isListening ? "Listening..." : "Tap the mic to start listening",
            style: TextStyle(color: Colors.grey),
          )
        ],
      ));

  Future<bool> _checkMicPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.microphone]);
      if (permissions[PermissionGroup.microphone] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
}
