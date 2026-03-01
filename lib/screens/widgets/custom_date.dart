import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:taskify/config/colors.dart';

import '../../utils/widgets/custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class DatePickerWidget extends StatelessWidget {
  final TextEditingController dateController;
  final String title;
  final bool? star;
  final bool? width;
  final bool isDetails;
  final String? titlestartend;
  final double? size;
  final void Function()? onTap;
  final bool isLightTheme;

  const DatePickerWidget({
    super.key,
    required this.dateController,
    this.size,
    this.width,
    this.isDetails=false,
    this.star,
    required this.title,
    this.titlestartend,
    this.onTap,
    required this.isLightTheme,
  });



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
        if (title != "")
                  CustomText(
              text: title,
              color: Theme.of(context).colorScheme.textClrChange,
                    size: 16.sp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w700,
            ),
            // SizedBox(width: 5.h),

            star == true
                ? CustomText(
              text: " *",
              color: Colors.red,
              size: 15,
              fontWeight: FontWeight.w400,
            )
                : SizedBox(),
            SizedBox(width: 2.h),
            if(titlestartend != null && titlestartend!="")
                 CustomText(
              text: titlestartend!,
              color: AppColors.greyColor,
              size: 12.sp,
              fontWeight: FontWeight.w700,
            )

          ],
        ),
        SizedBox(height: 5.h),
        Container(
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
            color:  isDetails ?                 Theme.of(context).colorScheme.detailsOverlay:Colors.transparent
          ),
          child: Center( // ✅ Ensures vertical centering
            child: TextFormField(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: size ?? 14.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              readOnly: true,
              onTap: onTap,
              controller: dateController,
              textAlignVertical: TextAlignVertical.center, // ✅ Centers text vertically
              textAlign: TextAlign.start, // ✅ Keeps text aligned to the left
              decoration: InputDecoration(

                  hintText: (dateController == "" || dateController.text.isEmpty || dateController.text.trim() == "null")
                      ? AppLocalizations.of(context)!.selectdate
                      : dateController.text,


                hintStyle: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                isCollapsed: true, // ✅ Removes extra padding
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w), // ✅ Horizontal padding
                border: InputBorder.none,
              ),
            ),
          ),
        )


      ],
    );
  }
}



class DateRangePickerWidget extends StatelessWidget {
  final TextEditingController dateController;
  final String title;
  final bool? star;
  final bool? width;
  final bool isDetails;
  final String? titlestartend;
  final double? size;
  final void Function(DateTime?, DateTime?)?
      onTap; // Callback to pass selected dates
  final bool isLightTheme;
  final FocusNode? focusNode;
  final DateTime? selectedDateStarts; // Add initial start date
  final DateTime? selectedDateEnds; // Add initial end date

  const DateRangePickerWidget({
    super.key,
    required this.dateController,
    this.size,
    this.width,
    this.isDetails = false,
    this.star,
    required this.title,
    this.titlestartend,
    this.onTap,
    required this.isLightTheme,
    this.focusNode,
    this.selectedDateStarts, // Pass initial start date
    this.selectedDateEnds, // Pass initial end date
  });

  @override
  Widget build(BuildContext context) {
    final FocusNode _localFocusNode = focusNode ?? FocusNode();

    // Date formatting function (moved from parent)
    String dateFormatConfirmed(DateTime date, BuildContext context) {
      // Example: Format as "MM/dd/yyyy"
      return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
    }



    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            if (title != "")
              CustomText(
                text: title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w700,
              ),
            star == true
                ? CustomText(
                    text: " *",
                    color: Colors.red,
                    size: 15,
                    fontWeight: FontWeight.w400,
                  )
                : SizedBox(),
            SizedBox(width: 2.h),
            if (titlestartend != null && titlestartend != "")
              Container(
                width: 120,
                child: CustomText(
                  text: titlestartend!,
                  color: AppColors.greyColor,
                  size: 12.sp,
                  maxLines: 2,
                  softwrap: true,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w700,
                ),
              )
          ],
        ),
        SizedBox(height: 5.h),
        Container(
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
            color: isDetails
                ? Theme.of(context).colorScheme.detailsOverlay
                : Colors.transparent,
          ),
          child: Center(
            child: TextFormField(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: size ?? 14.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              readOnly: true,
              focusNode: _localFocusNode,
              enableInteractiveSelection: false, // Prevent context menu
              onTap: onTap != null? () async {
                _localFocusNode.unfocus(); // Unfocus to prevent context menu
                // Call showOmniDateTimeRangePicker with provided initial dates
                final List<DateTime>? picked =
                    await showOmniDateTimeRangePicker(
                  context: context,
                  type: OmniDateTimePickerType.date,
                  is24HourMode: false,
                  startInitialDate: selectedDateStarts ?? DateTime.now(),
                  endInitialDate:
                      selectedDateEnds ?? DateTime.now().add(Duration(days: 1)),
                  startFirstDate: DateTime(2000, 1, 1),
                  startLastDate: DateTime(2100, 12, 31),
                  endFirstDate: DateTime(2000, 1, 1),
                  endLastDate: DateTime(2100, 12, 31),
                  constraints: BoxConstraints(maxHeight: 500),
                );

                if (picked != null && picked.length == 2) {
                  DateTime start = picked[0];
                  DateTime end = picked[1];

                  // Ensure start date is not before current date
                  if (start.isBefore(DateTime.now())) {
                    start = DateTime.now();
                  }

                  // If end date is before start, adjust it
                  if (end.isBefore(start)) {
                    end = start;
                  }

                  // Update dateController with formatted date range
                  String startAndEndText =
                      '${dateFormatConfirmed(start, context)} - ${dateFormatConfirmed(end, context)}';
                  dateController.text = startAndEndText;

                  // Pass selected dates to parent via onTap callback
                  onTap?.call(start, end);
                } else {
                  // Pass null if no dates selected
                  onTap?.call(null, null);
                }
              }:(){},
              controller: dateController,
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: (dateController.text.isEmpty ||
                        dateController.text.trim() == "null")
                    ? AppLocalizations.of(context)!.selectdate
                    : dateController.text,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
