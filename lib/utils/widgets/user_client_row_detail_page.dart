import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/colors.dart';
import 'custom_text.dart';

class UserClientRowDetailPage extends StatefulWidget {
  final List<dynamic> list;
  final String title;
  const UserClientRowDetailPage(
      {super.key, required this.list, required this.title});

  @override
  State<UserClientRowDetailPage> createState() =>
      _UserClientRowDetailPageState();
}

class _UserClientRowDetailPageState extends State<UserClientRowDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: widget.title,
            size: 18.sp,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.textClrChange,
          ),
          SizedBox(
            height: 15.h,
          ),
          SizedBox(
            // width: 80.w,
            height: 35.h,
            // color: Colors.yellow,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.start,   // Client should be aligned at the end
              children: [
                for (int i = 0; i < widget.list.length ; i++)
                  if (i < 10)
                    Align(
                      widthFactor: 0.75.w,
                      child: CircleAvatar(
                        radius: 15.r,
                        backgroundColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.greyColor,
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,

                            radius: 15.r,
                            backgroundImage: NetworkImage(
                                widget.list[i].photo!),
                          ),
                        ),
                      ),
                    ),
                // Add the custom text if there are more than 2 items in the list (for LTR)
                if (widget.list.length > 10 )
                  Align(
                    widthFactor: 0.75.w,
                    child: Container(
                      alignment: Alignment.center,
                      height: 30.r,
                      width: 30.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.greyColor,
                      ),
                      child: CustomText(
                        text: '+${widget.list.length - 10}',
                        color: AppColors.pureWhiteColor,
                      ),
                    ),
                  ),

                // Loop through the list and display the first two avatars


                // Add the custom text if there are more than 2 items in the list (for RTL)

              ],
            ),
          )
        ]);
  }
}
