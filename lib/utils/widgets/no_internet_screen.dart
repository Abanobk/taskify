import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/app_images.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

import '../../config/colors.dart';
import '../../src/generated/i18n/app_localizations.dart';
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: noInternetBody(),
    );
  }
  Widget noInternetBody() {
    return SizedBox(
      // Use Expanded or SizedBox to ensure proper height if needed
      height: MediaQuery.of(context).size.height, // Ensures full height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.noInternetImage),
                fit: BoxFit.contain, // Use BoxFit to handle image scaling
              ),
            ),
          ),
          SizedBox(height: 20.h), // Add space between image and text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CustomText(
                  text:  AppLocalizations.of(context)!.noInternetWhoops,
                  size: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  textAlign: TextAlign.center, // Ensure text is centered
                ),
              ),
              SizedBox(height: 10.h),
              CustomText(
                text: AppLocalizations.of(context)!.nointernet,
                size: 15.sp,
                color: AppColors.greyColor,

                textAlign: TextAlign.center, // Ensure text is centered
              ),
            // Add space between texts

            ],
          ),
        ],
      ),
    );
  }

}
