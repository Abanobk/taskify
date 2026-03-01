import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

class NoPermission extends StatelessWidget {
  const NoPermission({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 50.sp,
            color: AppColors.greyColor,
          ),
          SizedBox(height: 20.h),
          CustomText(
            text: 'You do not have permission to access this feature',
            color: AppColors.greyColor,
            size: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
} 