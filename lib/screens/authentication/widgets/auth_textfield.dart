import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/colors.dart';

class AuthCustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool autofocus;
  final String? Function(String)? onFieldSubmitted;
  final List<String>? autofillHints;

  const AuthCustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.obscureText = false,
    this.suffixIcon,
    this.autofocus = false,
    this.onFieldSubmitted,
    this.autofillHints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      width: 370.w,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofocus: autofocus,
        style: TextStyle(fontSize: 14.sp),
        cursorColor: AppColors.greyForgetColor,
        cursorWidth: 1.w,
        autofillHints: autofillHints,
        onSaved: onSaved,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.textFieldColor,
            fontSize: 13.sp,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          border: const OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}


