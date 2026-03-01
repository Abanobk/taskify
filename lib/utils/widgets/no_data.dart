import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/app_images.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

class NoData extends StatelessWidget {
  final bool isImage;
  final String message;

  const NoData({Key? key, this.isImage = false,this.message="No data found"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isImage)
              Image.asset(
                AppImages.noDataFoundImage,
                width: 400.w,
                height: 300.h,
              ),
            SizedBox(height: 20.h),
            CustomText(
              text: message,
              color: AppColors.greyColor,
              size: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
} 