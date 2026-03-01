import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/app_colors.dart';

class ListOfUser extends StatelessWidget {
  final List<String> userNames;
  final List<int> userIds;
  final bool isLightTheme;
  final Function(List<String>, List<int>) onSelectionChanged;

  const ListOfUser({
    Key? key,
    required this.userNames,
    required this.userIds,
    required this.isLightTheme,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: userNames.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            userNames[index],
            style: TextStyle(
              color: isLightTheme ? AppColors.black : AppColors.white,
              fontSize: 14.sp,
            ),
          ),
          trailing: Checkbox(
            value: false, // TODO: Implement selection state
            onChanged: (bool? value) {
              // TODO: Implement selection handling
            },
          ),
        );
      },
    );
  }
} 