import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DismissibleCard extends StatelessWidget {
  final String title;
  final Widget dismissWidget;
  final DismissDirection? direction;
  final Function(DismissDirection)
      onDismissed; // Action to perform when dismissed

  final Future<bool?> Function(DismissDirection)
      confirmDismiss; // Confirmation before dismiss

  const DismissibleCard({
    super.key,
    required this.title,
    required this.confirmDismiss,
    required this.dismissWidget,
    this.direction,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {

    final DismissDirection swipeDirection = direction ??
        DismissDirection.horizontal; // Default to horizontal if null

    return Dismissible(
      dismissThresholds: const{
        DismissDirection.endToStart:0.9,
        DismissDirection.startToEnd:0.9
      },
      key: ValueKey(title),
      direction: direction ?? swipeDirection,
      resizeDuration: Duration.zero,
      onDismissed: (direction) {
        onDismissed(direction);
      },
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          color: Colors.blue.withValues(alpha: 0.5),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Icon(
              Icons.edit,
              color: AppColors.pureWhiteColor,
              size: 36.sp,
            ),
          ),
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          color: AppColors.red.withValues(alpha: 0.5),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Icon(
              Icons.delete,
              color: AppColors.pureWhiteColor,
              size: 36.sp,
            ),
          ),
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        return await confirmDismiss(direction); // Perform confirmation logic
      },
      child: dismissWidget,
    );
  }
}
