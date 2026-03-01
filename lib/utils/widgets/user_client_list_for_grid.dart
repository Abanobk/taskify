import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/languages/language_switcher_bloc.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import 'custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class RowUserClientGridList extends StatefulWidget {
  final List<dynamic> list;
  final String title;
  final bool? isUsertTtle;
  const RowUserClientGridList(
      {super.key, required this.list, required this.title, this.isUsertTtle});

  @override
  State<RowUserClientGridList> createState() => _RowUserClientGridListState();
}

class _RowUserClientGridListState extends State<RowUserClientGridList> {
  bool isRtl = false;
  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    isRtl =
        LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);
    setState(() {});
  }

  @override
  void initState() {
    print("tyghujikl; ${widget.list.length}");
    // TODO: implement initState
    super.initState();
    _checkRtlLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.title == "client"
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.clients,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 10.sp,
              ),
              widget.list.isEmpty
                  ? Center(
                      child: Container(
                          alignment: isRtl ?Alignment.centerLeft:Alignment.centerRight,
                          // width: 60.w,
                          height: 35.h,
                          // color: Colors.red,
                          child: CustomText(
                            text: AppLocalizations.of(context)!.noclient,
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 8.sp,
                          )))
                  : SizedBox(
                      // width: 60.w,
                      height: 35.h,
                       // color: Colors.teal,
                      child:isRtl ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Loop through the list and display the first avatar (if there's at least one user)
                          for (int i = 0; i < (widget.list.length ); i++)
                            if (i < 1) // Only show the first avatar
                              Align(
                                widthFactor: 0.75,
                                child: CircleAvatar(
                                  radius: 15.r,
                                  backgroundColor: Colors.white,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.greyColor,
                                        width: 1.5.w,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 15.r,
                                      backgroundImage: NetworkImage(widget.list[i].photo!),
                                    ),
                                  ),
                                ),
                              ),
                          // Show the "+N" text if there are more than 1 user
                          if (widget.list.length > 1)
                            Container(
                              margin: EdgeInsets.only(left: 0.w), // Add a little margin to separate the avatar from the +N text
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.pureWhiteColor,
                                  width: 1.5.w,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                radius: 13.r,
                                child: CustomText(
                                  text: '${widget.list.length - 1}+',
                                  color: AppColors.pureWhiteColor,
                                ),
                              ),
                            ),
                        ],
                      )
                          :
                      SizedBox(
                        // color: Colors.yellow,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.end,   // Client should be aligned at the end
                          children: [
                            for (int i = 0; i < (widget.list.length ); i++)
                              if (i < 1)
                                Align(
                                  widthFactor: 0.75.w,
                                  child: CircleAvatar(
                                    radius: 15.r,
                                    backgroundColor: Colors.white,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.greyColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 15.r,
                                        backgroundImage: NetworkImage(
                                            widget.list[i].photo!),
                                      ),
                                    ),
                                  ),
                                ),
                            // Add the custom text if there are more than 2 items in the list (for LTR)
                            if (widget.list.length > 1 )
                              Align(
                                widthFactor: 0.75.w,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 30.r,
                                  width: 30.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                  child: CustomText(
                                    text: '+${widget.list.length - 1}',
                                    color: AppColors.pureWhiteColor,
                                  ),
                                ),
                              ),

                            // Loop through the list and display the first two avatars


                            // Add the custom text if there are more than 2 items in the list (for RTL)

                          ],
                        ),



                      )
                ,
                    ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.users,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 10.sp,
              ),
              widget.list.isEmpty
                  ? Center(
                      child: Container(
                          alignment: isRtl ? Alignment.centerRight:Alignment.centerLeft,
                          width: 60.w,
                          height: 35.h,
                          // color: Colors.red,
                          child: CustomText(
                            text: AppLocalizations.of(context)!.nousers,
                            color: Theme.of(context).colorScheme.textClrChange,
                            size: 8.sp,
                          )))
                  : SizedBox(
                      width: 60.w,
                      height: 35.h,
                      // color: Colors.teal,
                      child: isRtl ?
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,   // Client should be aligned at the end
                        children: [
                          for (int i = 0; i < (widget.list.length ); i++)
                            if (i < 1)
                              Align(
                                widthFactor: 0.75.w,
                                child: CircleAvatar(
                                  radius: 15.r,
                                  backgroundColor: Colors.white,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.greyColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 15.r,
                                      backgroundImage: NetworkImage(
                                          widget.list[i].photo!),
                                    ),
                                  ),
                                ),
                              ),
                          // Add the custom text if there are more than 2 items in the list (for LTR)
                          if (widget.list.length > 1 )
                            Align(
                              widthFactor: 0.75.w,
                              child: Container(
                                alignment: Alignment.center,
                                height: 30.r,
                                width: 30.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: CustomText(
                                  text: '+${widget.list.length - 1}',
                                  color: AppColors.pureWhiteColor,
                                ),
                              ),
                            ),

                          // Loop through the list and display the first two avatars


                          // Add the custom text if there are more than 2 items in the list (for RTL)

                        ],
                      ):
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,   // Client should be aligned at the end
                        children: [
                          for (int i = 0; i < (widget.list.length); i++)
                            if (i < 1)
                              Align(
                                widthFactor: 0.75.w,
                                child: CircleAvatar(
                                  radius: 15.r,
                                  backgroundColor: Colors.white,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.greyColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 15.r,
                                      backgroundImage: NetworkImage(
                                          widget.list[i].photo!),
                                    ),
                                  ),
                                ),
                              ),
                          // Add the custom text if there are more than 2 items in the list (for LTR)
                          if (widget.list.length > 1 )
                            Align(
                              widthFactor: 0.75.w,
                              child: Container(
                                alignment: Alignment.center,
                                height: 30.r,
                                width: 30.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: CustomText(
                                  text: '+${widget.list.length - 1}',
                                  color: AppColors.pureWhiteColor,
                                ),
                              ),
                            ),

                          // Loop through the list and display the first two avatars


                          // Add the custom text if there are more than 2 items in the list (for RTL)

                        ],
                      ),
                    ),
            ],
          );
  }
}
