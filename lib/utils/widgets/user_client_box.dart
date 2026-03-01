import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

void userClientDialog({
  required BuildContext context,
  required String from,
  required String title,
  required List<dynamic> list,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
        title: Text(title),
        content: list.isNotEmpty?SizedBox(
          width: 300.w,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: NetworkImage(item.photo ?? ''),
                    ),
                    SizedBox(width: 10.w),
                    CustomText(
                      text: '${item.firstName} ${item.lastName}',
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              );
            },
          ),
        ):NoData(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
} 