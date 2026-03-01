import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:taskify/config/colors.dart';
import '../../config/app_images.dart';
import '../../utils/widgets/custom_text.dart';

Widget singleDetails(
    {
      bool? isTickIcon,
      int? valueOfSwitch,
      bool? isSwitch,
      required String label,
       String? title,
      bool? button,
     required BuildContext context,
      Color? color}) {
  bool isSwitchValue= false;
  if(valueOfSwitch == 1){
    isSwitchValue = true;

  }else{
    isSwitchValue = false;
  }
  return SizedBox(
    // color: Colors.red,
    // width:  290.w,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: label,
            // text:getTranslated(context, "email"),
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 14.sp,
            fontWeight: FontWeight.w600,
          ),


         isSwitch == true ? FlutterSwitch(
           height: 15.h,
           width: 30.w,
           padding: 2.w,
           toggleSize: 15.sp,
           borderRadius: 10.r,
           inactiveColor: AppColors.greyColor.withValues(alpha: 0.5),
           activeColor: AppColors.primary,
           value: isSwitchValue,
           // Use the local state variable
           onToggle: (value) {

           },
         ):isTickIcon == true
             ? Container(
           height: 30.h,
           width: 20.w,
           decoration: BoxDecoration(
             image: DecorationImage(
               image: title == "Email Verified"
                   ? AssetImage(AppImages.meetingTickImage)
                   : AssetImage(AppImages.crossImage),
               fit: BoxFit.cover,
             ),
           ),
         )
             : button == true
             ? Container(
           alignment: Alignment.center,
           height: 25.h,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             color: color,
           ),
           child: Padding(
             padding: EdgeInsets.symmetric(horizontal: 10.w),
             child: CustomText(
               text: title!,
               color: AppColors.whiteColor,
               size: 15,
               fontWeight: FontWeight.w600,
             ),
           ),
         )
             : CustomText(
           text: title!,
           color: Theme.of(context).colorScheme.textClrChange,
           size: 14.sp,
           maxLines: 1,
           overflow: TextOverflow.ellipsis,
           fontWeight: FontWeight.w400,
         ),
        ],
      ),
    ),
  );
}