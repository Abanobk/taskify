import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isRequired;
  final bool isPassword;
  final bool showPassword;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onTogglePassword;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Function(String?)? onSaved;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isRequired = false,
    this.isPassword = false,
    this.showPassword = false,
    this.focusNode,
    this.onFieldSubmitted,
    this.onTogglePassword,
    this.inputFormatters,
    this.keyboardType,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      width: 370.w,
      child: TextFormField(
        style: TextStyle(fontSize: 14.sp),
        cursorColor: AppColors.greyForgetColor,
        cursorWidth: 1.w,
        controller: controller,
        obscureText: isPassword && showPassword,
        keyboardType: keyboardType ?? TextInputType.text,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        onSaved: onSaved,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          labelText: null,
          label: RichText(
            text: TextSpan(
              text: labelText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.textFieldColor,
                fontSize: 13.sp,
              ),
              children: isRequired ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13.sp,
                  ),
                ),
              ] : null,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.hintColor),
          ),
          suffixIcon: isPassword ? InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: onTogglePassword,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 10.0),
              child: Icon(
                !showPassword ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).colorScheme.fontColor.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
          ) : null,
        ),
      ),
    );
  }
} 