import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AppColors.dart';
import 'AppConstant.dart';


Text subHeadingText(var text) {
  return Text(
    text,
    style: TextStyle(fontFamily: fontBold, fontSize: 17.5, color: appTextColorSecondary),
  );
}

Widget text(var text, {var fontSize = textSizeLargeMedium, textColor = appTextColorSecondary, var fontFamily = fontRegular, var isCentered = false, var maxLine = 1, var latterSpacing = 0.5}) {
  return Text(text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: maxLine,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor, height: 1.5, letterSpacing: latterSpacing));
}


showToast(BuildContext aContext, String caption, {Color color}) {
  Scaffold.of(aContext).showSnackBar(SnackBar(content: text(caption, textColor: appWhite, isCentered: false,), backgroundColor: color,));
}

launchScreen(context, String tag, {Object arguments}) {
  if (arguments == null) {
    Navigator.pushNamed(context, tag);
  } else {
    Navigator.pushNamed(context, tag, arguments: arguments);
  }
}

BoxDecoration boxDecoration({double radius = 2, Color color = Colors.transparent, Color bgColor = appWhite, var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow ? [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)] : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}


String convertDate(date) {
  try {
    return date != null ? DateFormat(dateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    print(e);
    return '';
  }
}



Widget placeholderWidget() => Image.asset('images/LikeButton/image/grey.jpg');
