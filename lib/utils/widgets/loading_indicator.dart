import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final bool isLightTheme;
  final double? size;

  const LoadingIndicator({
    Key? key,
    required this.isLightTheme,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 24.w,
        height: size ?? 24.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          valueColor: AlwaysStoppedAnimation<Color>(
            isLightTheme ? AppColors.primary : AppColors.white,
          ),
        ),
      ),
    );
  }
} 