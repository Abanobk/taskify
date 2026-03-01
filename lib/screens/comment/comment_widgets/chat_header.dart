import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';

import '../../../config/colors.dart';
import '../../../utils/widgets/custom_text.dart';

class ChatHeader extends StatelessWidget {
  final String title;
  ChatHeader({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      width: double.infinity,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(left: 0.w, right: 10.w, top: 20.h),
        child: Row(
          children: [
            IconButton(
              icon: HeroIcon(
                HeroIcons.chevronLeft,
                size: 26.sp,
                color: AppColors.pureWhiteColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: CustomText(
                  text: title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  color: AppColors.whiteColor,
                  size: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}