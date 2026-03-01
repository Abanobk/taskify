import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/languages/language_switcher_bloc.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import 'custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class RowUserClientList extends StatefulWidget {
  final List<dynamic> list;
  final String title;
 final bool? isusertitle;
  final bool? fromNotification;
   const RowUserClientList(
      {super.key, required this.list, required this.title, this.isusertitle,this.fromNotification});

  @override
  State<RowUserClientList> createState() => _RowUserClientListState();
}

class _RowUserClientListState extends State<RowUserClientList> {
  bool isRtl = false;
  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    isRtl =
        LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _checkRtlLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.title == "client"
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                  text: AppLocalizations.of(context)!.clients,
                  color: Theme.of(context).colorScheme.textClrChange),
              widget.list.isEmpty
                  ? SizedBox(
                      height: 35,
                      // width: 60.w,
                      child: CustomText(
                        text: AppLocalizations.of(context)!.noclient,
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 10.sp,
                      ),
                    )
                  : isRtl
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Stack(children: [
                            Padding(
                              padding: widget.list.length > 2
                                  ? EdgeInsets.only(right: 0.w, left: 24.w)
                                  : EdgeInsets.only(right: 5.w, left: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  for (int i = 0;
                                      i < (widget.list.length );
                                      i++)
                                    if (i < 3)
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
                                ],
                              ),
                            ),
                            if (widget.list.length  > 3)
                              Positioned(
                                left: 0.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.pureWhiteColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    radius: 13.r,
                                    child: CustomText(
                                      text: '+${widget.list.length - 3}',
                                      color: AppColors.pureWhiteColor,
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Stack(children: [
                            Padding(
                              padding: widget.list.length > 2
                                  ? EdgeInsets.only(left: 0.w, right: 24.w)
                                  : EdgeInsets.only(right: 0.w, left: 0),
                              child: SizedBox(
                                // color: Colors.red,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    for (int i = 0;
                                        i < (widget.list.length );
                                        i++)
                                      if (i < 3)
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
                                  ],
                                ),
                              ),
                            ),
                            (widget.list.length > 2)
                                ? Positioned(
                                    right: 0.w,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.pureWhiteColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: AppColors.primary,
                                        radius: 13.r,
                                        child: CustomText(
                                          text: '${widget.list.length - 3}+',
                                          color: AppColors.pureWhiteColor,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ]),
                        ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.isusertitle == false
                  ? SizedBox.shrink()
                  : CustomText(
                      text: AppLocalizations.of(context)!.users,
                      color: Theme.of(context).colorScheme.textClrChange),
              widget.list.isEmpty
                  ? SizedBox(
                      height: 35,
                      // width: 60.w,
                      child: CustomText(
                        text: AppLocalizations.of(context)!.nousers,
                        color: Theme.of(context).colorScheme.textClrChange,
                        size: 10.sp,
                      ),
                    )
                  : isRtl
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Stack(children: [
                            Padding(
                              padding: widget.list.length > 2
                                  ? EdgeInsets.only(right: 2.w, left: 24.w)
                                  : EdgeInsets.only(right: 5.w, left: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  for (int i = 0;
                                      i < (widget.list.length );
                                      i++)
                                    if (i < 3)
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
                                ],
                              ),
                            ),
                            (widget.list.length > 3)
                                ? Positioned(
                                    left: 0.w,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.pureWhiteColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: AppColors.primary,
                                        radius: 13.r,
                                        child: CustomText(
                                          text: '+${widget.list.length - 3}',
                                          color: AppColors.pureWhiteColor,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ]),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: Stack(children: [
                            Padding(
                              padding: widget.list.length >= 3
                                  ? EdgeInsets.only(right:widget.fromNotification == true ? 0.w:0, left: widget.fromNotification == true ?0.w:4.w)
                                  : EdgeInsets.only(right: 0.w, left: 0),
                              child: SizedBox(
                                // color: Colors.red,
                                child: Row(
                                  mainAxisAlignment: widget.fromNotification == true?MainAxisAlignment.end:MainAxisAlignment.start,
                                  children: [
                                    for (int i = 0;
                                        i < (widget.list.length );
                                        i++)
                                      if (i < 3)
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
                                  ],
                                ),
                              ),
                            ),

                              widget.list.length > 3
                                  ? Positioned(
                                      right: widget.fromNotification == true ? 0.w:10.w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.pureWhiteColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: AppColors.primary,
                                          radius: 13.r,
                                          child: CustomText(
                                            text: '${widget.list.length - 3}+',
                                            color: AppColors.pureWhiteColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                          ]),
                        ),
            ],
          );
  }
}
