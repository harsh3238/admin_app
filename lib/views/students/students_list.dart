import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:click_campus_admin/config/g_constants.dart';
import 'package:click_campus_admin/data/app_data.dart';
import 'package:click_campus_admin/data/db_class_section.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:click_campus_admin/views/photo_gallery/photo_gallery_main.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:click_campus_admin/views/students/student_detail/students_detail_main.dart';
import 'package:click_campus_admin/views/util_widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateStudentsList();
  }
}

class StateStudentsList extends State<StudentsList> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _firstRunRoutineRan = false;

  List<Map<String, dynamic>> _allClasses = List();
  List<Map<String, dynamic>> _allSections = List();

  List<dynamic> _studentsLists = List();

  int _selectedClass;
  int _selectedSection;

  void _getAllClassesAndSections() async {
    _firstRunRoutineRan = true;
    showProgressDialog();
    String sessionToken = await AppData().getSessionToken();

    var allClassesResponse =
        await http.post(GConstants.getAllClassesAndSectionRoute(await AppData().getSchoolUrl()), body: {
      'active_session': sessionToken,
    });

    //print(allClassesResponse.body);

    if (allClassesResponse.statusCode == 200) {
      Map allClassesObject = json.decode(allClassesResponse.body);
      if (allClassesObject.containsKey("status")) {
        if (allClassesObject["status"] == "success") {
          List<dynamic> classes = allClassesObject['data']['class'];
          List<dynamic> sections = allClassesObject['data']['sections'];
          await DbClassSection().insertClassesSections(classes, sections);
          _allClasses = await DbClassSection().getAllClasses();
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

  void _getStudents() async {
    showProgressDialog();

    var newActiveSession = await SessionDbProvider().getActiveSession();
    String sessionToken = await AppData().getSessionToken();

    var studentsResponse = await http.post(GConstants.getStudentsBySectionRoute(await AppData().getSchoolUrl()), body: {
      'class_id': _selectedClass.toString(),
      'section_id': _selectedSection.toString(),
      'session_id': newActiveSession.sessionId.toString(),
      'active_session': sessionToken,
    });

    log(studentsResponse.body, name: "${studentsResponse.request}");

    if (studentsResponse.statusCode == 200) {
      Map studentsObject = json.decode(studentsResponse.body);
      if (studentsObject.containsKey("status")) {
        if (studentsObject["status"] == "success") {
          _studentsLists = studentsObject['data'];
          if (_studentsLists != null && _studentsLists.length == 0) {
            showShortToast(context, "No student in this section");
          }
          setState(() {});
          hideProgressDialog();
          return null;
        } else {
          hideProgressDialog();
          showSnackBar(studentsObject["message"]);
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

  void getSectionsForClass(int classId) async {
    _selectedSection = null;
    _allSections = await DbClassSection().getSectionsByClassId(classId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstRunRoutineRan) {
      Future.delayed(Duration(milliseconds: 100), () async {
        _getAllClassesAndSections();
      });
    }

    return Scaffold(
        key: _scaffoldState,
        body: Container(
          color: Colors.grey.shade200,
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Theme(
                          data: Theme.of(context).copyWith(brightness: Brightness.dark),
                          child: _allClasses.length > 0
                              ? DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                  value: _selectedClass,
                                  items: _allClasses
                                      .map((b) => DropdownMenuItem<int>(
                                            child: Text(
                                              "Class ${b['class_name']}",
                                              style: TextStyle(color: Colors.black, inherit: false),
                                            ),
                                            value: b['id'],
                                          ))
                                      .toList(),
                                  hint: Text(
                                    'Select Class',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onChanged: (b) {
                                    _allSections = [];
                                    setState(() {
                                      _selectedClass = _allClasses
                                          .where((Map<String, dynamic> item) => item['id'] == b)
                                          .toList()[0]['id'];
                                    });
                                    getSectionsForClass(_selectedClass);
                                  },
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ))
                              : Container(
                                  height: 0,
                                )),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Theme(
                          data: Theme.of(context).copyWith(brightness: Brightness.dark),
                          child: _allSections.length > 0
                              ? DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                  value: _selectedSection,
                                  items: _allSections
                                      .map((b) => DropdownMenuItem<int>(
                                            child: Text(
                                              "Section ${b['sec_name']}",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            value: b['id'],
                                          ))
                                      .toList(),
                                  onChanged: (b) {
                                    setState(() {
                                      _selectedSection = _allSections
                                          .where((Map<String, dynamic> item) => item['id'] == b)
                                          .toList()[0]['id'];
                                    });
                                  },
                                  hint: Text(
                                    'Select Section',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                              : Container(
                                  height: 0,
                                )),
                    ),
                    FlatButton(
                      child: Text(
                        "GO",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      shape: CircleBorder(side: BorderSide(color: Colors.white54)),
                      onPressed: () {
                        _getStudents();
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                color: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (){
                        log("${_studentsLists[index]}");
                            navigateToModule(StudentsDetailMain(_studentsLists[index]));
                      },
                      child: Slidable(
                        actionPane: SlidableBehindActionPane(),
                        actionExtentRatio: 0.1,
                        secondaryActions: <Widget>[
                          SlideAction(
                            child: Icon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.white,
                            ),
                            color: Colors.green,
                            onTap: () async {
                              await launch("https://wa.me/91${_studentsLists[index]['mobile']}");
                            },
                          ),
                          SlideAction(
                            child: Icon(Icons.call, color: Colors.white),
                            color: Colors.blueAccent,
                            onTap: () async {
                              await launch("tel://${_studentsLists[index]['mobile']}");
                            },
                          ),
                        ],
                        child: Card(
                          child: Row(
                            children: <Widget>[
                              (_studentsLists[index]['photo_student'] != null
                                  ? GestureDetector(
                                      onTap: () {
                                        showPhoto(index);
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) => Container(
                                              child: Image(
                                                image: AssetImage("assets/dash_icons/ic_profile.png"),
                                                width: 60,
                                                height: 60,
                                                color: Colors.black45,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            imageUrl: _studentsLists[index]['photo_student'],
                                            imageBuilder: (context, imageProvider) => Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          )),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image(
                                        image: AssetImage("assets/dash_icons/ic_profile.png"),
                                        width: 60,
                                        height: 60,
                                        color: Colors.black45,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      _studentsLists[index]['student_name'],
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "Father : ${_studentsLists[index]['father_name']}",
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  ),
                                  Text(
                                    "S. R. No. : ${_studentsLists[index]['s_r_no']}",
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  ),
                                  GestureDetector(
                                    onTap:()async{
                                      if(_studentsLists[index]['mobile']!=null){
                                        await launch("tel://${_studentsLists[index]['mobile']}");
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right:8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            "Mobile No. : ${_studentsLists[index]['mobile']}",
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                          ),
                                          Icon(Icons.call, color: Colors.green, size: 18,),
                                        ],
                                      ),
                                    ),

                                  ),

                                  Container(
                                      width: MediaQuery.of(context).size.width -
                                          MediaQuery.of(context).size.width / 3.5,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(
                                          "Address : ${_studentsLists[index]['address']}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: false,
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                        ),
                                      ])),

                                  Row(
                                    children: <Widget>[
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Text(
                                            _studentsLists[index]['first_app_login'] == null
                                                ? "App Not Installed"
                                                : "First Login : ${DateFormat().addPattern("dd-MMM").format(DateTime.parse(_studentsLists[index]['first_app_login']))}",
                                            style: TextStyle(color: Colors.white, fontSize: 11),
                                          ),
                                        ),
                                        color: _studentsLists[index]['first_app_login'] == null
                                            ? Colors.red.shade400
                                            : Colors.green.shade400,
                                        elevation: 0,
                                      ),
                                      _studentsLists[index]['first_app_login'] != null
                                          ? Card(
                                              child: Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                  "Last Activity: ${DateFormat().addPattern("dd-MMM").format(DateTime.parse(_studentsLists[index]['last_app_activity']))}",
                                                  style: TextStyle(color: Colors.white, fontSize: 11),
                                                ),
                                              ),
                                              color: Colors.orange.shade300,
                                              elevation: 0,
                                            )
                                          : SizedBox()
                                    ],
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                        ),
                      ),
                    );
                  },
                  itemCount: _studentsLists.length,
                ),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
        ));
  }

  void showPhoto(index) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey),
          actions: <Widget>[
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                const PopupMenuItem<String>(
                  value: 'Share',
                  child: Text('Share'),
                )
              ],
              onSelected: (v) {
                //  gridPhotoViewer.takeScreenShot();
              },
            )
          ],
        ),
        body: SizedBox.expand(
          child: CarouselSlider(
            autoPlay: false,
            viewportFraction: 1.0,
            aspectRatio: MediaQuery.of(context).size.aspectRatio,
            enableInfiniteScroll: false,
            items: getPhoto(index).map(
              (photoItem) {
                var photo = Photo(assetName: photoItem.assetName, title: photoItem.title, caption: photoItem.title);
                return GridPhotoViewer(photo: photo);
              },
            ).toList()
            ,
            initialPage: index,
          ),
        ),
      );
    }));
  }

  List<Photo> getPhoto(int index) {
    List<Photo> _imageLists = List();
    var photo = Photo(
        assetName: _studentsLists[index]['photo_student'],
        title: _studentsLists[index]['student_name'],
        caption: _studentsLists[index]['student_name']);
    _imageLists.add(photo);
    return _imageLists;
  }

  void navigateToModule(Widget module) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        body: module,
      );
    }));
  }
}
