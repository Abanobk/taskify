import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/data/model/settings/timezone_model.dart';

import '../../../../bloc/setting/settings_bloc.dart';
import '../../../../bloc/setting/settings_event.dart';
import '../../../../src/generated/i18n/app_localizations.dart';import '../../../../utils/widgets/custom_text.dart';
import '../../../widgets/custom_cancel_create_button.dart';
import '../../lists/static_list.dart';

class CurrencyFormatField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final String? subtitle;
  final String? name;
  final String? title;
  final String? access;
  // final List<StatusModel> status;
  final Function(String) onSelectedSymbol;
  final Function(String) onSelectedFormated;
  final Function(String, String) onSelectedDateFormat;
  final Function(String, String) onSelectedTimeFormatChange;
  final Function(String, String) onSelectedTimeZoneFormatChange;
  const CurrencyFormatField({
    super.key,
    required this.isRequired,
    required this.isCreate,
    this.title,
    this.subtitle,
    required this.access,
    required this.name,
    required this.onSelectedSymbol,
    required this.onSelectedTimeFormatChange,
    required this.onSelectedTimeZoneFormatChange,
    required this.onSelectedFormated,
    required this.onSelectedDateFormat,
  });

  @override
  State<CurrencyFormatField> createState() => _CurrencyFormatFieldState();
}

class _CurrencyFormatFieldState extends State<CurrencyFormatField> {
  String? Currencyname;
  String? dateFormatName;
  String? timeFormatName;
  String? timeZoneFormatName;

  String? CurrencySymbolName;
  String? nameOfCurrency;
  String? nameOfFormat;
  String? nameOfSymbol;
  int? projectsId;
  TextEditingController searchController = TextEditingController();
  List<TimeZoneInfoModel> timezoneList = [];
  List<TimeZoneInfoModel> displayedList = [];
  String NameOfTimeFormat = "";

  // Define the access list here

