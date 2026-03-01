import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';


import '../../config/app_images.dart';
import '../../src/generated/i18n/app_localizations.dart';
class SearchPopUp extends StatelessWidget {
  const SearchPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    print("rtyguhjkl;");
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      title: Padding(
        padding:  EdgeInsets.only(bottom: 25.h),
        child: Center(child: Text(AppLocalizations.of(context)!.speak)),
      ),
      content: SingleChildScrollView(
        child: AvatarGlow(
          // endRadius: 60.0,
          child: Material(     // Replace this child with your own
            elevation: 8.0,
            shape: CircleBorder(),
            child: CircleAvatar(
              backgroundColor: Colors.grey[100],
              radius: 30.0,
              child: Image.asset(
                AppImages.speakerPeechToTextImage,
                height: 50,
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding:  EdgeInsets.only(top: 8.h),
          child: Center(
            child: TextButton(
              child: CustomText(text: AppLocalizations.of(context)!.trytosaysomething,color: Theme.of(context).colorScheme.textClrChange,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ],
    );
  }
}
