import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

Future<void> userClientDialog(
    {required list, required String title, required String from,String? isFrom ,required BuildContext context}) {

  return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10.r), // Set the desired radius here
          ),
          backgroundColor:
          Theme.of(context).colorScheme.alertBoxBackGroundColor,
          contentPadding: EdgeInsets.zero,
          title: Center(
            child: Column(
              children: [
                CustomText(
                  text: title,
                  fontWeight: FontWeight.w800,
                  size: 20,
                  color: Theme.of(context).colorScheme.whitepurpleChange,
                ),
                const Divider(),
              ],
            ),
          ),
          content: Container(
            constraints: BoxConstraints(maxHeight: 900.h),
            width: 300.w,
            child:list.isNotEmpty ?ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (from == "client") {
                        router.push(
                          '/clientdetails',
                          extra: {
                            "id": list[index].id,
                          },
                        );

                        router.pop(context);

                      } if(from == "user" ) {
                        router.push('/userdetail', extra: {
                          "id": list[index].id,
                        "from":"homescreen"

                        });
                        router.pop(context);
                      } if(from == "task") {
                        router.push(
                          '/taskdetail',
                          extra: {
                            "id": list[index].id,
                          },
                        );
                        router.pop(context);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.transparent,

                            radius: 20,
                            backgroundImage: NetworkImage(list[index].photo!),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Column(  // Changed from Row to Column to stack vertically
                                crossAxisAlignment: CrossAxisAlignment.start,  // Align items to the left
                                children: [
                                  Row(  // First row with names
                                    children: [
                                      Flexible(
                                        child: CustomText(
                                          text: list[index].firstName!,
                                          fontWeight: FontWeight.w500,
                                          size: 18.sp,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          color: Theme.of(context).colorScheme.textClrChange,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      Flexible(
                                        child: CustomText(
                                          text: list[index].lastName!,
                                          fontWeight: FontWeight.w500,
                                          size: 18.sp,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          color: Theme.of(context).colorScheme.textClrChange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(height: 2.h),  // Add some spacing between rows
                                  Row(
                                    children: [
                                      Flexible(
                                        child: CustomText(
                                          text: list[index].email??"",
                                          fontWeight: FontWeight.w400,
                                          size: 14.sp,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          color: AppColors.greyColor,
                                        ),
                                      ),
                                    ],
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ): CustomText(
                textAlign:
                TextAlign.center,
                text: AppLocalizations.of(
                    context)!
                    .nodata,
                color: Theme.of(context)
                    .colorScheme
                    .textClrChange)
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6)),
                        height: 30.h,
                        width: 100.w,
                        margin: EdgeInsets.symmetric(vertical: 10.h),
                        child: CustomText(
                          text: AppLocalizations.of(context)!.ok,
                          size: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pureWhiteColor,
                        )),
                  ),
                ],
              ),
            ),
          ],
        );
      }));
}