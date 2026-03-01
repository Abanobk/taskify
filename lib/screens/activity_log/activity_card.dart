
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
Widget activityChild(isLightTheme, activityLog, dateCreated,context,profilePic) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 20.h, left: 18.w, right: 18.w),
                    child: SizedBox(
                      // height: 40.h,

                      // color: Colors.yellow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text:
                                        "#${activityLog.id.toString()}",
                                        size: 12.sp,
                                        color:
                                        AppColors.projDetailsSubText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      SizedBox(
                                        // color: Colors.red,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              // width:30.w,
                                              // alignment: Alignment.center,
                                              child: CircleAvatar(
                                                radius: 25.r,
                                                backgroundColor:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .backGroundColor,
                                                child: profilePic != null
                                                    ? CircleAvatar(
                                                  backgroundImage:
                                                  NetworkImage(
                                                      profilePic!),
                                                  radius: 25
                                                      .r, // Size of the profile image

                                                )
                                                    : CircleAvatar(
                                                  radius: 25
                                                      .r, // Size of the profile image
                                                  backgroundColor:
                                                  Colors.grey[
                                                  200],
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 20.sp,
                                                    color:
                                                    Colors.grey,
                                                  ), // Replace with your image URL
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            SizedBox(
                                              width: 140.w,
                                              // color: Colors.orange,
                                              child: CustomText(
                                                text: activityLog
                                                    .actorName ??
                                                    "",
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange,
                                                size: 17,
                                                maxLines: 2,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.only(left: 0.w),
                                        child: SizedBox(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the top
                                                children: [
                                                  HeroIcon(
                                                    HeroIcons.envelope,
                                                    style: HeroIconStyle.outline,
                                                    color: AppColors.projDetailsSubText,
                                                    size: 20.sp,
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(maxWidth: 180.w), // Adjust width accordingly
                                                    child: CustomText(
                                                      text: activityLog.message ?? "No message",
                                                      color: Colors.grey,
                                                      size: 15,
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: null,
                                                      softwrap: true,
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                  ),


                                                ],
                                              ),

                                              SizedBox(
                                                height: 10.w,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  HeroIcon(
                                                    HeroIcons.clock,
                                                    style: HeroIconStyle
                                                        .outline,
                                                    color: AppColors
                                                        .projDetailsSubText,
                                                    size: 20.sp,
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Container(

                                                    // width: 220.w,
                                                    alignment:
                                                    Alignment.topLeft,
                                                    // color: Colors.orange,
                                                    child: CustomText(
                                                      text: dateCreated,
                                                      color: Colors.grey,
                                                      size: 15,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20.w,
                                      ),
                                    ],
                                  )

                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Divider(color: colors.darkColor),
                ]),
          ),

        ],
      ));
}