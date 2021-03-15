import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/utils/s3_upload.dart';
import 'package:click_campus_admin/views/announcement/select_audience.dart';
import 'package:click_campus_admin/views/announcement/selected_audience.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';

enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
}

class AddVoiceMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddVoiceMessageState();
  }
}

class AddVoiceMessageState extends State<AddVoiceMessage> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  FlutterSound flutterSound;
  List<String> _path = [null, null, null, null, null, null, null];
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;

  bool _didGetData = false;

  bool _isRecording = false;
  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;
  t_MEDIA _media = t_MEDIA.FILE;
  t_CODEC _codec = t_CODEC.CODEC_AAC;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  List<String> assetSample = [
    'assets/samples/sample.aac',
    'assets/samples/sample.aac',
    'assets/samples/sample.opus',
    'assets/samples/sample.caf',
    'assets/samples/sample.mp3',
    'assets/samples/sample.ogg',
    'assets/samples/sample.wav',
  ];

  List<dynamic> _msgSenders = <dynamic>[];
  Map<String, dynamic> _selectedMsgSender;

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  // In this simple example, we just load a file in memory.This is stupid but just for demonstation  of startPlayerFromBuffer()
  Future<Uint8List> makeBuffer(String path) async {
    try {
      if (!await fileExists(path)) return null;
      File file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      //print('The file is ${contents.length} bytes long.');
      return contents;
    } catch (e) {
      //print(e);
      return null;
    }
  }

  void startPlayer() async {
    try {
      String path = null;
      if (_media == t_MEDIA.ASSET) {
        Uint8List buffer = (await rootBundle.load(assetSample[_codec.index]))
            .buffer
            .asUint8List();
        path = await flutterSound.startPlayerFromBuffer(
          buffer,
          codec: _codec,
        );
      } else if (_media == t_MEDIA.FILE) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[_codec.index]))
          path = await flutterSound
              .startPlayer(this._path[_codec.index]); // From file
      } else if (_media == t_MEDIA.BUFFER) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[_codec.index])) {
          Uint8List buffer = await makeBuffer(this._path[_codec.index]);
          if (buffer != null)
            path = await flutterSound.startPlayerFromBuffer(
              buffer,
              codec: _codec,
            ); // From buffer
        }
      }
      if (path == null) {
        //print('Error starting player');
        return;
      }
      //print('startPlayer: $path');
      await flutterSound.setVolume(1.0);

      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          sliderCurrentPosition = e.currentPosition;
          maxDuration = e.duration;

          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss:SS').format(date);
          this.setState(() {
            //this._isPlaying = true;
            this._playerTxt = txt.substring(0, 8);
          });
        }
      });
    } catch (err) {
      //print('error: $err');
    }
    setState(() {});
  }

  void stopPlayer() async {
    try {
      String result = await flutterSound.stopPlayer();
      //print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } catch (err) {
      //print('error: $err');
    }
    this.setState(() {
      //this._isPlaying = false;
    });
  }

  void pausePlayer() async {
    String result;
    try {
      if (flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED) {
        result = await flutterSound.resumePlayer();
        //print('resumePlayer: $result');
      } else {
        result = await flutterSound.pausePlayer();
        //print('pausePlayer: $result');
      }
    } catch (err) {
      //print('error: $err');
    }
    setState(() {});
  }

  void seekToPlayer(int milliSecs) async {
    String result = await flutterSound.seekToPlayer(milliSecs);
    //print('seekToPlayer: $result');
  }

  onPausePlayerPressed() {
    return flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING ||
            flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED
        ? pausePlayer
        : null;
  }

  onStopPlayerPressed() {
    return flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING ||
            flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED
        ? stopPlayer
        : null;
  }

  onStartPlayerPressed() {
    if (_media == t_MEDIA.FILE || _media == t_MEDIA.BUFFER) {
      if (_path[_codec.index] == null) return null;
    }
    return flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
        ? startPlayer
        : null;
  }

  onStartRecorderPressed() {
    if (_media == t_MEDIA.ASSET || _media == t_MEDIA.BUFFER) return null;
    if (flutterSound.audioState == t_AUDIO_STATE.IS_RECORDING)
      return stopRecorder;

    return flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
        ? startRecorder
        : null;
  }

  void startRecorder() async {
    try {
      // String path = await flutterSound.startRecorder
      // (
      //   paths[_codec.index],
      //   codec: _codec,
      //   sampleRate: 16000,
      //   bitRate: 16000,
      //   numChannels: 1,
      //   androidAudioSource: AndroidAudioSource.MIC,
      // );
      Directory tempDir = await getTemporaryDirectory();

      String path = await flutterSound.startRecorder(
        uri: '${tempDir.path}/sound.aac',
        codec: _codec,
      );
      //print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS').format(date);

        this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        //print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
        this._path[_codec.index] = path;
      });
    } catch (err) {
      //print('startRecorder error: $err');
      setState(() {
        this._isRecording = false;
      });
    }
  }

  void stopRecorder() async {
    try {
      String result = await flutterSound.stopRecorder();
      //print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
    } catch (err) {
      //print('stopRecorder error: $err');
    }
    this.setState(() {
      this._isRecording = false;
    });
  }

  Icon recorderAssetImage() {
    if (onStartRecorderPressed() == null)
      return Icon(
        Icons.mic_off,
        size: 44,
      );
    return flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
        ? Icon(
            Icons.mic,
            size: 44,
          )
        : Icon(
            Icons.stop,
            size: 44,
          );
  }

  SelectedAudience _selectedAudience;

  void _getMsgSenders() async {
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();
    var modulesResponse = await http.post(
        GConstants.getMsgSendersRoute(await AppData().getSchoolUrl()),
        body: {
          'active_session': sessionToken,
        });

    //print(modulesResponse.body);

    if (modulesResponse.statusCode == 200) {
      Map modulesResponseObject = json.decode(modulesResponse.body);
      if (modulesResponseObject.containsKey("status")) {
        if (modulesResponseObject["status"] == "success") {
          _msgSenders = modulesResponseObject['data'];
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

  final List<Widget> chips = [];

  List<Map<String, String>> _filePathsToUpload = [];

  Future<bool> _uploadAttachments() async {
    var filePath = _path[_codec.index];
    String mimeType = mime(filePath);

    String extension;
    int lastDot = filePath.lastIndexOf('.', filePath.length - 1);
    if (lastDot != -1) {
      extension = filePath.substring(lastDot + 1);
    }

    var fileNameNew =
        "${DateTime.now().millisecondsSinceEpoch.toString()}.$extension";
    var rs = await s3Upload(File(filePath), fileNameNew);
    if (!rs) {
      showSnackBar("Could not upload files");
      return false;
    }

    Map<String, String> map = Map();

    if (mimeType.contains("image")) {
      map['media_type'] = "image";
    } else if (mimeType.contains("video")) {
      map['media_type'] = "video";
    } else if (mimeType.contains("audio")) {
      map['media_type'] = "audio";
    } else if (mimeType.contains("pdf")) {
      map['media_type'] = "pdf";
    }

    map['url'] =
        "https://stucarecloud.s3.ap-south-1.amazonaws.com/uploaded/$fileNameNew";
    _filePathsToUpload.add(map);

    return true;
  }

  void _validateSubmit() async {
    if (_selectedMsgSender == null) {
      showSnackBar("Please select a sender", color: Colors.orange);
      return;
    }

    if (_selectedAudience != null &&
        (_selectedAudience.checkedStaff.length > 0 ||
            _selectedAudience.checkedStudents.length > 0)) {
      if (_path[_codec.index] != null &&
          await fileExists(_path[_codec.index])) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Post Announcement?"),
                content:
                    Text("Are you sure you want to post this announcement ? "),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendMessage();
                    },
                    child: Text("Okay"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  )
                ],
              );
            });
      } else {
        showSnackBar("Please record a message", color: Colors.orange);
      }
    } else {
      showSnackBar("Please select auidence for this message",
          color: Colors.orange);
    }
  }

  void _sendMessage() async {
    stopPlayer();
    showProgressDialog();
    var shouldGoAhead = await _uploadAttachments();
    if (shouldGoAhead) {
      await _sendMessageFinally();
    } else {
      hideProgressDialog();
    }
  }

  Future<void> _sendMessageFinally() async {
    var loginId = await AppData().getUserLoginId();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse = await http.post(
        GConstants.getSendMediaMsgRoute(await AppData().getSchoolUrl()),
        body: {
          'sender_id': _selectedMsgSender['id'],
          'students': json.encode(_selectedAudience.checkedStudents.toList()),
          'staff': json.encode(_selectedAudience.checkedStaff.toList()),
          'message': "",
          'login_id': loginId.toString(),
          'attachments': json.encode(_filePathsToUpload),
          'active_session': sessionToken,
        });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          _path[_codec.index] = null;
          _filePathsToUpload.clear();
          _selectedMsgSender = null;
          _selectedAudience = null;
          chips.clear();
          showSnackBar('Message sent successfully', color: Colors.green);
          setState(() {});
          hideProgressDialog();
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(allClassesObject["message"]);
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
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        _getMsgSenders();
      });
    }
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("Add Annoucement"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
                          child: Text(
                            this._recorderTxt,
                            style: TextStyle(
                              fontSize: 35.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        /* _isRecording ? LinearProgressIndicator(
                          value: 100.0 / 160.0 * (this._dbLevel ?? 1) / 100,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          backgroundColor: Colors.red,
                        ) : Container()*/
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 56.0,
                          height: 50.0,
                          child: ClipOval(
                            child: FlatButton(
                              onPressed: onStartRecorderPressed(),
                              padding: EdgeInsets.all(8.0),
                              child: recorderAssetImage(),
                            ),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
                      child: Text(
                        this._playerTxt,
                        style: TextStyle(
                          fontSize: 35.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          child: FlatButton(
                            onPressed: onStartPlayerPressed(),
                            disabledColor: Colors.white,
                            padding: EdgeInsets.all(8.0),
                            child: Icon(onStartPlayerPressed() != null
                                ? Icons.play_arrow
                                : Icons.remove),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          child: FlatButton(
                            onPressed: onPausePlayerPressed(),
                            disabledColor: Colors.white,
                            padding: EdgeInsets.all(8.0),
                            child: Icon(onStartPlayerPressed() != null
                                ? Icons.pause
                                : Icons.remove),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          child: FlatButton(
                            onPressed: onStopPlayerPressed(),
                            disabledColor: Colors.white,
                            padding: EdgeInsets.all(8.0),
                            child: Icon(onStartPlayerPressed() != null
                                ? Icons.stop
                                : Icons.remove),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                    Container(
                        height: 30.0,
                        child: Slider(
                            value: sliderCurrentPosition,
                            min: 0.0,
                            max: maxDuration,
                            onChanged: (double value) async {
                              await flutterSound.seekToPlayer(value.toInt());
                            },
                            divisions: maxDuration.toInt())),
                    SizedBox(
                      height: 40,
                    ),
                    Card(
                      child: DropdownButtonFormField(
                        items: _msgSenders.map((v) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                              child: Text(v['name']), value: v);
                        }).toList(),
                        value: _selectedMsgSender,
                        onChanged: (nV) {
                          setState(() {
                            _selectedMsgSender = nV;
                          });
                        },
                        decoration: InputDecoration(
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 8, 12),
                        ),
                        hint: Text("Select Sender"),
                      ),
                      margin: EdgeInsets.all(8),
                    ),
                    Align(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 10, 0, 10),
                        child: Text(
                          "Audience",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    Wrap(
                      children: chips.map<Widget>((Widget chip) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: chip,
                        );
                      }).toList(),
                    ),
                    GestureDetector(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 20, 8, 20),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Select Audience",
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down)
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                        margin: EdgeInsets.all(8),
                      ),
                      onTap: () async {
                        await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return SelectAudience();
                                    },
                                    fullscreenDialog: true))
                            .then((rs) {
                          _selectedAudience = rs as SelectedAudience;
                          chips.clear();
                          if (_selectedAudience.areAllStaffSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text('All Staff')));
                          } else if (_selectedAudience.oneDepartmentSelected) {
                            var depName =
                                _selectedAudience.selectedDepartments[0];
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text(depName)));
                          } else if (_selectedAudience
                              .multipleDepartmentSelected) {
                            _selectedAudience.selectedDepartments
                                .forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.oneStaffSelected) {
                            _selectedAudience.selectedStaff.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.multipleStaffSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text("Multiple Staff")));
                          }

                          if (_selectedAudience.areAllStudentsSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text('All Students')));
                          } else if (_selectedAudience.oneClassSelected) {
                            _selectedAudience.selectedClasses.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.multipleClassSelected) {
                            _selectedAudience.selectedClasses.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.oneSectionSelected) {
                            _selectedAudience.selectedSections.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience
                              .multipleSectionSelected) {
                            _selectedAudience.selectedSections.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience.oneStudentSelected) {
                            _selectedAudience.selectedStudents.forEach((item) {
                              chips.add(Chip(
                                  avatar: CircleAvatar(
                                      backgroundColor: Colors.grey.shade800,
                                      child: Icon(Icons.check)),
                                  label: Text(item)));
                            });
                          } else if (_selectedAudience
                              .multipleStudentSelected) {
                            chips.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundColor: Colors.grey.shade800,
                                    child: Icon(Icons.check)),
                                label: Text("Multiple Students")));
                          }
                        });
                        setState(() {});
                      },
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      _validateSubmit();
                    },
                    color: Colors.indigo,
                    child: Text(
                      "Post Now",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {},
                    color: Colors.indigo,
                    child: Text(
                      "Post Sheduled",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          )
        ],
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }
}
