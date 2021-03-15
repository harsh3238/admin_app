import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:click_campus_admin/data/models/option_model.dart';
import 'package:click_campus_admin/utils/camera.dart';
import 'package:click_campus_admin/utils/s3_upload.dart';
import 'package:click_campus_admin/views/polls/poll_preview.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';

class AddQuestionPoll extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddQuestionPoll();
  }
}

class StateAddQuestionPoll extends State<AddQuestionPoll> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  int visibleOptions = 2;
  bool shouldShowRemove = false;
  String questionImage, questionImageUrl;
  bool questionHasImage = false;
  String operation; //1-question image, 2-option image
  List<String> _selectedFilesPaths = [];
  List<Option> _optionList = [];
  String capturedImagePath;
  final _questionTextController = TextEditingController();

  File _image;
  bool didWeGetData = false;

  Widget getOneOptionItem(int position) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              onChanged: (value) {},
              decoration: InputDecoration(
                  labelText: "Option $position",
                  contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                  labelStyle: TextStyle(fontSize: 14)),
              maxLines: 1,
              keyboardType: TextInputType.text,
              scrollPadding: EdgeInsets.all(0),
              validator: (txt) {
                return null;
              },
            ),
          ),
          IconButton(icon: Icon(Icons.add_a_photo), onPressed: null)
        ],
      ),
    );
  }

  void addOptions() {
    _optionList.add(Option("option 1", ""));
    _optionList.add(Option("option 2", ""));
    //setState(() {});
  }

  void addOption() {
    _optionList.add(Option("", ""));
    //setState(() {});
  }

  Widget getOption(int position) {
    debugPrint("OPTION_NO:" + position.toString());
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              onChanged: (value) {},
              decoration: InputDecoration(
                  labelText: "Option $position",
                  contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                  labelStyle: TextStyle(fontSize: 14)),
              maxLines: 1,
              keyboardType: TextInputType.text,
              scrollPadding: EdgeInsets.all(0),
              validator: (txt) {
                return null;
              },
            ),
          ),
          IconButton(icon: Icon(Icons.add_a_photo), onPressed: null)
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!didWeGetData) {
      didWeGetData = true;
      addOptions();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Poll"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getQuestionWidget(),
                    questionImage != null
                        ? Align(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Image.file(
                                  File(questionImage),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )),
                            alignment: Alignment.center,
                          )
                        : Container(
                            height: 10,
                          ),
                    getOptionList(),
                    getFooterWidget()
                  ],
                ),
              ),
            ),
            Align(
              child: Container(
                color: Colors.indigo,
                child: FlatButton(
                    onPressed: () {
                      validateInputs();
                    },
                    child: Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    )),
                width: double.infinity,
              ),
              alignment: Alignment.bottomCenter,
            )
          ],
        ),
      ),
    );
  }

  String convertToJson(List<Option> options) {
    List<Map<String, dynamic>> jsonData = options.map((option) => option.toMap()).toList();
    return jsonEncode(jsonData);
  }

  Future<String> getImage() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    await Navigator.push(context, MaterialPageRoute(builder: (BuildContext buildContext) {
      return TakePictureScreen(
        camera: firstCamera,
      );
    })).then((image) async {
      if (image != null) {
        capturedImagePath = image.path;
        log(image.path, name: "CAMERA_IMAGE");
        return image.path;
      }
    });
  }

  Future<String> getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      log(image.path, name: "GALLERY_IMAGE");
      return image.path;
    }
    return null;
  }

  bool isValidFile(String path) {
    String mimeType = mime(path);

    if (mimeType.contains("image")) {
      return true;
    } else if (mimeType.contains("pdf")) {
      return true;
    }

    return false;
  }

  void _pickImage(String type, int position) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    'Choose Image',
                    style: TextStyle(
                        fontSize: 20,
                        color: const Color(0xff7c7c74),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins'),
                  ),
                ),
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('Camera'),
                    onTap: () async {
                      Navigator.of(bc).pop();
                      capturedImagePath = null;
                      await getImage().then((value) {
                        log("returned");
                        if (capturedImagePath != null) {
                          if (type == "option") {
                            _optionList[position].image = capturedImagePath;
                          } else {
                            questionImage = capturedImagePath;
                          }
                        }
                        setState(() {});
                      });
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_album),
                  title: new Text('Gallery'),
                  onTap: () async {
                    Navigator.of(bc).pop();
                    await getImageFromGallery().then((value) {
                      if (value != null) {
                        if (type == "option") {
                          _optionList[position].image = value;
                        } else {
                          questionImage = value;
                        }
                      } else {
                        questionImage = null;
                      }
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<bool> _uploadQuestionAttachment() async {
    showProgressDialog();
    if (questionImage == null) {
      hideProgressDialog();
      questionHasImage = false;
      return true;
    }
    String mimeType = mime(questionImage);

    String extension;
    int lastDot = questionImage.lastIndexOf('.', questionImage.length - 1);
    if (lastDot != -1) {
      extension = questionImage.substring(lastDot + 1);
    }

    var fileNameNew = "${DateTime.now().millisecondsSinceEpoch.toString()}.$extension";
    var rs = await s3Upload(File(questionImage), fileNameNew);
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

    questionImageUrl = "https://stucarecloud-data.s3.ap-south-1.amazonaws.com/uploaded/$fileNameNew";
    log(questionImageUrl, name: "UPLOAD_URL");
    hideProgressDialog();
    return true;
  }

  Future<bool> _uploadOptionAttachments() async {
    showProgressDialog();
    for (int i = 0; i < _optionList.length; i++) {
      var filePath = _optionList[i].image;
      if(filePath==""){
        break;
      }
      String mimeType = mime(filePath);

      String extension;
      int lastDot = filePath.lastIndexOf('.', filePath.length - 1);
      if (lastDot != -1) {
        extension = filePath.substring(lastDot + 1);
      }

      var fileNameNew = "${DateTime.now().millisecondsSinceEpoch.toString()}.$extension";
      var rs = await s3Upload(File(filePath), fileNameNew);
      if (!rs) {
        showSnackBar("Could not upload files");
        return false;
      }

      var imageUrl = "https://stucarecloud-data.s3.ap-south-1.amazonaws.com/uploaded/$fileNameNew";
      _optionList[i].image = imageUrl;
    }
    hideProgressDialog();
    return true;
  }

  Future<void> validateInputs() async {
    if (_questionTextController.text.isEmpty) {
      StateHelper().showShortToast(context, "Please enter question");
      return;
    }
    for (final item in _optionList) {
      if (item.option == "") {
        StateHelper().showShortToast(context, "Please fill all options");
        return;
      }
      log("loop executed");
    }

    var shouldGoAhead = await _uploadQuestionAttachment();
    if (shouldGoAhead) {
      await _uploadOptionAttachments();

      String options = convertToJson(_optionList);
      log(options);

      Navigator.push(context, MaterialPageRoute(builder: (BuildContext con) {
        return PollPreview(_questionTextController.text, questionImageUrl, _optionList);
      })).then((value){
        if(value!=null && value){
          Navigator.of(context).pop(true);
        }
      });

    }


  }

  Widget getQuestionWidget() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _questionTextController,
              enabled: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter description here..."),
              maxLines: 4,
              maxLength: 200,
            ),
          ),
          InkWell(
              onTap: () {
                _pickImage("question", 0);
              },
              child: IconButton(icon: Icon(Icons.add_a_photo), onPressed: null))
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget getOptionList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(10.0),
      itemCount: _optionList.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  onChanged: (value) {
                    _optionList[index].option = value;
                  },
                  decoration: InputDecoration(
                      labelText: "Option "+(index+1).toString(),
                      contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 2),
                      labelStyle: TextStyle(fontSize: 14)),
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  scrollPadding: EdgeInsets.all(0),
                  validator: (txt) {
                    return null;
                  },
                ),
              ),
              _optionList[index].image != ""
                  ? Align(
                      child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Image.file(
                            File(_optionList[index].image),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )),
                      alignment: Alignment.center,
                    )
                  : Container(
                      height: 10,
                    ),
              IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: () {
                    _pickImage("option", index);
                  })
            ],
          ),
        );
      },
    );
  }

  Widget getFooterWidget() {
    return Align(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            shouldShowRemove
                ? FlatButton(
                    child: Text("Remove"),
                    onPressed: () {
                      setState(() {
                        if (_optionList.length > 2) {
                          _optionList.removeLast();
                          if (_optionList.length == 2) {
                            shouldShowRemove = false;
                          }
                        } else {
                          shouldShowRemove = false;
                        }
                      });
                    },
                  )
                : Container(
                    height: 0,
                  ),
            FlatButton(
              child: Text("Add more option"),
              onPressed: () {
                setState(() {
                  if (_optionList.length < 8) {
                    //visibleOptions += 1;
                    addOption();
                    shouldShowRemove = true;
                  }
                });
              },
            )
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      alignment: Alignment.centerRight,
    );
  }
}
