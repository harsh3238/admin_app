import 'package:click_campus_admin/views/fee/dues/dues_all.dart';
import 'package:click_campus_admin/views/fee/dues/fee_dues_class_wise.dart';
import 'package:flutter/material.dart';

class DueFeesMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: "All Dues",
              ),
              Tab(text: "Class Wise Dues"),
            ],
          ),
          title: Text('Fees'),
        ),
        body: TabBarView(
          children: [
            DuesAll(),
            FeeDuesClassWise(),
          ],
        ),
      ),
    );
  }
}
