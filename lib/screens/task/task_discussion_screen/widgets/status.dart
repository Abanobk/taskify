import 'package:flutter/material.dart';

import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../../utils/widgets/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';

import '../../../widgets/custom_cancel_create_button.dart';

class StatusOfMileStone extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final String? statusName;
  final Function(String) onSelected;
  const StatusOfMileStone({super.key,required this.isCreate , required this.isRequired,required this.onSelected,required this.statusName});

  @override
  State<StatusOfMileStone> createState() => _StatusOfMileStoneState();
}

class _StatusOfMileStoneState extends State<StatusOfMileStone> {
  String? statusname;

  List<String> status = ["Complete", "Incomplete"];


  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text:AppLocalizations.of(context)!.status,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true ?  const CustomText(
                text: " *",
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              ):const SizedBox.shrink(),
            ],
          ),
        ),
        // SizedBox(height: 5.h),
        AbsorbPointer(
          absorbing: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) setState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),  // Set the desired radius here
                              ),
                              backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,

                              contentPadding: EdgeInsets.zero,
                              title: Center(
                                child: Column(
                                  children: [
                                    CustomText(
                                      text: AppLocalizations.of(context)!.pleaseselect,
                                      fontWeight: FontWeight.w800,
                                      size: 20,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .whitepurpleChange,
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              ),
                              content: Container(
                                constraints: BoxConstraints(maxHeight: 900.h),
                                width:MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: status.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected =  statusname == status[index];


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,                                    onTap: () {
                                        setState(() {
                                          if (widget.isCreate == true) {
                                            statusname = status[index];

                                            widget.onSelected(status[index]);
                                          } else {
                                            statusname = status[index];
                                            widget.onSelected(status[index]);
                                          }
                                        });
                                      },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20.w,
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            height: 35.h,
                                            decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors
                                                    .purpleShade
                                                    : Colors
                                                    .transparent,
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    10),
                                                border: Border.all(
                                                    color: isSelected
                                                        ? AppColors
                                                        .purple
                                                        : Colors
                                                        .transparent)),
                                            child:  Center(
                                              child: Padding(
                                                padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width:150.w,
                                                      // color: Colors.red,
                                                      child: CustomText(
                                                        text: status[index],

                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        size: 18.sp,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        color: isSelected
                                                            ? AppColors
                                                            .purple
                                                            : Theme.of(
                                                            context)
                                                            .colorScheme
                                                            .textClrChange,
                                                      ),
                                                    ),
                                                    isSelected ?  const HeroIcon(
                                                        HeroIcons
                                                            .checkCircle,
                                                        style: HeroIconStyle
                                                            .solid,
                                                        color: AppColors
                                                            .purple):const SizedBox.shrink(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: CreateCancelButtom(
                                    title: "OK",
                                    onpressCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onpressCreate: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  height: 40.h,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyColor),

                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: widget.isCreate
                              ? (statusname?.isEmpty ?? true
                              ? AppLocalizations.of(context)!.pleaseselect
                              : statusname!)
                              : (statusname?.isEmpty ?? true
                              ? widget.statusName!
                              : statusname!),
                          fontWeight: FontWeight.w500,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
