import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/colors.dart';
import 'custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

Widget statusClientRow(String? status, String? priority, BuildContext context, bool detailPage) {

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      if (status != null && status.isNotEmpty)
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.status,
              size: 15.sp,
              color: Theme.of(context).colorScheme.textClrChange,
              fontWeight: detailPage ? FontWeight.w800 : FontWeight.normal,
            ),
            SizedBox(height: 5.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 140.w),
              child: IntrinsicWidth(
                child: Container(
                  alignment: Alignment.center,
                  height: 25.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.shade800,
                  ),
                  child: CustomText(
                    text: status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.whiteColor,
                    size: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      if (priority != null && priority.isNotEmpty)
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.priority,
              size: 15.sp,
              color: Theme.of(context).colorScheme.textClrChange,
              fontWeight: detailPage ? FontWeight.w800 : FontWeight.normal,
            ),
            SizedBox(height: 5.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 140.w),
              child: IntrinsicWidth(
                child: Container(
                  alignment: Alignment.center,
                  height: 25.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange.shade500,
                  ),
                  child: CustomText(
                    text: priority,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.whiteColor,
                    size: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
    ],
  );
}

