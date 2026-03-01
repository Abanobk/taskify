import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';

import '../../../utils/widgets/custom_text.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class ColorField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final String? name;
  // final String? color;
  // final List<StatusModel> status;
  final Function(String) onSelected;
  const ColorField(
      {super.key,
      required this.isRequired,
      required this.isCreate,
      required this.name,
      required this.onSelected});

  @override
  State<ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<ColorField> {
  String? colorsname;
  String? name;
  int? colorId;

  // Define the access list here
  List<Map<String, dynamic>> colorList = [
    {"title": "Primary", "color": AppColors.primary},
    {"title": "Secondary", "color": const Color(0xFF8996a6)},
    {"title": "Success", "color": const Color(0xFF3ffb01)},
    {"title": "Danger", "color": const Color(0xFFcc251b)},
    {"title": "Warning", "color": const Color(0xFFf9aa00)},
    {"title": "Info", "color": const Color(0xFF38c2f8)},
    {"title": "Dark", "color": const Color(0xFF060606)},
  ];


  @override
  void initState() {
    super.initState();
    colorsname = widget.name;

    if (widget.isCreate) {
      colorsname ??= colorList[0]['title']; // Set default to first item
    } else {
      if(!widget.isCreate){
        if(widget.name == "primary"){
          colorsname = "Primary";
        }
        else if(widget.name == "secondary"){
          colorsname = "Secondary";
        }else if(widget.name == "success"){
          colorsname = "Success";
        }
        else if(widget.name == "danger"){
          colorsname = "Danger";
        }
        else if(widget.name == "warning"){
          colorsname = "Warning";
        } else if(widget.name == "info"){
          colorsname = "Info";
        } else if(widget.name == "dark"){
          colorsname = "Dark";
        }
      }
    }
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
                text: AppLocalizations.of(context)!.color,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
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
                              itemCount: colorList.length,
                              itemBuilder: (BuildContext context, int index) {
                                print("colorsname $colorsname");
                                final isSelected = colorsname ==
                                    colorList[index]['title'] ;

                                print("isSelected  $isSelected");
                                print("colorList ${(colorList[index]['title'] as String).replaceFirstMapped(RegExp(r'^[A-Z]'), // Match the first uppercase letter
                                    (match) => match.group(0)!.toLowerCase())}");
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  child: InkWell(
                                    highlightColor: Colors
                                        .transparent, // No highlight on tap
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        colorsname = colorList[index]['title'];
                                        print("fgkjngfkfzln ${colorsname}");
                                      });
                                      widget.onSelected(
                                          colorList[index]['title']);
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
                                                SizedBox(
                                                  width: 150.w,
                                                  // color: Colors.red,
                                                  child: Row(
                                                    children: [
                                                      CustomText(
                                                        text: colorList[index]
                                                            ['title'],
                                                        fontWeight: FontWeight.w500,
                                                        size: 18.sp,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        color: isSelected
                                                            ? AppColors.purple
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .textClrChange,
                                                      ),
                                                      SizedBox(width: 10.w,),
                                                      CircleAvatar(
                                                        radius: 7.sp,
                                                        backgroundColor: colorList[index]
                                                        ['color'],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                isSelected
                                                    ? const HeroIcon(
                                                        HeroIcons.checkCircle,
                                                        style:
                                                            HeroIconStyle.solid,
                                                        color: AppColors.purple)
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
                              ? (colorsname?.isEmpty ?? true
                                  ? AppLocalizations.of(context)!.pleaseselect
                                  : colorsname!)
                              : (colorsname?.isEmpty ?? true
                                  ? widget.name!
                                  : colorsname!),
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
