import 'package:carousel_slider/carousel_slider.dart';
import 'package:click_campus_admin/views/fee/collection.dart';
import 'package:click_campus_admin/views/fee/concession/concession_report.dart';
import 'package:click_campus_admin/views/fee/discount/discount_report.dart';
import 'package:flutter/material.dart';

import 'fee_dues.dart';

class DashCard extends StatelessWidget {
  List<dynamic> _collectionData = [];

  DashCard(this._collectionData);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      shadowColor: Colors.grey.shade300,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child: CarouselSlider(
                height: 30.0,
                autoPlay: true,
                viewportFraction: 1.0,
                autoPlayInterval: Duration(seconds: 4),
                items: [0, 1, 2].map((d) {
                  var name;
                  var data;
                  switch (d) {
                    case 0:
                      name = "Today's Collection";
                      data = _collectionData[0]['todays'];
                      break;
                    case 1:
                      name = "Weeks's Collection";
                      data = _collectionData[0]['weeks'];
                      break;
                    default:
                      name = "Months's Collection";
                      data = _collectionData[0]['months'];
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(data ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ))
                    ],
                  );
                }).toList(),
                pauseAutoPlayOnTouch: Duration(seconds: 2),
              ),
            ),
            Divider(
              height: 0,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(child: Column(
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius:
                            new BorderRadius.all(new Radius.circular(60.0)),
                            color: Colors.grey.shade100),
                        child: Image(image: AssetImage("assets/fee_dash/ic_collection.png")),
                      ),
                      Text("Collection",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ))
                    ],
                  ), onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) {
                          return FeeCollection();
                        }));
                  },),
                  GestureDetector(child: Column(
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius:
                            new BorderRadius.all(new Radius.circular(60.0)),
                            color: Colors.grey.shade100),
                        child: Image(image: AssetImage("assets/fee_dash/ic_dues.png")),
                      ),
                      Text("Dues",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ))
                    ],
                  ), onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) {
                          return FeeDues();
                        }));
                  },),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) {
                            return DiscountReport();
                          }));
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius:
                              new BorderRadius.all(new Radius.circular(60.0)),
                              color: Colors.grey.shade100),
                          child:Image(image: AssetImage("assets/fee_dash/ic_discount.png")),
                        ),
                        Text("Discounts",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ))
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) {
                            return ConcessionReport();
                          }));
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius:
                              new BorderRadius.all(new Radius.circular(60.0)),
                              color: Colors.grey.shade100),
                          child:Image(image: AssetImage("assets/fee_dash/ic_conession.png")),
                        ),
                        Text("Concession",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ))
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius:
                            new BorderRadius.all(new Radius.circular(60.0)),
                            color: Colors.grey.shade100),
                        child: Image(image: AssetImage("assets/fee_dash/ic_expenses.png")),
                      ),
                      Text("Expense",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
