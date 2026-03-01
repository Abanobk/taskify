import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesShimmer extends StatelessWidget {
  final double? height;
  final bool? isNoti;
  final bool paddingNeeded;
  final int? count;
  const NotesShimmer(
      {super.key,
      this.height,
      this.count,
      this.isNoti,
      this.paddingNeeded = true});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Shimmer.fromColors(
      baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
      highlightColor:
          isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: 30.h),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count ?? 6,
          itemBuilder: (context, index) {
            return Padding(
                padding: isNoti == true
                    ? EdgeInsets.symmetric(
                        vertical: 10.h,
                      )
                    : EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: paddingNeeded == false ? 0 : 18.w),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.backGroundColor,
                      borderRadius: BorderRadius.circular(12)),
                  height: height ?? 200.h,
                ));
          }),
    );
  }
}
class SettingUpdateShimmer extends StatelessWidget {
  final double? height;
  final bool? isNoti;
  final bool paddingNeeded;
  final int? count;
  const SettingUpdateShimmer(
      {super.key,
      this.height,
      this.count,
      this.isNoti,
      this.paddingNeeded = true});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Shimmer.fromColors(
      baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
      highlightColor:
          isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.backGroundColor,
                  borderRadius: BorderRadius.circular(12)),
              height: height ?? 40.h,
            ),

            SizedBox(
              height: 20.w,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.backGroundColor,
                  borderRadius: BorderRadius.circular(12)),
              height: height ?? 40.h,
            ),
            SizedBox(
              height: 20.w,
            ),

            ListView.builder(
                padding: EdgeInsets.only(bottom: 30.h),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: count ?? 12,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:  EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.backGroundColor,
                          borderRadius: BorderRadius.circular(12)),
                      height: height ?? 100.h,
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class ProjectShimmer extends StatefulWidget {
  const ProjectShimmer({super.key});

  @override
  State<ProjectShimmer> createState() => _ProjectShimmerState();
}

class _ProjectShimmerState extends State<ProjectShimmer> {
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Shimmer.fromColors(
        baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
        highlightColor:
            isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: 30.h, top: 20.h),
          shrinkWrap: true,
          itemCount: 10, // Add 1 for the loading indicator
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: SizedBox(
                    height: 250.h,
                    width: 200.w,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.backGroundColor,
                          borderRadius: BorderRadius.circular(12)),
                      height: 100.h,
                    )));
          },
        ));
  }
}

class GridShimmer extends StatelessWidget {
  final int? count;
  const GridShimmer({super.key, this.count = 10});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return Shimmer.fromColors(
        baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
        highlightColor:
            isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.h),
            // height: 500,
            width: double.infinity,
            child: GridView.builder(
              padding: EdgeInsets.only(top: 20.h),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 1.0, // Horizontal spacing between items
                mainAxisSpacing: 1.0, // Vertical spacing between items
              ),
              shrinkWrap: true,
              itemCount: count, // Number of items in the grid
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.all(10.h),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.backGroundColor,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            )));
  }
}

class DashBoardStatsShimmer extends StatelessWidget {
  const DashBoardStatsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return Shimmer.fromColors(
        baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
        highlightColor:
            isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
        child: Column(
          children: [
            Column(
              children: [
                MasonryGridView.builder(
                  padding: EdgeInsets.only(bottom: 10.h),
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                  ),
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  itemCount: 4, // Total number of items
                  shrinkWrap: true, // Prevents unnecessary scrolling issues
                  physics:
                      const NeverScrollableScrollPhysics(), // Disables independent scrolling
                  itemBuilder: (context, index) {
                    index = index +
                        1;
                    return Shimmer.fromColors(
                        baseColor: isLightTheme == true
                            ? Colors.grey[100]!
                            : Colors.grey[600]!,
                        highlightColor: isLightTheme == false
                            ? Colors.grey[800]!
                            : Colors.grey[300]!,
                        child: Container(
                          height: index.isOdd ? 200.h : 120.h,
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.backGroundColor,
                              borderRadius: BorderRadius.circular(10)),
                        ));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 200.w,
                      // width: double.infinity, // Let MasonryGrid manage the width
                      height: 120.h,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.backGroundColor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    Container(
                      width: 130.w,
                      // width: double.infinity, // Let MasonryGrid manage the width
                      height: 120.h,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.backGroundColor,
                          borderRadius: BorderRadius.circular(10)),
                    )
                  ],
                )
              ],
            ),

          ],
        ));
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Shimmer.fromColors(
        baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
        highlightColor:
            isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
        child: Container(
          height: 563.h,
          width: 350.w,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.backGroundColor,
              borderRadius: BorderRadius.circular(12)),
        ));
  }
}

Widget shimmerDetails(isLightTheme, context, height) {
  return Shimmer.fromColors(
      baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
      highlightColor:
          isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
      child: Container(
        height: height,
        width: 400.w,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.backGroundColor,
            borderRadius: BorderRadius.circular(17.4)),
      ));
}

Widget shimmerAvatarDetails(
  isLightTheme,
  context,
) {
  return Shimmer.fromColors(
      baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
      highlightColor:
          isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 45.r,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.greyColor,
                  width: 1.5.w,
                ),
              ),
            ),
          ),
        ],
      ));
}
class HomeUpcomingShimmer extends StatelessWidget {
  final double? height;
  final bool? isNoti;
  final bool paddingNeeded;
  final int? count;
  const HomeUpcomingShimmer(
      {super.key,
        this.height,
        this.count,
        this.isNoti,
        this.paddingNeeded = true});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Shimmer.fromColors(
      baseColor: isLightTheme == true ? Colors.grey[100]! : Colors.grey[600]!,
      highlightColor:
      isLightTheme == false ? Colors.grey[800]! : Colors.grey[300]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(bottom: 30.h),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count ?? 6,
          itemBuilder: (context, index) {
            return Padding(
                padding: isNoti == true
                    ? EdgeInsets.symmetric(
                  vertical: 0.h,
                )
                    : EdgeInsets.only(
                    top: 10.h,bottom: 0,
                    left: paddingNeeded == false ? 0 : 18.w),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.backGroundColor,
                      borderRadius: BorderRadius.circular(12)),
                  width: 250.w,
                ));
          }),
    );
  }
}