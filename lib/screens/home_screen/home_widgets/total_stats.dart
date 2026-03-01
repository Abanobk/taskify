import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../../bloc/dashboard_stats/dash_board_stats_state.dart';
import '../../../config/colors.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../routes/routes.dart';
import '../../dash_board/dashboard.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';

class TotalStats extends StatelessWidget {
  final bool isLightTheme;


  const TotalStats({
    super.key,
    required this.isLightTheme,

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
      child: BlocConsumer<DashBoardStatsBloc, DashBoardStatsState>(
        listener: (context, state) {
          if (state is DashBoardStatsSuccess) {
            // These values are now passed through constructor
          }
        },
        builder: (context, state) {
          if (state is DashBoardStatsLoading) {
            return const DashBoardStatsShimmer();
          } else if (state is DashBoardStatsSuccess) {
           var totalProjects = state.totalproject;
           var totalUser = state.totaluser;
            var totalTask = state.totaltask;
           var totalClient = state.totalclient;
          var   totalMeeting = state.totalmeeting;
           var totalTodos = state.totaltodos;
            final items = [
              {
                "title": AppLocalizations.of(context)!.totalMeeting,
                "total": totalMeeting.toString(),
                "icon": const HeroIcon(HeroIcons.users,
                    style: HeroIconStyle.outline, color: AppColors.redColor),
                "onPress": () =>
                    router.push('/meetings', extra: {"fromNoti": false}),
                "colors": AppColors.orangeYellowishColor,
                "width": 200.w
              },
              {
                "title": AppLocalizations.of(context)!.totalTodo,
                "total": totalTodos.toString(),
                "icon": const HeroIcon(HeroIcons.barsArrowUp,
                    style: HeroIconStyle.outline, color: AppColors.yellow),
                "onPress": () => router.push('/todos'),
                "colors": AppColors.yellow,
                "width": 130.w
              }
            ];
            return Column(
              children: [
                MasonryGridView.builder(
                  padding: EdgeInsets.only(bottom: 10.h),
                  gridDelegate:
                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final items = [
                      {
                        "title": AppLocalizations.of(context)!.totalProject,
                        "total": totalProjects.toString(),
                        "icon": const HeroIcon(HeroIcons.wallet,
                            style: HeroIconStyle.outline,
                            color: AppColors.primary),
                        "onPress": () => Navigator.of(context).push(
                            CupertinoPageRoute(
                                builder: (context) =>
                                    const DashBoard(initialIndex: 1))),
                        "colors": AppColors.primary,
                      },
                      {
                        "title": AppLocalizations.of(context)!.totalTask,
                        "total": totalTask.toString(),
                        "icon": const HeroIcon(HeroIcons.documentCheck,
                            style: HeroIconStyle.outline,
                            color: AppColors.blueLight),
                        "onPress": () => Navigator.of(context).push(
                            CupertinoPageRoute(
                                builder: (context) =>
                                    const DashBoard(initialIndex: 2))),
                        "colors": AppColors.blueLight,
                      },
                      {
                        "title": AppLocalizations.of(context)!.totalClient,
                        "total": totalClient.toString(),
                        "icon": const HeroIcon(HeroIcons.userGroup,
                            style: HeroIconStyle.outline,
                            color: AppColors.orangeYellowishColor),
                        "onPress": () => router.push("/client"),
                        "colors": AppColors.orangeYellowishColor,
                      },
                      {
                        "title": AppLocalizations.of(context)!.totalUser,
                        "total": totalUser.toString(),
                        "icon": const HeroIcon(HeroIcons.userCircle,
                            style: HeroIconStyle.outline,
                            color: AppColors.yellow),
                        "onPress": () => router.push('/user'),
                        "colors": AppColors.yellow,
                      },
                    ];

                    return _getTotal(
                      context: context,
                      index: index + 1,
                      title: items[index]["title"] as String,
                      isLightTheme: isLightTheme,
                      total: items[index]["total"] as String,
                      icon: items[index]["icon"] as HeroIcon,
                      onPress: items[index]["onPress"] as VoidCallback,
                      backroundcolor:
                          Theme.of(context).colorScheme.containerDark,
                      colors: items[index]["colors"] as Color,
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _getTotalMeetingTodo(
                      context: context,
                      width: items[0]["width"] as double,
                      title: items[0]["title"] as String,
                      isLightTheme: isLightTheme,
                      total: items[0]["total"] as String,
                      icon: items[0]["icon"] as HeroIcon,
                      onPress: items[0]["onPress"] as VoidCallback,
                      backroundcolor:
                          Theme.of(context).colorScheme.containerDark,
                      colors: items[0]["colors"] as Color,
                    ),
                    _getTotalMeetingTodo(
                      context: context,
                      width: items[1]["width"] as double,
                      title: items[1]["title"] as String,
                      isLightTheme: isLightTheme,
                      total: items[1]["total"] as String,
                      icon: items[1]["icon"] as HeroIcon,
                      onPress: items[1]["onPress"] as VoidCallback,
                      backroundcolor:
                          Theme.of(context).colorScheme.containerDark,
                      colors: items[1]["colors"] as Color,
                    ),
                  ],
                )
              ],
            );
          } else if (state is DashBoardStatsError) {
            return Center(
              child: Text(
                state.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _getTotal({
    required String title,
    required bool isLightTheme,
    required String total,
    required Widget icon,
    required VoidCallback? onPress,
    required Color backroundcolor,
    required int index,
    required Color colors,
    required BuildContext context

  }) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: index.isOdd ? 200.h : 120.h,
        decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          borderRadius: BorderRadius.circular(10),
          color: backroundcolor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                CustomText(
                  textAlign: TextAlign.center,
                  text: title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: total,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: AppLocalizations.of(context)!.viewmore,
                  color: colors,
                  size: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTotalMeetingTodo({
    required String title,
    required bool isLightTheme,
    required String total,
    required Widget icon,
    required VoidCallback? onPress,
    required Color backroundcolor,
    required double width,
    required Color colors,
    required BuildContext context
  }) {
    return InkWell(
      onTap: onPress,
      child: Container(
        width: width,
        height: 120.h,
        decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          borderRadius: BorderRadius.circular(10),
          color: backroundcolor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                CustomText(
                  textAlign: TextAlign.center,
                  text: title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: total,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: AppLocalizations.of(context)!.viewmore,
                  color: colors,
                  size: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 