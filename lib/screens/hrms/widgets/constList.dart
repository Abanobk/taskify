import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';

class CustomSelectField extends StatefulWidget {
  final bool isRequired;
  final bool isCreate;
  final bool isFilter;
  final String? initialValue;
  final String title;
  final List<String> items;
  final Function(String) onSelected;

  const CustomSelectField({
    super.key,
    required this.title,
    required this.items,
    required this.onSelected,
    this.initialValue,
    this.isRequired = false,
    this.isCreate = true,
    this.isFilter = false,
  });

  @override
  State<CustomSelectField> createState() => _CustomSelectFieldState();
}

class _CustomSelectFieldState extends State<CustomSelectField> {
  late ValueNotifier<String?> selectedValueNotifier;

  @override
  void initState() {
    super.initState();
    selectedValueNotifier = ValueNotifier<String?>(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: widget.title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              if (widget.isRequired)
                const CustomText(
                  text: " *",
                  color: AppColors.red,
                  size: 15,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        AbsorbPointer(
          absorbing: false,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              if (widget.isCreate || widget.isFilter) {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    int selectedIndex = widget.items.indexWhere(
                          (item) => item.toLowerCase() == (selectedValueNotifier.value ?? '').toLowerCase(),
                    );
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
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
                              padding: EdgeInsets.only(bottom: 20.h),
                              shrinkWrap: true,
                              itemCount: widget.items.length,
                              itemBuilder: (BuildContext context, int index) {
                                final isSelected = selectedIndex == index;
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      selectedIndex = index;
                                      selectedValueNotifier.value = widget.items[index];
                                      widget.onSelected(widget.items[index]);
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
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
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 150.w,
                                              child: CustomText(
                                                text: widget.items[index],
                                                fontWeight: FontWeight.w500,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                size: 18.sp,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Theme.of(context).colorScheme.textClrChange,
                                              ),
                                            ),
                                            if (isSelected)
                                              const HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              ),
                                          ],
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
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              height: 40.h,
              width: double.infinity,
              margin:  EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color:  Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: selectedValueNotifier,
                      builder: (context, value, _) {
                        final displayText = (value?.isEmpty ?? true)
                            ? AppLocalizations.of(context)!.pleaseselect
                            : value![0].toUpperCase() + value.substring(1);
                        return CustomText(
                          text:displayText,
                          fontWeight: FontWeight.w500,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}






