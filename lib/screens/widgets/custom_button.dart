import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/colors.dart';
import '../../utils/widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? height;
  final double? width;
  final Color? darkContainerColor;
  final Color? textcolor;
  final bool? isLoading;
  final bool? isLogin;
  final bool? isBorder;
  final Color? isBackgroundColor;
  final Color? border;
  final GestureTapCallback? onPress;
   const CustomButton({super.key,required this.isLoading,this.isLogin,this.border,this.isBorder,this.isBackgroundColor,required this.text,this.height,this.width,this.darkContainerColor,this.textcolor,this.onPress});

  @override
  Widget build(BuildContext context) {

    return  isBorder == true  ? InkWell(
      highlightColor: Colors.transparent, // No highlight on tap
      splashColor: Colors.transparent,
       onTap: onPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color:AppColors.primary,width: 2),
            color:   AppColors.primary,
            // boxShadow: const [
            //   BoxShadow(
            //     color: Color(0x33959DA5), // #959DA533 in ARGB format
            //     offset: Offset(0, 8), // x and y offsets
            //     blurRadius: 24,
            //   ),
            // ],
            ),
        child:Center(
            child: CustomText(
              text: text,
              size: 16.sp,
              fontWeight: FontWeight.w600,
                color: AppColors.pureWhiteColor
            )),
      ),
    ):InkWell(
      highlightColor: Colors.transparent, // No highlight on tap
      splashColor: Colors.transparent,
      onTap: onPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textcolor!,width: 2),
          color: Colors.transparent,
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color(0x33959DA5), // #959DA533 in ARGB format
          //     offset: Offset(0, 8), // x and y offsets
          //     blurRadius: 24,
          //   ),
          // ],
        ),
        child:Center(
            child: CustomText(
                text: text,
                size: 16.sp,
                fontWeight: FontWeight.w600,
                color: textcolor!
            )),
      ),
    );
  }
}
