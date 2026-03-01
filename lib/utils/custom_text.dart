import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './app_colors.dart';

Widget titleTask(BuildContext context, String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).brightness == Brightness.light
          ? AppColors.black
          : AppColors.white,
    ),
  );
} 