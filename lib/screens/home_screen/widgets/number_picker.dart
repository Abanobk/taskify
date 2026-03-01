import 'package:awesome_number_picker/awesome_number_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';

import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';


class CustomNumberPickerDialog extends StatefulWidget {
  final TextEditingController dayController;
  final ValueNotifier<int> currentValue;
  final bool isLightTheme;
  final int minValue;
  final int maxValue;
  final Function(int) onSubmit;
  final String? title;
  final String? hint;

  const CustomNumberPickerDialog({
    super.key,
    required this.dayController,
    required this.currentValue,
    required this.isLightTheme,
    required this.onSubmit,
    this.minValue = 1,
    this.maxValue = 366,
    this.title,
    this.hint,
  });

  static Future<void> show({
    required BuildContext context,
    required TextEditingController dayController,
    required ValueNotifier<int> currentValue,
    required bool isLightTheme,
    required Function(int) onSubmit,
    int minValue = 1,
    int maxValue = 366,
    String? title,
    String? hint,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomNumberPickerDialog(
          dayController: dayController,
          currentValue: currentValue,
          isLightTheme: isLightTheme,
          onSubmit: onSubmit,
          minValue: minValue,
          maxValue: maxValue,
          title: title,
          hint: hint,
        );
      },
    );
  }

  @override
  State<CustomNumberPickerDialog> createState() => _CustomNumberPickerDialogState();
}

class _CustomNumberPickerDialogState extends State<CustomNumberPickerDialog> {
  late TextEditingController textController;
  late int tempValue;

  @override
  void initState() {
    super.initState();
    tempValue = widget.currentValue.value;
    textController = TextEditingController(text: widget.currentValue.value.toString());
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      title: Center(
        child: CustomText(
          text: widget.title ?? AppLocalizations.of(context)!.selectDays,
          color: Theme.of(context).colorScheme.textClrChange,
          size: 20.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFields(
            keyboardType: TextInputType.number,
            title: "",
            hinttext: widget.hint ?? AppLocalizations.of(context)!.selectDays,
            controller: textController,
            isLightTheme: widget.isLightTheme,
            onSaved: (String? val) {},
            onchange: (value) {
              if (value != null && value.isNotEmpty) {
                final newValue = int.tryParse(value);
                if (newValue != null && newValue >= widget.minValue && newValue <= widget.maxValue) {
                  setState(() {
                    widget.currentValue.value = newValue;
                    widget.dayController.text = newValue.toString();
                  });
                }
              }
            },
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 230.h,
            child: IntegerNumberPicker(
              key: ValueKey(widget.currentValue.value),
              size: 50.sp,
              initialValue: widget.currentValue.value,
              minValue: widget.minValue,
              maxValue: widget.maxValue,
              pickedItemTextStyle: TextStyle(
                color: AppColors.pureWhiteColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              pickedItemDecoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              onChanged: (newValue) {
                setState(() {
                  widget.currentValue.value = newValue;
                  textController.text = newValue.toString();
                  widget.dayController.text = newValue.toString();
                });
              },
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  // widget.currentValue.value = tempValue;
                  // widget.dayController.text = tempValue.toString();
                  widget.onSubmit(7);
                  Navigator.pop(context);
                },
                child: CustomText(
                  text: AppLocalizations.of(context)!.cancel,
                  color: AppColors.greyColor,
                  size: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onSubmit(widget.currentValue.value);
                  Navigator.pop(context);
                },
                child: CustomText(
                  text: AppLocalizations.of(context)!.ok,
                  color: AppColors.primary,
                  size: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}