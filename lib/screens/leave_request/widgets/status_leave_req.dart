import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/colors.dart';
import '../../../utils/widgets/custom_text.dart';







// Widget fromTimeField(isLightTheme,context,_timestart) {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.start,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Row(
//           children: [
//             CustomText(
//               text: AppLocalizations.of(context)!.fromtime,
//               // text: getTranslated(context, 'myweeklyTask'),
//               color: Theme.of(context).colorScheme.textClrChange,
//               size: 16,
//               fontWeight: FontWeight.w500,
//             ),
//             const CustomText(
//               text: " *",
//               // text: getTranslated(context, 'myweeklyTask'),
//               color: AppColors.red,
//               size: 15,
//               fontWeight: FontWeight.w400,
//             ),
//           ],
//         ),
//       ),
//       SizedBox(
//         height: 5.h,
//       ),
//       Container(
//           margin: EdgeInsets.only(left: 10.w, right: 10.w),
//           padding: EdgeInsets.symmetric(horizontal: 0.w),
//           height: 40.h,
//           // margin: EdgeInsets.only(left: 20, right: 10),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.greyColor),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           // decoration: DesignConfiguration.shadow(),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: InkWell(
//               splashColor: Colors.transparent,
//               onTap: () {
//                 setState(() {
//                   _selectstartTime();
//                 });
//               },
//               child: Row(
//                 children: [
//                   const HeroIcon(
//                     size: 20,
//                     HeroIcons.clock,
//                     style: HeroIconStyle.outline,
//                     color: AppColors.greyForgetColor,
//                   ),
//                   SizedBox(
//                     width: 10.w,
//                   ),
//                   CustomText(
//                     text: _timestart.format(context),
//                     fontWeight: FontWeight.w400,
//                     size: 14.sp,
//                     color: Theme.of(context).colorScheme.textClrChange,
//                   ),
//                 ],
//               ),
//             ),
//           ))
//     ],
//   );
// }

// Widget toTimeField(isLightTheme,context) {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.start,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Row(
//           children: [
//             CustomText(
//               text: AppLocalizations.of(context)!.totime,
//               // text: getTranslated(context, 'myweeklyTask'),
//               color: Theme.of(context).colorScheme.textClrChange,
//               size: 16,
//               fontWeight: FontWeight.w500,
//             ),
//             const CustomText(
//               text: " *",
//               // text: getTranslated(context, 'myweeklyTask'),
//               color: AppColors.red,
//               size: 15,
//               fontWeight: FontWeight.w700,
//             ),
//           ],
//         ),
//       ),
//       SizedBox(
//         height: 5.h,
//       ),
//       Container(
//           margin: const EdgeInsets.only(right: 10, left: 10),
//           padding: EdgeInsets.symmetric(horizontal: 0.w),
//           height: 40.h,
//           // margin: EdgeInsets.only(left: 20, right: 10),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.greyColor),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           // decoration: DesignConfiguration.shadow(),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: InkWell(
//               splashColor: Colors.transparent,
//               onTap: () {
//
//                 setState(() {
//                   _selectendTime();
//                 });
//               },
//               child: Row(
//                 children: [
//                   HeroIcon(
//                     size: 20.sp,
//                     HeroIcons.clock,
//                     style: HeroIconStyle.outline,
//                     color: AppColors.greyForgetColor,
//                   ),
//                   SizedBox(
//                     width: 10.w,
//                   ),
//                   CustomText(
//                     text: _timeend.format(context),
//                     fontWeight: FontWeight.w400,
//                     size: 14.sp,
//                     color: Theme.of(context).colorScheme.textClrChange,
//                   ),
//                 ],
//               ),
//             ),
//           ))
//     ],
//   );
// }

Widget daysField(isLightTheme, statusOfPartial, title, inDaysHours,context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(right: 0.w),
        child: CustomText(
          text: inDaysHours,
          // text: getTranslated(context, 'myweeklyTask'),
          color: Theme.of(context).colorScheme.textClrChange,
          size: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      SizedBox(
        height: 5.h,
      ),
      Container(
          alignment: Alignment.center,
          // padding: EdgeInsets.symmetric(horizontal: 12.w),
          height: 40.h,
          width: double.infinity,
          margin: EdgeInsets.only(right: 0.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          // decoration: DesignConfiguration.shadow(),
          child: Center(
              child: CustomText(
                text: title,
                fontWeight: FontWeight.w400,
                size: 14.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              )))
    ],
  );
}