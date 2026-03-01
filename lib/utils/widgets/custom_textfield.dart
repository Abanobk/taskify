import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../screens/style/design_config.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final Color borderColor;
  final TextInputType keyBoardType;
  final Widget? suffixIcon;
  final String? initial;
   final bool obscureText ;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.keyBoardType,
    this.suffixIcon,
    required this.controller,
    required this.onChanged,
    this.validator,
    this.initial,
     this.obscureText =false,
    this.borderColor = Colors.red, // Default to red if not specified
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
       obscureText: obscureText ,
      style: TextStyle(color:AppColors.primary,  fontSize: textSize(context, 18),),
      initialValue:initial,
      validator: validator,
      onChanged: onChanged,
      controller: controller,
      keyboardType: keyBoardType,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle:  TextStyle(
          fontSize: textSize(context,18),
          // height: 26.59 / 18,
          fontFamily: "Source Sans Pro",
          fontWeight: FontWeight.w600,
          color: Colors.grey, // Adjust as needed
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: borderColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
