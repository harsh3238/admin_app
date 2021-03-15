import 'package:click_campus_admin/views/admission/form_sale.dart';
import 'package:click_campus_admin/views/admission/registration.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';

import 'enquiries.dart';

class AdmissionMain extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateAdmissionMain();
  }
}

class StateAdmissionMain extends State<AdmissionMain> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  EnquiriesTab _tabViewOne = EnquiriesTab();
  FormSaleTab _tabViewTwo = FormSaleTab();
  RegistrationTab _tabViewThree = RegistrationTab();

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: activeSession != null
                  ? Text(activeSession.sessionName)
                  : Container(
                      height: 0,
                    ),
              textColor: Colors.white,
              disabledColor: Colors.white,
              onPressed: () {
                var dialog = SimpleDialog(
                  title: const Text('Change Session'),
                  children: allSessions.map((oneSessionItem) {
                    return SimpleDialogOption(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          oneSessionItem.sessionName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, oneSessionItem);
                      },
                    );
                  }).toList(),
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) => dialog,
                ).then((value) {
                  //print(value);
                  setActiveSession(value, this).then((v) {
                    _tabViewOne.sessionChanged(value);
                    _tabViewTwo.sessionChanged(value);
                    _tabViewThree.sessionChanged(value);
                  });
                });
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Enquiry"),
              Tab(text: "Form Sale"),
              Tab(text: "Registration")
            ],
          ),
          title: Text('Admission'),
        ),
        body: TabBarView(
          children: [
            _tabViewOne,
            _tabViewTwo,
            _tabViewThree
          ],
        ),
      ),
    );
  }
}
