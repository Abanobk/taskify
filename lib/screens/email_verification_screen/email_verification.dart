import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../src/generated/i18n/app_localizations.dart';
import '../../routes/routes.dart';
import '../widgets/custom_button.dart';



class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Padding(
        padding:  EdgeInsets.all(18.w),
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(textAlign :TextAlign.center,text:  AppLocalizations.of(context)!.emailVerification,fontWeight: FontWeight.w800,color: AppColors.primary,),
           SizedBox(height: 20.h,),
            InkWell(
              onTap: (){
                router.go('/login');
              },
              child: CustomButton(
                isLoading: false,
                text: AppLocalizations.of(context)!.login,
                textcolor: AppColors.pureWhiteColor,
              ),
            ),
          ],
        )),
      ),
    );
  }
}
