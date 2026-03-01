import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

import '../../../bloc/setting/settings_bloc.dart';

class CustomTextFields extends StatefulWidget {
  final String? subtitle;
  final String title; // Required title text
  final String hinttext; // Required title text
  final bool isRequired; // Flag indicating if the field is required
  final bool? isPassword; // Flag indicating if the field is required
  final TextEditingController
      controller; // Text editing controller for the field
  final TextInputType
      keyboardType; // Type of keyboard to show (e.g., TextInputType.text)// Validation function for the field
  final void Function(String?) onSaved; // Callback when the field is saved
  final void Function(String?)? onchange; // Callback when the field is saved
  final void Function(String)?
      onFieldSubmitted; // Callback when the field is submitted
  final bool
      isLightTheme; // Flag for light/dark theme// Flag for light/dark theme
  final bool? readonly; // Flag for light/dark theme
  final bool? currency; // Flag for light/dark theme
  final double height;
  final bool isDetails;
  final List<TextInputFormatter>? inputFormatters; // Flag for light/dark theme

  CustomTextFields({
    super.key,
    required this.title,
    this.subtitle,
    this.currency,
    this.isPassword = false,
    this.isDetails = false,
    this.readonly = false,
    required this.hinttext,
    this.isRequired = false,
    this.inputFormatters,
    double? height, // Accept a nullable height
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.onSaved,
    this.onchange,
    this.onFieldSubmitted,
    required this.isLightTheme,
  }) : height = height ?? 40.h; // Assign default value in the initializer

  @override
  State<CustomTextFields> createState() => _CustomTextFieldsState();
}

class _CustomTextFieldsState extends State<CustomTextFields> {
  bool _showPassword = true;
  String? currency;
  @override
  Widget build(BuildContext context) {
    currency = context.read<SettingsBloc>().currencySymbol;
print("frtyhujk ${widget.currency == true }");
print("frtyhujk ${currency != null}");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                CustomText(
                  text: widget.title,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 16.sp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w700,
                ),
                if (widget.currency == true && currency != null)
                  Text(
                    " ($currency) ",
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Theme.of(context).colorScheme.textClrChange,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (widget.isRequired)
                  const Text(
                    " *",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (widget.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: CustomText(
                      text: widget.subtitle!,
                      color: AppColors.greyColor,
                      size: 12.sp,
                      fontWeight: FontWeight.w500,
                      maxLines: null,
                    ),
                  ),
              ],
            )),
        SizedBox(
          height: 5.h,
        ),
        widget.height > 40.h
            ? IntrinsicHeight(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  width: double.infinity,
                  margin:  EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: widget.isDetails
                        ? Theme.of(context).colorScheme.detailsOverlay
                        : Colors.transparent,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    obscureText:
                        widget.isPassword == true ? _showPassword : false,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,

                    maxLines: null, // Allow multiple lines based on content
                    minLines: 1, // Start with 1 line
                    onSaved: widget.onSaved,
                    onChanged: widget.onchange,
                    inputFormatters: widget.inputFormatters,
                    readOnly: widget.readonly == true,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.hinttext,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.greyForgetColor,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                   // More padding for multiline, less for single-line

                        horizontal: 10.w,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
            : Container(
                height: 40.h, // Default to 40.h if height is not passed
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: widget.isDetails
                      ? Theme.of(context).colorScheme.detailsOverlay
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  // ✅ Ensures the TextField is centered within the Container
                  child: TextFormField(
                    obscureText:
                        widget.isPassword == true ? _showPassword : false,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical
                        .center, // ✅ Ensures vertical alignment
                    onSaved: widget.onSaved,
                    onChanged: widget.onchange,
                    inputFormatters: widget.inputFormatters,
                    readOnly: widget.readonly == true,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIcon: widget.isPassword == true
                          ? InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 10.w),
                                child: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withValues(alpha: 0.4),
                                  size: 22.sp,
                                ),
                              ),
                            )
                          : null,
                      hintText: widget.hinttext,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.greyForgetColor,
                      ),
                      contentPadding: widget.isPassword == true
                          ? EdgeInsets.symmetric(
                            // ✅ Ensures balanced padding
                              horizontal: 10.w,
                            )
                          : EdgeInsets.symmetric(
                             // ✅ Ensures balanced padding
                              horizontal: 10.w,
                            ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
      ],
    );
  }
}
