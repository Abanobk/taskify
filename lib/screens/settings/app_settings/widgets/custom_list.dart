import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../src/generated/i18n/app_localizations.dart';import '../../../../utils/widgets/custom_text.dart';
import '../../../widgets/custom_cancel_create_button.dart';


import 'package:heroicons/heroicons.dart';



class CustomListField extends StatefulWidget {
  final bool isRequired;
  final String? name;
  // final String? typeName;
  final String? title;
  // final List<StatusModel> status;

  final Function(String) onTypeSelected;
  final Function(String) onSmtpEncryptionSelected;
  final Function(String) onrequestMethodSelected;
  final Function(String) onStorageSelected;
  final Function(String) onFollowUpTypeSelected;
  final Function(String) onStatusSelected;
  const CustomListField(
      {super.key,
        required this.isRequired,
        required this.title,
        // required this.smtpName,
        required this.name,
        required this.onSmtpEncryptionSelected,
        required this.onrequestMethodSelected,
        required this.onStorageSelected,
        required this.onTypeSelected,
        required this.onFollowUpTypeSelected,
        required this.onStatusSelected,

      });

  @override
  State<CustomListField> createState() => _CustomListFieldState();
}

class _CustomListFieldState extends State<CustomListField> {
  String? typeName;

  String? smtpEncryptionName;
  String? requestMethodName;
  String? followupTypeName;
  String? storageName;
  String? statusName;

  // Define the access list here
  List<String> type = ["Text", "HTML"];
  List<String> smtpEncryption = ["off", "TLS","SSL"];
  List<String> method = ["POST", "GET"];
  List<String> storage = ["Local Storage", "Amazone AWS S3"];
  List<String> followUpList = ["Call", "E-mail", "Meeting","SMS","Other"];
  List<String> statusList = ["Pending", "Completed", "Rescheduled"];

  @override
  void initState() {
if(widget.title == "emailContentType") {
  typeName = widget.name;
}
if(widget.title == "smtpEncryption") {
  smtpEncryptionName = widget.name;
}
if(widget.title == "requestMethod") {
  requestMethodName = widget.name;
}if(widget.title == "followupType") {
  // followupTypeName = widget.name;
  followupTypeName ??= followUpList.contains(widget.name) ? widget.name : followUpList[0];
}

if (widget.title == "storage") {
  // Only set the default if `storageName` is null or empty
  storageName ??= storage.contains(widget.name) ? widget.name : storage[0];
}if (widget.title == "status") {
  // Only set the default if `storageName` is null or empty
  statusName ??= statusList.contains(widget.name) ? widget.name : statusList[0];
}
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
                text: () {
                  switch (widget.title) {
                    case "emailContentType":
                      return AppLocalizations.of(context)!.emailcontenttype;
                    case "smtpEncryption":
                      return AppLocalizations.of(context)!.smtpencryption;
                      case "requestMethod":
                      return AppLocalizations.of(context)!.method;
                      case "followupType":
                      return AppLocalizations.of(context)!.followupType;
                      case "storage":
                      return AppLocalizations.of(context)!.selectmediastorage;
                      case "status":
                      return AppLocalizations.of(context)!.status;
                    default:
                      return "";
                  }
                }(),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
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
        widget.title == "emailContentType"?   AbsorbPointer(
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
                                  itemCount: type.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected =  typeName!.toLowerCase() == type[index].toLowerCase();


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,                                    onTap: () {
                                        setState(() {
                                            typeName = type[index];
                                            widget.onTypeSelected(type[index]);

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
                                                        text: type[index],

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
                          text: typeName?.isEmpty ?? true
                              ? widget.name!
                              : typeName!,
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
        ):SizedBox.shrink(),
       widget.title =="smtpEncryption" ?AbsorbPointer(
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
                                  itemCount: smtpEncryption.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected = smtpEncryptionName!.toLowerCase() == smtpEncryption[index].toLowerCase();


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,                                    onTap: () {
                                        setState(() {

                                          smtpEncryptionName = smtpEncryption[index];

                                          widget.onSmtpEncryptionSelected(smtpEncryption[index]);

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
                                                        text: smtpEncryption[index],

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
                          text: smtpEncryptionName?.isEmpty ?? true
                              ? widget.name!
                              : smtpEncryptionName!,
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
        ):SizedBox.shrink(),
       widget.title =="requestMethod" ?AbsorbPointer(
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
                                  itemCount: method.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected = requestMethodName!.toLowerCase() == method[index].toLowerCase();


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,                                    onTap: () {
                                        setState(() {

                                          requestMethodName = method[index];

                                          widget.onrequestMethodSelected(method[index]);

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
                                                        text: method[index],

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
                          text: requestMethodName?.isEmpty ?? true
                              ? widget.name!
                              : requestMethodName!,
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
        ):SizedBox.shrink(),
       widget.title =="storage" ?AbsorbPointer(
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
                                  itemCount: storage.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected = storageName!.toLowerCase() == storage[index].toLowerCase();


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                        setState(() {

                                          storageName = storage[index];

                                          widget.onStorageSelected(storage[index]);

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
                                                        text: storage[index],

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
                          text: storageName?.isEmpty ?? true
                              ? widget.name!
                              : storageName!,
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
        ):SizedBox.shrink(),
       widget.title =="followupType" ?AbsorbPointer(
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
                                  itemCount: followUpList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected = followupTypeName!.toLowerCase() == followUpList[index].toLowerCase();


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                        setState(() {

                                          followupTypeName = followUpList[index];

                                          widget.onFollowUpTypeSelected(followUpList[index]);

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
                                                        text: followUpList[index],

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
                          text: followupTypeName?.isEmpty ?? true
                              ? widget.name!
                              : followupTypeName!,
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
        ):SizedBox.shrink(),
       widget.title =="status" ?AbsorbPointer(
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
                                  itemCount: statusList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final isSelected = statusName!.toLowerCase() == statusList[index].toLowerCase();


                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: InkWell(
                                        highlightColor: Colors.transparent, // No highlight on tap
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                        setState(() {

                                          statusName = statusList[index];

                                          widget.onStatusSelected(statusList[index]);

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
                                                        text: statusList[index],

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
                          text: statusName?.isEmpty ?? true
                              ? widget.name!
                              : statusName!,
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
        ):SizedBox.shrink(),
      ],
    );
  }
}


