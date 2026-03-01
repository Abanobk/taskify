import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';
import '../../../config/colors.dart';
import '../../../data/model/user_model.dart';
import '../../../utils/widgets/custom_text.dart';


class ListOfUser extends StatefulWidget {
  final bool isSelected;
  final User? user;
  final AllClientModel? client;

  final bool isUser ;
  const ListOfUser({super.key,this.isUser = true, required this.isSelected,  this.user,this.client});

  @override
  State<ListOfUser> createState() => _ListOfUserState();
}

class _ListOfUserState extends State<ListOfUser> {
  @override
  Widget build(BuildContext context) {
    // print("dfxfv ${widget.client!.firstName!}");
    return widget.isUser == true ?
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isSelected ? AppColors.purpleShade : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isSelected ? AppColors.purple : Colors.transparent,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w,), // Adjust padding
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            backgroundImage:
            NetworkImage(widget.user?.profile ?? ""),
          ),
          SizedBox(width: 12.w), // Add spacing between avatar and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CustomText(
                        text: widget.user?.firstName ?? "",
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        size: 18.sp,
                        color: widget.isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.textClrChange,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: CustomText(
                        text: widget.user?.lastName ?? "",
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        size: 18.sp,
                        color: widget.isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.textClrChange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: widget.user?.email ?? "",
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  size: 14.sp,
                  color: widget.isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ),
          if (widget.isSelected) // Show icon only if selected
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: const HeroIcon(
                HeroIcons.checkCircle,
                style: HeroIconStyle.solid,
                color: AppColors.purple,
              ),
            ),
        ],
      ),
    ):
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isSelected ? AppColors.purpleShade : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isSelected ? AppColors.purple : Colors.transparent,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w,), // Adjust padding
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            backgroundImage:
            NetworkImage(widget.client!.profile! ),
          ),
          SizedBox(width: 12.w), // Add spacing between avatar and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CustomText(
                        text: widget.client!.firstName ?? "",
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        size: 18.sp,
                        color: widget.isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.textClrChange,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: CustomText(
                        text: widget.client!.lastName ?? "",
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        size: 18.sp,
                        color: widget.isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.textClrChange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: widget.client!.email ?? "",
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  size: 14.sp,
                  color: widget.isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ),
          if (widget.isSelected) // Show icon only if selected
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child:  HeroIcon(
                HeroIcons.checkCircle,
                style: HeroIconStyle.solid,
                color: AppColors.purple,
              ),
            ),
        ],
      ),
    );
  }
}
