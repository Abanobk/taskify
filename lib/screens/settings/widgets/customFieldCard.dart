
import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/app_images.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';

Widget customFieldChild(isLightTheme, field,context,profilePic) {
  return Container(
      decoration: BoxDecoration(
          boxShadow: [
            isLightTheme
                ? MyThemes.lightThemeShadow
                : MyThemes.darkThemeShadow,
          ],
          color: Theme.of(context).colorScheme.containerDark,
          borderRadius: BorderRadius.circular(12)),
      // height: 170.h,
      child: Padding(
        padding: EdgeInsets.only(
            top: 20.h, left: 18.w, right: 18.w),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.start,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                CustomText(
                  text:
                  "#${field.id.toString()}",
                  size: 12.sp,
                  color:
                  AppColors.projDetailsSubText,
                  fontWeight: FontWeight.w600,
                ),
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
                        text: field.fieldType,
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
            SizedBox(
              height: 15.h,
            ),
            _buildFieldRow(AppImages.modulesImage, "Module",context,field.module),
            _buildFieldRow(AppImages.labelImage, "Label",context,field.fieldLabel),

              // _buildFieldRow("Field Type", "select",context),
            SizedBox(
              height: 10.h,
            ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.backGroundColor,

    ),
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 8.w,vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldRow(AppImages.requiredImage, "Required",context,field.required=="1" ?"Yes":"No"),
            _buildFieldRow(AppImages.tableImage, "Table",context,field.showInTable=="1" ?"Yes":"No"),
          ],
        ),
      ),
    ),
            SizedBox(height: 10.h,)
          ],
        ),
      ));
}

Widget _buildFieldRow(String image, String label,context,String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Tooltip(
            message: label,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
// border: Border.all(color: Colors.blueAccent, width: 1),
            ),
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            waitDuration: Duration(milliseconds: 300),
            showDuration: Duration(seconds: 2),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child:Container(
// color: Colors.red,
              child: Image.asset(image, height: 20.h, width: 20.w),
            )),
        SizedBox(width: 10.w,),
        CustomText(
          text: value,
          fontWeight:
          FontWeight
              .w500,
          maxLines: 1,
          overflow:
          TextOverflow
              .ellipsis,
          size: 12.sp,
          color: Theme.of(
              context)
              .colorScheme
              .textClrChange,
        ),
      ],
    ),
  );
}




