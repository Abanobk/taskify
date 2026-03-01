import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';

import '../../utils/widgets/my_theme.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class CustomSearchField extends StatelessWidget {
  final bool isLightTheme;
  final String? hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool enableVoiceSearch;
  final bool? isNoti;
  final Function? onVoiceSearchStart;
  final VoidCallback? onTap;  // Equivalent to `void Function()?`


  final Function? onVoiceSearchStop;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;

  const CustomSearchField({super.key,
    required this.isLightTheme,
    this.isNoti,
    this.onTap,
    this.hintText,
    required this.controller,
    required this.onChanged,
    this.enableVoiceSearch = true,
    this.onVoiceSearchStart,
    this.onVoiceSearchStop,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: double.infinity,
      margin: isNoti == true?EdgeInsets.symmetric(horizontal: 0.w) :EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.containerDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          isLightTheme
              ? MyThemes.lightThemeShadow
              : MyThemes.darkThemeShadow,
        ],
      ),
      child: TextFormField(
        onTap: onTap,
        autofocus: autofocus,
        controller: controller,
        cursorColor: AppColors.greyForgetColor,
        cursorWidth: 1.w,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: prefixIcon ??
              HeroIcon(
                HeroIcons.magnifyingGlass,
                style: HeroIconStyle.outline,
                size: 20.sp,
                color: Theme.of(context).colorScheme.textFieldColor,
              ),
          suffixIcon: suffixIcon,


          hintText: hintText ??AppLocalizations.of(context)!.searchhere,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: AppColors.greyForgetColor,
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.textFieldColor,
            fontSize: 13,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: (40.h - 20.sp) / 2,
            horizontal: 10.w,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