  @override
  void initState() {
    BlocProvider.of<SettingsBloc>(context).add(const SettingsList("general_settings"));

    if (widget.title == "currencySymbol") {
      CurrencySymbolName = widget.name;
    }
    if (widget.title == "currencyFormat") {
      Currencyname = widget.name;
    }
    if (widget.title == "dateFormat") {
      dateFormatName = widget.name;
    }
    if (widget.title == "timeFormat") {
      timeFormatName = widget.name;
    }
    if (widget.title == "systemTimezone") {
      timeZoneFormatName = widget.name;
      print("zgrnjzkvm , $timeFormatName");
    }
    timezoneList = context.read<SettingsBloc>().timeZoneList;
    displayedList = timezoneList.take(20).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currencyFormat = [
      {"index": 0, "label": AppLocalizations.of(context)!.commaseperated},
      {"index": 1, "label": AppLocalizations.of(context)!.dotseperated},
    ];

    List<Map<String, dynamic>> currencySymbol = [
      {
        "index": 0,
        "label": "${AppLocalizations.of(context)!.before} \$100",
      },
      {
        "index": 1,
        "label": "${AppLocalizations.of(context)!.after} 100.000\$",
      },
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title == "currencyFormat")
                CustomText(
                  text: AppLocalizations.of(context)!.currencyformat,
                  color: Theme.of(context).colorScheme.textClrChange,

                  size: 16.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,


                  fontWeight: FontWeight.w700,
                ),
              if (widget.title == "currencySymbol")
                CustomText(
                  text: AppLocalizations.of(context)!.currencysymbolposition,
                  color: Theme.of(context).colorScheme.textClrChange,

                  size: 16.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,



                  fontWeight: FontWeight.w700,
                ),
              if (widget.title == "dateFormat")
                CustomText(
                  text: AppLocalizations.of(context)!.dateformat,
                  color: Theme.of(context).colorScheme.textClrChange,

                  size: 16.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,



                  fontWeight: FontWeight.w700,
                ),
              if (widget.title == "timeFormat")
                CustomText(
                  text: AppLocalizations.of(context)!.timeformat,
                  color: Theme.of(context).colorScheme.textClrChange,

                  size: 16.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,



                  fontWeight: FontWeight.w700,
                ),
              if (widget.title == "systemTimezone")
                CustomText(
                  text: AppLocalizations.of(context)!.systemtimezone,
                  color: Theme.of(context).colorScheme.textClrChange,

                  size: 16.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,



                  fontWeight: FontWeight.w700,
                ),
              widget.isRequired == true
                  ? const CustomText(
                      text: " *",
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: AppColors.red,
                      size: 15,
                      fontWeight: FontWeight.w400,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        if (widget.subtitle != null )
          widget.subtitle == "" ?SizedBox(height: 5.h,):    Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 18.w), // Add spacing if needed
            child: CustomText(
              text: widget.subtitle!,
              color: AppColors.greyColor,
              size: 12.sp,
              fontWeight: FontWeight.w500,
              maxLines: null, // Allow unlimited lines
            ),
          ),
        // SizedBox(height: 5.h),
        if (widget.title == "currencySymbol")
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
                        return StatefulBuilder(builder: (BuildContext context,
                            void Function(void Function()) setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.r), // Set the desired radius here
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .alertBoxBackGroundColor,
                            contentPadding: EdgeInsets.zero,
                            title: Center(
                              child: Column(
                                children: [
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .pleaseselect,
                                    fontWeight: FontWeight.w800,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .whitepurpleChange,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                            content: Container(
                              constraints: BoxConstraints(maxHeight: 900.h),
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: currencySymbol.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final int itemIndex =
                                      currencySymbol[index]["index"];
                                  final String label =
                                      currencySymbol[index]["label"];

                                  final int selectedIndex =
                                      (CurrencySymbolName ==
                                              currencySymbol[0]["label"])
                                          ? 0
                                          : 1;
                                  print("jgfgzswdsd hn ${CurrencySymbolName}");
                                  final bool isSelected =
                                      itemIndex == selectedIndex;
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          CurrencySymbolName = label;
                                        });

                                        // Notify parent widget
                                        widget.onSelectedSymbol(label);

                                        // Close the dialog after selection
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          // height: 35.h,
                                          decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.purpleShade
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.purple
                                                      : Colors.transparent)),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 18.w),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      width: 150.w,
                                                      // height: 70.h,
                                                      // color: Colors.red,
                                                      child: CustomText(
                                                        text: label,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        size: 18.sp,
                                                        maxLines:
                                                            null, // Allow unlimited lines
                                                        softwrap:
                                                            true, // Make sure text is fully displayed
                                                        color: isSelected
                                                            ? AppColors.purple
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .textClrChange,
                                                      ),
                                                    ),
                                                  ),
                                                  isSelected
                                                      ? const HeroIcon(
                                                          HeroIcons.checkCircle,
                                                          style: HeroIconStyle
                                                              .solid,
                                                          color:
                                                              AppColors.purple)
                                                      : const SizedBox.shrink(),
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
                        });
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
                                ? (CurrencySymbolName?.isEmpty ?? true
                                    ? AppLocalizations.of(context)!.pleaseselect
                                    : CurrencySymbolName!)
                                : (CurrencySymbolName?.isEmpty ?? true
                                    ? widget.name!
                                    : CurrencySymbolName!),
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
          ),
        if (widget.title == "currencyFormat")
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
                        return StatefulBuilder(builder: (BuildContext context,
                            void Function(void Function()) setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.r), // Set the desired radius here
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .alertBoxBackGroundColor,
                            contentPadding: EdgeInsets.zero,
                            title: Center(
                              child: Column(
                                children: [
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .pleaseselect,
                                    fontWeight: FontWeight.w800,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .whitepurpleChange,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                            content: Container(
                              constraints: BoxConstraints(maxHeight: 900.h),
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: currencyFormat.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final int itemIndex =
                                      currencyFormat[index]["index"];
                                  final String label =
                                      currencyFormat[index]["label"];
                                  int selectedIndex =
                                      Currencyname!.contains("comma_separated")
                                          ? 0
                                          : 1;
                                  final isSelected =
                                      (itemIndex == selectedIndex);

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                    child: InkWell(
                                      highlightColor: Colors
                                          .transparent, // No highlight on tap
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          if (widget.isCreate == true) {
                                            Currencyname = label;

                                            widget.onSelectedFormated(label);
                                          } else {
                                            Currencyname = label;
                                            widget.onSelectedFormated(label);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          // height: 35.h,
                                          decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.purpleShade
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.purple
                                                      : Colors.transparent)),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 18.w),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      width: 150.w,
                                                      // height: 70.h,
                                                      // color: Colors.red,
                                                      child: CustomText(
                                                        text: label,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        size: 18.sp,
                                                        maxLines:
                                                            null, // Allow unlimited lines
                                                        softwrap:
                                                            true, // Make sure text is fully displayed
                                                        color: isSelected
                                                            ? AppColors.purple
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .textClrChange,
                                                      ),
                                                    ),
                                                  ),
                                                  isSelected
                                                      ? const HeroIcon(
                                                          HeroIcons.checkCircle,
                                                          style: HeroIconStyle
                                                              .solid,
                                                          color:
                                                              AppColors.purple)
                                                      : const SizedBox.shrink(),
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
                        });
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
                                ? (Currencyname ==""
                                    ? AppLocalizations.of(context)!.pleaseselect
                                    : Currencyname!)
                                : (Currencyname?.isEmpty ?? true
                                    ? widget.name!
                                    : Currencyname!),
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
          ),
        if (widget.title == "dateFormat")
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
                        return StatefulBuilder(builder: (BuildContext context,
                            void Function(void Function()) setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.r), // Set the desired radius here
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .alertBoxBackGroundColor,
                            contentPadding: EdgeInsets.zero,
                            title: Center(
                              child: Column(
                                children: [
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .pleaseselect,
                                    fontWeight: FontWeight.w800,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .whitepurpleChange,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                            content: Container(
                              constraints: BoxConstraints(maxHeight: 900.h),
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: dateFormat.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final isSelected = dateFormatName ==
                                      dateFormat[index].values.first;

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                    child: InkWell(
                                      highlightColor: Colors
                                          .transparent, // No highlight on tap
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          dateFormatName =
                                              dateFormat[index].values.first;
                                          dateFormatName =
                                              dateFormat[index].values.first;
                                          widget.onSelectedDateFormat(
                                              dateFormat[index].values.first,
                                              dateFormat[index].keys.first);
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          // height: 35.h,
                                          decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.purpleShade
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.purple
                                                      : Colors.transparent)),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 18.w),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      width: 150.w,
                                                      // height: 70.h,
                                                      // color: Colors.red,
                                                      child: CustomText(
                                                        text: dateFormat[index]
                                                            .values
                                                            .first,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        size: 18.sp,
                                                        maxLines:
                                                            null, // Allow unlimited lines
                                                        softwrap:
                                                            true, // Make sure text is fully displayed
                                                        color: isSelected
                                                            ? AppColors.purple
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .textClrChange,
                                                      ),
                                                    ),
                                                  ),
                                                  isSelected
                                                      ? const HeroIcon(
                                                          HeroIcons.checkCircle,
                                                          style: HeroIconStyle
                                                              .solid,
                                                          color:
                                                              AppColors.purple)
                                                      : const SizedBox.shrink(),
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
                        });
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
                                ? (dateFormatName == ""
                                    ? AppLocalizations.of(context)!.pleaseselect
                                    : dateFormatName!)
                                : (dateFormatName?.isEmpty ?? true
                                    ? widget.name!
                                    : dateFormatName!),
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
          ),
        if (widget.title == "timeFormat")
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
                        return StatefulBuilder(builder: (BuildContext context,
                            void Function(void Function()) setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.r), // Set the desired radius here
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .alertBoxBackGroundColor,
                            contentPadding: EdgeInsets.zero,
                            title: Center(
                              child: Column(
                                children: [
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .pleaseselect,
                                    fontWeight: FontWeight.w800,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .whitepurpleChange,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                            content: Container(
                              constraints: BoxConstraints(maxHeight: 900.h),
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: timeFormat.length,
                                itemBuilder: (BuildContext context, int index) {
                                  print("jffj ${timeFormatName}");
                                  final isSelected = timeFormatName ==
                                      timeFormat[index].values.first;

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                    child: InkWell(
                                      highlightColor: Colors
                                          .transparent, // No highlight on tap
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          timeFormatName =
                                              timeFormat[index].values.first;

                                          widget.onSelectedTimeFormatChange(
                                              dateFormat[index].values.first,
                                              dateFormat[index].keys.first);
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          // height: 35.h,
                                          decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.purpleShade
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.purple
                                                      : Colors.transparent)),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 18.w),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      width: 150.w,
                                                      // height: 70.h,
                                                      // color: Colors.red,
                                                      child: CustomText(
                                                        text: dateFormat[index]
                                                            .values
                                                            .first,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        size: 18.sp,
                                                        maxLines:
                                                            null, // Allow unlimited lines
                                                        softwrap:
                                                            true, // Make sure text is fully displayed
                                                        color: isSelected
                                                            ? AppColors.purple
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .textClrChange,
                                                      ),
                                                    ),
                                                  ),
                                                  isSelected
                                                      ? const HeroIcon(
                                                          HeroIcons.checkCircle,
                                                          style: HeroIconStyle
                                                              .solid,
                                                          color:
                                                              AppColors.purple)
                                                      : const SizedBox.shrink(),
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
                        });
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
                                ? (NameOfTimeFormat.isEmpty
                                    ? AppLocalizations.of(context)!.pleaseselect
                                    : NameOfTimeFormat)
                                : (NameOfTimeFormat == ""
                                    ? widget.name!
                                    : NameOfTimeFormat),
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
          ),
        if (widget.title == "systemTimezone")
          AbsorbPointer(
            absorbing: false,
            child: InkWell(
              highlightColor: Colors.transparent, // No highlight on tap
              splashColor: Colors.transparent,
              onTap: () {
                print("sfdzxfgdZXfd");
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .alertBoxBackGroundColor,
                          contentPadding: EdgeInsets.zero,
                          title: Column(
                            children: [
                              CustomText(
                                text: AppLocalizations.of(context)!
                                    .pleaseselect,
                                fontWeight: FontWeight.w800,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .whitepurpleChange,
                              ),
                              const Divider(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.w),
                                child: SizedBox(
                                  // color: Colors.red,
                                  height: 35.h,
                                  width: double.infinity,
                                  child: TextField(
                                    cursorColor:
                                    AppColors.greyForgetColor,
                                    cursorWidth: 1,
                                    controller:
                                    searchController,
                                    decoration: InputDecoration(
                                      contentPadding:
                                      EdgeInsets.symmetric(
                                        vertical:
                                        (35.h - 20.sp) / 2,
                                        horizontal: 10.w,
                                      ),
                                      hintText:
                                      AppLocalizations.of(
                                          context)!
                                          .search,
                                      enabledBorder:
                                      OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors
                                              .greyForgetColor, // Set your desired color here
                                          width:
                                          1.0, // Set the border width if needed
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(
                                            10.0), // Optional: adjust the border radius
                                      ),
                                      focusedBorder:
                                      OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            10.0),
                                        borderSide: BorderSide(
                                          color: AppColors
                                              .purple, // Border color when TextField is focused
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value.isEmpty) {
                                            // Show the first 20 items when there's no search input
                                            displayedList = timezoneList
                                                .take(20)
                                                .toList();
                                          } else {
                                            // Get the complete list from the BLoC
                                            List<TimeZoneInfoModel> fullList =
                                                context
                                                    .read<SettingsBloc>()
                                                    .timeZoneList;

                                            // Search through the entire list
                                            displayedList = fullList
                                                .where((timeZone) =>
                                            timeZone.region
                                                .toLowerCase()
                                                .contains(value
                                                .toLowerCase()) ||
                                                timeZone.time
                                                    .toLowerCase()
                                                    .contains(value
                                                    .toLowerCase()) ||
                                                timeZone.utcOffset
                                                    .toLowerCase()
                                                    .contains(value
                                                    .toLowerCase()))
                                                .toList();
                                          }
                                        });
                                      }
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                            ],
                          ),
                          content: Container(
                            constraints: BoxConstraints(maxHeight: 400.h),
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: displayedList.length,
                              itemBuilder: (context, index) {
                                var timeList = displayedList[index];
                                final bool isSelected =
                                    timeList.region == timeZoneFormatName;

                                return InkWell(

                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      // Store both the region name (for tracking selection) and the formatted display text
                                      timeZoneFormatName = timeList.region;
                                      NameOfTimeFormat = "${timeList.region} GMT ${timeList.time} ${timeList.utcOffset}";
                                    });

                                    // Pass the selection back to the parent
                                    widget.onSelectedTimeFormatChange(timeList.region, timeList.utcOffset);

                                    // Optionally close the dialog immediately upon selection
                                    // Navigator.pop(context);
                                    // If you want to keep the dialog open until OK is pressed, remove the line above
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2.h, horizontal: 20.w),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.purpleShade
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.purple
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: ListTile(
                                        title: CustomText(
                                          text:
                                              "${timeList.region} GMT ${timeList.time} ${timeList.utcOffset}",
                                          fontWeight: FontWeight.w500,
                                          size: 18.sp,
                                          color: isSelected
                                              ? AppColors.purple
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                        ),
                                        trailing: isSelected
                                            ? const HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple)
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Inside the AlertDialog actions section, replace the current CreateCancelButtom widget with this:

                          actions: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 20.h),
                              child: CreateCancelButtom(
                                title: "OK",
                                onpressCancel: () {
                                  searchController.clear();
                                  Navigator.pop(context);
                                },
                                onpressCreate: () {
                                  // Confirm the selected timezone and pass data back
                                  if (timeZoneFormatName != null && timeZoneFormatName!.isNotEmpty) {
                                    // Find the selected timezone model to get its complete data
                                    TimeZoneInfoModel? selectedModel = context
                                        .read<SettingsBloc>()
                                        .timeZoneList
                                        .firstWhere(
                                          (element) => element.region == timeZoneFormatName,
                                      orElse: () => TimeZoneInfoModel(region: "", time: "", utcOffset: ""),
                                    );

                                    // Only update if we found a valid selection
                                    if (selectedModel.region.isNotEmpty) {
                                      setState(() {
                                        NameOfTimeFormat = "${selectedModel.region} GMT ${selectedModel.time} ${selectedModel.utcOffset}";
                                      });

                                      // Pass the selected data back to the parent
                                      widget.onSelectedTimeZoneFormatChange(
                                          selectedModel.region,
                                          selectedModel.utcOffset
                                      );
                                    }
                                  }
                                  searchController.clear();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        );
                      },
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
                            ? (NameOfTimeFormat.isEmpty
                                ? AppLocalizations.of(context)!.pleaseselect
                                : NameOfTimeFormat)
                            : (NameOfTimeFormat.isEmpty
                                ? widget.name!
                                : NameOfTimeFormat),
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
          )
      ],
    );
  }
}
