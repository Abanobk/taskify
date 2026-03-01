import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/toast_widget.dart';


class CustomFieldCheckbox extends StatefulWidget {
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final double size;
  final Color activeBgColor;
  final Color? inactiveBgColor;
  final String? label;
  final bool? required;
  final bool isDetails;
  final String? fieldId;
  final EdgeInsets padding;

  const CustomFieldCheckbox({
    Key? key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.required,
    this.size = 20.0,
    this.isDetails = false,
    this.activeBgColor = AppColors.primary,
    this.inactiveBgColor,
    this.label,
    this.fieldId,
    this.padding = const EdgeInsets.only(bottom: 8.0),
  }) : super(key: key);

  @override
  State<CustomFieldCheckbox> createState() => _CustomFieldCheckboxState();
}

class _CustomFieldCheckboxState extends State<CustomFieldCheckbox> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    // Initialize selected list with provided selectedValues
    selected = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              CustomText(
                text: widget.label!,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(width: 5.w),
              if (widget.required == true)
                CustomText(
                  text: "*",
                  color: AppColors.red,
                  size: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
        Stack(
          children: [
            ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final option = widget.options[index];
              final isChecked = selected.contains(option);
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selected.add(option);
                        } else {
                          selected.remove(option);
                        }
                        widget.onChanged(selected);
                        print('Checkbox updated: $selected');
                      });
                    },
                    activeColor: widget.activeBgColor,
                    side: BorderSide(
                      color: isChecked
                          ? widget.activeBgColor
                          : Theme.of(context).colorScheme.whitepurpleChange,
                    ),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return widget.activeBgColor;
                      }
                      return Theme.of(context).colorScheme.containerDark;
                    }),
                  ),
                  SizedBox(width: 2.w),
                  CustomText(
                    text: option,
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              );
            },
          ),if (widget.isDetails)
            Positioned.fill(
              child: InkWell(
                onTap: (){
                  print("tyuhjnkm,l");
                  flutterToastCustom(
                    msg: AppLocalizations.of(context)!.createdsuccessfully,
                    color: AppColors.primary,
                  );
                },
                child: Container(

                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.detailsOverlay,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),],
        ),
      ],
    );
  }
}