import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/app_images.dart';
import '../../utils/widgets/custom_text.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class NoData extends StatelessWidget {
  final bool? isImage;
  final bool? isNoInterview;

  const NoData({super.key, this.isImage,this.isNoInterview});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isImage == true
              ? Container(
                  alignment: Alignment.center,
                  height: 300.h,
                  // width: 300.w,
                  decoration: BoxDecoration(
                      // color: Colors.red,
                      image: DecorationImage(
                          image: AssetImage(AppImages.noDataFoundImage),
                          fit: BoxFit.contain)),
                )
              : SizedBox.shrink(),
          isNoInterview == true ?Container(
            alignment: Alignment.center,
            height: 300.h,
            // width: 300.w,
            decoration: BoxDecoration(
              // color: Colors.red,
                image: DecorationImage(
                    image: AssetImage(AppImages.noDataFoundImage),
                    fit: BoxFit.contain)),
          )
              : SizedBox.shrink(),
          CustomText(
            text: AppLocalizations.of(context)!.nodata,
            size: isImage == true ? 20.sp : 15.sp,
            color: Theme.of(context).colorScheme.textClrChange,
          )
        ],
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onPress;
  const NoInternetScreen({super.key, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 300.h,
              width: 300.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // color: Colors.red,
                  image: DecorationImage(
                      image: AssetImage(AppImages.noInternetImage),
                      fit: BoxFit.cover)),
            ),
            InkWell(
              highlightColor: Colors.transparent, // No highlight on tap
              splashColor: Colors.transparent,
              onTap: () {
                onPress;
              },
              child: Container(
                alignment: Alignment.center,
                height: 70.h,
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary,
                ),
                child: CustomText(
                  text: AppLocalizations.of(context)!.tryAgain,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
