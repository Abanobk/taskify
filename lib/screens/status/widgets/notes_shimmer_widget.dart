import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/colors.dart';
class NotesShimmer extends StatelessWidget {
  final double? height ;
  final bool? title ;
  const NotesShimmer({super.key,this.height,this.title});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Shimmer.fromColors(
      baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
      highlightColor:
      isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,

      child:ListView.builder(
          padding: EdgeInsets.only(bottom: 30.h),
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 18.w),
                child: Column(
                  children: [
                 title==true ? Container(
                      decoration: BoxDecoration(
                          color: AppColors.pureWhiteColor,
                          borderRadius: BorderRadius.circular(12)),
                      height:20.h,

                    ):SizedBox(),
                    SizedBox(height: 10.h,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.pureWhiteColor,
                          borderRadius: BorderRadius.circular(12)),
                      height:height ??100.h,

                    ),
                  ],
                ));
          }),);
  }
}
