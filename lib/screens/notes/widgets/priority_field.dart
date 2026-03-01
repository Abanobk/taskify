import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class PriorityField extends StatefulWidget {
  final bool isRequired;
  final bool isLightTheme;
  final String priority;
  final bool isCreate;
  final String selectedCategoryy;
  final Function(String) onCategorySelected; // Callback function

  const PriorityField({
    super.key,
    required this.isLightTheme,
    required this.isRequired,
    required this.priority,
    required this.isCreate,
    required this.selectedCategoryy,
    required this.onCategorySelected, // Initialize the callback
  });

  @override
  State<PriorityField> createState() => _PriorityFieldState();
}

class _PriorityFieldState extends State<PriorityField> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.priority; // Initialize selected category
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.selectpriority,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 15.sp,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ?  CustomText(
                      text: " *",
                      color: AppColors.red,
                      size: 15.sp,
                      fontWeight: FontWeight.w500,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        GestureDetector(
          onTap: () {
            _showPriorityDialog(context);
          },
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.greyColor),
            ),
            child: CustomText(
              text: widget.isCreate
                  ? (selectedCategory?.isEmpty ?? true
                      ?AppLocalizations.of(context)!.selectpriority
                      : selectedCategory!)
                  : (selectedCategory?.isEmpty ?? true
                      ? widget.priority
                      : selectedCategory!),
              fontWeight: FontWeight.w500,
              size: 14.sp,
              color: Theme.of(context).colorScheme.textClrChange,
              // color: (selectedCategory?.isEmpty ?? true)
              //     ? colors.greyForgetColor
              //     : Theme.of(context).colorScheme.textClrChange,
            ),
          ),
        ),
      ],
    );
  }

  void _showPriorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.r), // Set the desired radius here
          ),
          backgroundColor:
              Theme.of(context).colorScheme.alertBoxBackGroundColor,
          title: CustomText(
            text: AppLocalizations.of(context)!.selectpriority,
            fontWeight: FontWeight.w800,
            size: 20.sp,
            color: Theme.of(context).colorScheme.whitepurpleChange,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <String>['low', 'medium', 'high'].map((String value) {
              bool isSelected = selectedCategory ==
                  value; // Determine if the item is selected

              return InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    selectedCategory = value;
                  });
                  widget.onCategorySelected(value); // Send data back to parent
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.purpleShade
                        : Colors
                            .transparent, // Change background color when selected
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  width: double.infinity,
                  height: 40.h,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: value,
                            fontWeight: FontWeight.w500,
                            size: 18.sp,
                            color: isSelected
                                ? AppColors
                                    .purple // Change text color when selected
                                : Theme.of(context).colorScheme.textClrChange,
                          ),
                          if (isSelected) // Show check icon when selected
                            const HeroIcon(
                              HeroIcons.checkCircle,
                              style: HeroIconStyle.solid,
                              color: AppColors.primary,
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
