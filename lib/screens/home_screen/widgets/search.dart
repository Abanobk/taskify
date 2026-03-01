import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/colors.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class Search extends StatefulWidget {
  final TextEditingController
  controller;
  final void Function(String?)? onchange;
  const Search({super.key,required this.controller,this.onchange});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.red,
      height: 30.h,
      width: double.infinity,
      child: TextField(
        cursorColor: AppColors.greyForgetColor,
        cursorWidth: 1,
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: (35.h - 20.sp) / 2,
            horizontal: 10.w,
          ),
          hintText:
          AppLocalizations.of(context)!.search,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors
                  .greyForgetColor, // Set your desired color here
              width:
              1.0, // Set the border width if needed
            ),
            borderRadius: BorderRadius.circular(
                10.0), // Optional: adjust the border radius
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: AppColors
                  .purple, // Border color when TextField is focused
              width: 1.0,
            ),
          ),
        ),
        onChanged: (value) {

        },
      ),
    );
  }
}
