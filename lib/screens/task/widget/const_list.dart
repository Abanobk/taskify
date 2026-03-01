import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:heroicons/heroicons.dart';

import '../../../utils/widgets/custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';


class ConstListField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final int? index;
  final String? access;
  final String? from;

  final Function(int) onSelected;
  const ConstListField(
      {super.key,
        required this.isRequired,
        required this.isCreate,
        required this.access,
        required this.index,
        required this.from,

        required this.onSelected});

  @override
  State<ConstListField> createState() => _ConstListFieldState();
}

class _ConstListFieldState extends State<ConstListField> {
  String? projectsname;
  String? name;
  int? projectsId;

  List<String> type = ["None", "Billable","Non Billable"];
  List<String> frequencyType = ["Daily", "Monthly","Weekly","Yearly"];
  List<String> dayOfTheWeek = ["Any Day", "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  List<String> dayOfTheMonth = [
    "Any Day", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
    "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
    "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"
  ];
  List<String> monthsOfYear = [
    "Any Month","January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];


  @override
  void initState() {
    print("jnhk hh  ${widget.index}");
    // name = widget.name;
    if(widget.from == "recurrencefrequencytype"){
      if (!widget.isCreate) {
        switch (widget.access?.toLowerCase()) {
          case "":
          case null:
            projectsname = "Daily"; // Default value
            break;
          case "daily":
            projectsname = "Daily";
            break;
          case "weekly":
            projectsname = "Weekly";
            break;
          case "monthly":
            projectsname = "Monthly";
            break;
          case "yearly":
            projectsname = "Yearly";
            break;
          default:
            projectsname = "Daily"; // Fallback
            break;
        }
      }

    }
    if(widget.from == "dayofWeek") {
      if (!widget.isCreate) {
        switch (widget.index) {
          case 0:
          case null:
            projectsname = "Any Day"; // Default value
            break;
          case 1:
            projectsname = "Any Day";
            break;
          case 2:
            projectsname = "Monday";
            break;
          case 3:
            projectsname = "Tuesday";
            break;
          case 4:
            projectsname = "Wednesday";
            break;
          case 5:
            projectsname = "Thursday";
            break;
          case 6:
            projectsname = "Friday";
            break;
          case 7:
            projectsname = "Saturday";
            break;
          case 8:
            projectsname = "Sunday";
            break;
          default:
            projectsname = "Any Day"; // Fallback
            break;
        }
      }
    }

    if (widget.from == "monthofyear") {
      if (!widget.isCreate) {
        switch (widget.index) {
          case 0:
          case null:
            projectsname = "Any Day"; // Default value
            break;
          case 1:
            projectsname = "January";
            break;
          case 2:
            projectsname = "February";
            break;
          case 3:
            projectsname = "March";
            break;
          case 4:
            projectsname = "April";
            break;
          case 5:
            projectsname = "May";
            break;
          case 6:
            projectsname = "June";
            break;
          case 7:
            projectsname = "July";
            break;
          case 8:
            projectsname = "August";
            break;
          case 9:
            projectsname = "September";
            break;
          case 10:
            projectsname = "October";
            break;
          case 11:
            projectsname = "November";
            break;
          case 12:
            projectsname = "December";
            break;
          default:
            projectsname = "Any Day"; // Fallback
            break;
        }
      }
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Widget buildContent() {
      switch (widget.from) {
        case "billing":
          return buildWidget(title: AppLocalizations.of(context)!.billingtype,type: type);
        case "frequencytype":
          return buildWidget(title: AppLocalizations.of(context)!.frequencttype,type: frequencyType);
        case "dayofWeek":
          return buildWidget(title: AppLocalizations.of(context)!.dayofweek,type: dayOfTheWeek);
          case "recurrencefrequencytype":
          return buildWidget(title: AppLocalizations.of(context)!.recurrencefrequency,type: frequencyType);
          case "dayofmonth":
          return buildWidget(title: AppLocalizations.of(context)!.dayofthemonth,type: dayOfTheMonth);
          case "monthofyear":
          return buildWidget(title: AppLocalizations.of(context)!.monthofyear,type: monthsOfYear);
        default:
          return const SizedBox.shrink(); // Empty if `widget.from` is unknown
      }
    }

    return buildContent();
  }

 Widget  buildWidget({required String title,required List<String> type}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text:title,
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
                  int selectedIndex = type.indexOf(projectsname ?? type.first);

                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
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
                                    color: Theme.of(context).colorScheme.whitepurpleChange,
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
                                itemCount: type.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final isSelected = selectedIndex == index;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                          projectsname = type[index];
                                          widget.onSelected(index);
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                                        child: Container(
                                          width: double.infinity,
                                          height: 35.h,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected ? AppColors.purple : Colors.transparent,
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: 150.w,
                                                    child: CustomText(
                                                      text: type[index],
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,

                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Expanded(
                                                      flex:
                                                      1,
                                                      child: const HeroIcon(HeroIcons.checkCircle,
                                                          style: HeroIconStyle.solid,
                                                          color: AppColors.purple),
                                                    )
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
                          text:  projectsname?.isEmpty ?? true
                              ? AppLocalizations.of(context)!.pleaseselect
                              : projectsname!,
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


class BilingListField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final String? name;
  final String? access;
  final String? from;

  final Function(String) onSelected;
  const BilingListField(
      {super.key,
        required this.isRequired,
        required this.isCreate,
        required this.access,
        required this.name,
        required this.from,

        required this.onSelected});

  @override
  State<BilingListField> createState() => _BilingListFieldState();
}

class _BilingListFieldState extends State<BilingListField> {
  String? projectsname;
  String? name;
  int? projectsId;

  List<String> type = ["None", "Billable","Non Billable"];
  List<String> frequencyRecurrenceType = ["Daily", "Monthly","Weekly","Yearly"];
  List<String> frequencyType = ["Daily", "Monthly","Weekly",];


  @override
  void initState() {
print("rgbhnjkm ");
    print("scchj ${widget.name}");
    print("sdsfdsdsd ${widget.from}");
    // name = widget.name;
    if(widget.from == "billing") {
      if (!widget.isCreate) {
        switch (widget.access) {
          case "":
          case null:
            projectsname = "None";
            break;
          case "None":
          case "none":
            projectsname = "None";
            break;
          case "Billable":
          case "billable":
            projectsname = "Billable";
            break;
          case "Non Billable":
          case "non Billable":
            projectsname = "Non Billable";
            break;
        }

      }
    }
    if(widget.from == "frequencytype"){
      print("cuvbh #${widget.access!.toLowerCase()}");
      if (!widget.isCreate) {
        switch (widget.access!.toLowerCase()) {
          case "":
            projectsname = "Daily"; // Default value
            break;
          case "daily":
            projectsname = "Daily";
            break;
          case "weekly":
            projectsname = "Weekly";
            break;
          case "monthly":
            projectsname = "Monthly";
            break;

          default:
            projectsname = "Daily"; // Fallback
            break;
        }
      }

    }
    // name = widget.name;
    if(widget.from == "recurrencefrequencytype"){
      print("cuvbh #${widget.access!.toLowerCase()}");
      if (!widget.isCreate) {
        switch (widget.access?.toLowerCase()) {
          case "":
          case null:
            projectsname = "Daily"; // Default value
            break;
          case "daily":
            projectsname = "Daily";
            break;
          case "weekly":
            projectsname = "Weekly";
            break;
          case "monthly":
            projectsname = "Monthly";
            break;
          case "yearly":
            projectsname = "Yearly";
            break;
          default:
            projectsname = "Daily"; // Fallback
            break;
        }
      }

    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Widget buildContent() {
      switch (widget.from) {
        case "billing":
          return buildWidget(title: AppLocalizations.of(context)!.billingtype,type: type);
        case "frequencytype":
          return buildWidget(title: AppLocalizations.of(context)!.frequencttype,type: frequencyType);
          case "recurrencefrequencytype":
          return buildWidget(title: AppLocalizations.of(context)!.recurrencefrequency,type: frequencyRecurrenceType);
        default:
          return const SizedBox.shrink(); // Empty if `widget.from` is unknown
      }
    }

    return buildContent();
  }

 Widget  buildWidget({required String title,required List<String> type}){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text:title,
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
                  int selectedIndex = type.indexOf(projectsname ?? type.first);

                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
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
                                    color: Theme.of(context).colorScheme.whitepurpleChange,
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
                                itemCount: type.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final isSelected = selectedIndex == index;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                          projectsname = type[index];
                                          widget.onSelected(type[index]);
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                                        child: Container(
                                          width: double.infinity,
                                          height: 35.h,
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isSelected ? AppColors.purple : Colors.transparent,
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: 150.w,
                                                    child: CustomText(
                                                      text: type[index],
                                                      fontWeight: FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,

                                                    ),
                                                  ),
                                                  isSelected
                                                      ? Expanded(
                                                    flex:
                                                    1,
                                                    child: const HeroIcon(HeroIcons.checkCircle,
                                                        style: HeroIconStyle.solid,
                                                        color: AppColors.purple),
                                                  ):SizedBox()
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


