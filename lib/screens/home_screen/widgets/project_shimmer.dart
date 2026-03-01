import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/colors.dart';

class ProjectShimmer extends StatelessWidget {
  const ProjectShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200.w,
                height: 20.h,
                color: AppColors.whiteColor,
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                height: 40.h,
                color: AppColors.whiteColor,
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.w,
                    height: 20.h,
                    color: AppColors.whiteColor,
                  ),
                  Container(
                    width: 100.w,
                    height: 20.h,
                    color: AppColors.whiteColor,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80.w,
                    height: 20.h,
                    color: AppColors.whiteColor,
                  ),
                  Container(
                    width: 80.w,
                    height: 20.h,
                    color: AppColors.whiteColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 