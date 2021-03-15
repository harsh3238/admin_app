import 'package:click_campus_admin/data/models/the_session.dart';
import 'package:click_campus_admin/data/session_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StateHelper {

  BuildContext _context;
  bool _isProgressDialogShowing = false;
  GlobalKey<ScaffoldState> _scaffoldState;
  List<TheSession> allSessions = List();
  TheSession activeSession;

  ///This method must be called in the initState method of the inheriting class
  init(BuildContext context, GlobalKey<ScaffoldState> scaffoldState, {State state}) {
    this._context = context;
    this._scaffoldState = scaffoldState;
    if (state != null) {
      _getSessions(state);
    }
  }

  _getSessions(State state) async {
    allSessions = await SessionDbProvider().getAllSessions();
    activeSession = await SessionDbProvider().getActiveSession();
    state.setState(() {});
  }

  Future<void> setActiveSession(TheSession theSession, State state) async {
    await SessionDbProvider().setActiveSession(theSession.sessionId);
    activeSession = await SessionDbProvider().getActiveSession();
    state.setState(() {});
  }

  void showProgressDialog() {
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 16,
                  ),
                  Text("Please wait..."),
                ],
              ),
            ),
          );
        });
    _isProgressDialogShowing = true;
  }

  void hideProgressDialog() {
    try{
      if (_isProgressDialogShowing) {
        Navigator.pop(_context);
      }
    }catch(_){ }

  }


  void showSnackBar(String text, {Color color = Colors.red}) {
    _scaffoldState.currentState
        .showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }

  void showServerError() {
    showSnackBar("Server error occured", color: Colors.red.shade800);
  }

  //function to show toast message on screen
  void showShortToast(BuildContext context, String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT);
  }

  //function to show long time toast message on screen
  void showLongToast(BuildContext context, String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG);
  }
}
