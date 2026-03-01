import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/screens/widgets/no_data.dart';

import '../../utils/widgets/custom_text.dart';
import 'custom_cancel_create_button.dart';
import 'package:heroicons/heroicons.dart';
import '../../../src/generated/i18n/app_localizations.dart';


class AccessibiltyField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
   final String? name;
  final String? access;
  // final List<StatusModel> status;
  final int? index;
  final Function(String) onSelected;
   const AccessibiltyField(
      {super.key,
        required this.isRequired,
        required this.isCreate,
        required this.access,
        required this.name,
        required this.index,
        required this.onSelected});

  @override
  State<AccessibiltyField> createState() => _AccessibiltyFieldState();
}

class _AccessibiltyFieldState extends State<AccessibiltyField> {
  String? projectsname;
  String? name;
  int? projectsId;

  // Define the access list here
  List<String> access = ["Assigned User", "Project Users"];

  @override
  void initState() {

    name =widget.name;
 if(!widget.isCreate){
   if(widget.access == "assigned_users"){
     projectsname = "Assigned User";
   } else if(widget.access == "project_users"){
     projectsname = "Project Users";
   }
 }
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text:AppLocalizations.of(context)!.taskaccessibility,
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
                                child: access.isEmpty?NoData(isImage: true,):ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: access.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected =  projectsname == access[index];


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,                                    onTap: () {
                                        setState(() {
                                          if (widget.isCreate == true) {
                                            projectsname = access[index];

                                            widget.onSelected(access[index]);
                                          } else {
                                            name = access[index];
                                            projectsname = access[index];
                                            widget.onSelected(access[index]);
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
                                                        text: access[index],

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
                              ? (projectsname?.isEmpty ?? true
                              ? AppLocalizations.of(context)!.pleaseselect
                              : projectsname!)
                              : (projectsname?.isEmpty ?? true
                              ? widget.name!
                              : projectsname!),
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


