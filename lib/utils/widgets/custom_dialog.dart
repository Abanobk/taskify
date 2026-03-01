import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_colors.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final bool isLightTheme;
  final double? width;
  final double? height;

  const CustomDialog({
    Key? key,
    required this.child,
    required this.isLightTheme,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: isLightTheme ? AppColors.white : AppColors.darkGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(16.w),
        child: child,
      ),
    );
  }
} 