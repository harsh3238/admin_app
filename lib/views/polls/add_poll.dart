import 'dart:io';

import 'package:camera/camera.dart';
import 'package:click_campus_admin/utils/camera.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';

class AddPoll extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAddPoll();
  }
}

class StateAddPoll extends State<AddPoll> with StateHelper{
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  int visibleOptions = 2;
  Widget qusWidget, theFooterWidget;
  bool shouldShowRemove = false;
  String questionImage;
  String operation;//1-question image, 2-option image
  List<String> _selectedFilesPaths = [];
  List<Map<String, String>> _filePathsToUpload = [];

  File _image;

  Widget getOneOptionItem(int position) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
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

  List<Widget> getWidgets() {
    List<Widget> theList = List();
    theList.add(qusWidget);

    for (int i = 1; i <= visibleOptions; i++) {
      theList.add(getOneOptionItem(i));
    }
    theList.add(theFooterWidget);
    return theList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    qusWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              enabled: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter description here..."),
              maxLines: 4,
              maxLength: 200,
            ),
          ),
          InkWell(
              onTap: (){
                _pickImage();
              },
              child: IconButton(icon: Icon(Icons.add_a_photo), onPressed: null))
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );

    theFooterWidget = Align(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            shouldShowRemove
                ? FlatButton(
                    child: Text("Remove"),
                    onPressed: () {
                      setState(() {
                        if (visibleOptions > 2) {
                          visibleOptions -= 1;
                          if (visibleOptions == 2) {
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
                  if (visibleOptions < 8) {
                    visibleOptions += 1;
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

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Poll"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Form(
                child: Column(
                  children: getWidgets(),
                ),
              ),
            ),
          )),
          Align(
            child: Container(
              color: Colors.indigo,
              child: FlatButton(
                  onPressed: null,
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
    );
  }

  Future getImage() async {
    /*var image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 40);

    setState(() {
      _image = image;
      _selectedFilesPaths.add(_image.path);
      //print(_selectedFilesPaths);
    });*/
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext buildContext) {
          return TakePictureScreen(
            camera: firstCamera,
          );
        })).then((image) {
      setState(() {
        _image = image;
        _selectedFilesPaths.add(_image.path);
        //print(_selectedFilesPaths);
      });
    });
  }

  void _openFileExplorer() async {
    var path = await FilePicker.getFilePath(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'pdf', 'png']);

    if (path != null && isValidFile(path)) {
      setState(() {
        _selectedFilesPaths.add(path);
        //print(_selectedFilesPaths);
      });
    } else {
      showSnackBar("File type not allowed");
    }
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


  void _pickImage() {
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
                    onTap: () {
                      Navigator.of(bc).pop();
                      getImage();
                      //getFile(ImageSource.camera);
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_album),
                  title: new Text('Gallery'),
                  onTap: () {
                    Navigator.of(bc).pop();
                    _openFileExplorer();
                    //getFile(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }


}
