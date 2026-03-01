import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import '../../config/colors.dart';

void customToasts({
  required String message,
  ToastGravity gravity = ToastGravity.BOTTOM,
  Color backgroundColor = AppColors.primary,
  Color textColor = Colors.white,
  int durationInSeconds = 10,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: gravity,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 16.0,
    timeInSecForIosWeb: durationInSeconds,
  );
}
