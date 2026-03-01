import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/colors.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_button.dart';


class CustomNumberPickerDialog extends StatelessWidget {
  final TextEditingController dayController;
  final ValueNotifier<int> currentValue;
  final bool isLightTheme;
  final Function(int) onSubmit;

  const CustomNumberPickerDialog({
    Key? key,
    required this.dayController,
    required this.currentValue,
    required this.isLightTheme,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.selectDays,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                backgroundColor: Theme.of(context).colorScheme.textClrChange,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: dayController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.selectDays,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  onTap: () => Navigator.pop(context),
                  text: AppLocalizations.of(context)!.cancel,
                  backgroundColor: Theme.of(context).colorScheme.backGroundColor,
                  textColor: Theme.of(context).colorScheme.textClrChange,

                ),
                SizedBox(width: 8.w),
                CustomButton(
                  onTap: () {
                    int? value = int.tryParse(dayController.text);
                    if (value != null && value >= 1 && value <= 366) {
                      onSubmit(value);
                      Navigator.pop(context);
                    }
                  },
                  text: AppLocalizations.of(context)!.ok,
                  backgroundColor: AppColors.primary,
                  textColor:        Theme.of(context).colorScheme.textClrChange,

    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 