import 'package:click_campus_admin/views/fee/payments/fee_class_wise.dart';
import 'package:click_campus_admin/views/fee/payments/fee_dashboard.dart';
import 'package:click_campus_admin/views/fee/payments/fee_date_wise.dart';
import 'package:flutter/material.dart';

class FeesMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Dashboard",
              ),
              Tab(text: "Date Wise"),
              Tab(text: "Class Wise"),
            ],
          ),
          title: Text('Fees'),
        ),
        body: TabBarView(
          children: [
            FeeDashboard(),
            FeeDateWise(),
            FeeClassWise(),
          ],
        ),
      ),
    );
  }
}
