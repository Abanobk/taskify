import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/app_images.dart';



class NoPermission extends StatelessWidget {
  const NoPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            height: 400.h,
            width: 350.w,
            decoration:  BoxDecoration(
              // color: Colors.red,
                image: DecorationImage(
                    image: AssetImage(
                        AppImages.noPermissionImage),
                    fit: BoxFit.cover)),
          ),
          // CustomText(
          //   text:AppLocalizations.of(context)!.noPermission,
          //   size: 20.sp,
          //   color: Theme.of(context)
          //       .colorScheme
          //       .textClrChange,
          // )
        ],
      ),
    );
  }
}

