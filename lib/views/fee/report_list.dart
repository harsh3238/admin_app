
import 'package:click_campus_admin/views/fee/cancelled_receipt_report.dart';
import 'package:click_campus_admin/views/state_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ReportListState();
  }
}

class ReportListState extends State<ReportList> with StateHelper {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _didGetData = false;
  bool downloading = false;
  var progress = "";
  List<dynamic> filteredUsers = [];
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    super.init(context, _scaffoldState, state: this);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didGetData) {
      _didGetData = true;
      Future.delayed(Duration(milliseconds: 100), () async {
        showProgressDialog();
        await getData();
      });
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text("More Reports"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 5,
              right: 5,
              top: 5,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: filteredUsers.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    if (index == 0) {
                      navigateToModule(
                          CancelledReceiptReport());
                    }
                  },
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  filteredUsers[index]["title"],
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              new Spacer(), // I just added one line
                              Icon(Icons.navigate_next, color: Colors.black)
                            ],
                          ),

//                          Text(
//                            filteredUsers[index].email.toLowerCase(),
//                            style: TextStyle(
//                              fontSize: 14.0,
//                              color: Colors.grey,
//                            ),
//                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getData() async {

    Future.delayed(Duration(milliseconds: 500), () async {
      filteredUsers.add({"id": "1", "title": "Cancelled Receipts"});
      filteredUsers.add({"id": "1", "title": "Pending Receipts"});
      hideProgressDialog();
      setState(() {
      });
    });

  }

  void navigateToModule(Widget module) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => module),
    );
  }

  void getPaymentAmount() async {}
}
