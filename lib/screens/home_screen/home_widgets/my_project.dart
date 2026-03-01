import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../bloc/project/project_bloc.dart';
import '../../../bloc/project/project_state.dart';
import '../../../bloc/project/project_event.dart';
import '../../../config/colors.dart';
import '../../../config/constants.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/row_dashboard.dart';
import '../../../utils/widgets/user_client_box.dart';
import '../../widgets/html_widget.dart';
import '../../dash_board/dashboard.dart';
import '../../../routes/routes.dart';
import '../widgets/project_shimmer.dart';

class MyProject extends StatelessWidget {
  final BuildContext context;
  final bool isLightTheme;
  final String? languageCode;

  const MyProject({
    super.key,
    required this.context,
    required this.isLightTheme,
    this.languageCode,
  });
  //
  // String formatDateFromApi(String dateString, BuildContext context) {
  //   try {
  //     DateTime date = DateTime.parse(dateString);
  //     return DateFormat('MMM dd, yyyy').format(date);
  //   } catch (e) {
  //     return dateString;
  //   }
  // }



  Widget htmlCard(String html, BuildContext context, {double? width, double? height}) {
    return htmlWidget(html, context, width: width, height: height);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            height: 270.h,
            child: const ProjectShimmer(),
          );
        } else if (state is ProjectSuccess) {
          return const SizedBox.shrink();
        } else if (state is ProjectError) {
          return const SizedBox.shrink();
        } else if (state is ProjectPaginated) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (!state.hasReachedMax &&
                  scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                context.read<ProjectBloc>().add(ProjectLoadMore("", [], []));
              }
              return false;
            },
            child: Column(
              children: [
                state.project.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          titleTask(context, AppLocalizations.of(context)!.myproject),
                          InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => const DashBoard(initialIndex: 1),
                                ),
                              );
                            },
                            child: Container(
                              height: 20.h,
                              width: 100.w,
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: CustomText(
                                  textAlign: TextAlign.end,
                                  text: AppLocalizations.of(context)!.seeall,
                                  color: Theme.of(context).colorScheme.textClrChange,
                                  size: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                state.project.isNotEmpty
                    ? Container(
                        height: 314.h,
                        alignment: Alignment.centerLeft,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 18.w,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.hasReachedMax
                              ? state.project.length
                              : state.project.length + 1,
                          itemBuilder: (context, index) {
                            if (index < state.project.length) {
                              final project = state.project[index];
                              String? date;
                              if (project.startDate !=
                                  null) {
                                date = formatDateFromApi(
                                    project.startDate!,
                                    context);
                              }
                              // print("fcgvbh ${project.startDate}");
                              // if (project.startDate != null) {
                              //   date = formatDateFromApi(project.startDate!, context);
                              // }

                              return Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: InkWell(
                                  onTap: () {
                                    router.push('/projectdetails', extra: {
                                      "id": state.project[index].id,
                                      "projectModel":state.project[index]

                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        isLightTheme
                                            ? MyThemes.lightThemeShadow
                                            : MyThemes.darkThemeShadow,
                                      ],
                                      color: Theme.of(context).colorScheme.containerDark,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    width: 250.w,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 18.h,
                                        horizontal: 18.w,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.zero,
                                              child: CustomText(
                                                text: project.title!,
                                                color: Theme.of(context).colorScheme.textClrChange,
                                                size: 24.sp,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w600,
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ),
                                          project.description != null
                                              ? Padding(
                                                  padding: EdgeInsets.only(top: 8.h),
                                                  child: htmlCard(
                                                    project.description!,
                                                    context,
                                                    width: 290.w,
                                                    height: 36.h,
                                                  ),
                                                )
                                              : SizedBox(
                                                  height: 40.h,
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: CustomText(
                                                      text: AppLocalizations.of(context)!.nodescription,
                                                      color: AppColors.greyColor,
                                                      size: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(height: 10.h),
                                          project.users?.isEmpty == true && project.clients?.isEmpty == true
                                              ? const SizedBox.shrink()
                                              : Padding(
                                                  padding: EdgeInsets.only(top: 0.h),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            userClientDialog(
                                                              from: 'user',
                                                              title: AppLocalizations.of(context)!.allusers,
                                                              list: project.users ?? [],
                                                              context: context,
                                                            );
                                                          },
                                                          child: RowDashboard(
                                                            list: project.users ?? [],
                                                            title: "user",
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            userClientDialog(
                                                              context: context,
                                                              from: "client",
                                                              title: project.clients?.isNotEmpty == true
                                                                  ? AppLocalizations.of(context)!.allclients
                                                                  : AppLocalizations.of(context)!.allclients,
                                                              list: project.clients ?? [],
                                                            );
                                                          },
                                                          child: SizedBox(
                                                            width: 80.w,
                                                            child: RowDashboard(
                                                              list: project.clients ?? [],
                                                              title: "client",
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          SizedBox(height: 10.h),
                                          SizedBox(
                                            width: 240.w,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (project.status != null && project.status!.isNotEmpty)
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        CustomText(
                                                          text: AppLocalizations.of(context)!.status,
                                                          size: 15,
                                                          fontWeight: FontWeight.w500,
                                                          color: Theme.of(context).colorScheme.textClrChange,
                                                        ),
                                                        Container(
                                                          alignment: Alignment.center,
                                                          height: 25.h,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: Colors.blue.shade800,
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                            child: CustomText(
                                                              text: project.status ?? "",
                                                              color: AppColors.whiteColor,
                                                              size: 12.sp,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                SizedBox(width: 5.w,),
                                                if (project.priority != null && project.priority!.isNotEmpty)
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        CustomText(
                                                          text: AppLocalizations.of(context)!.priority,
                                                          size: 15,
                                                          fontWeight: FontWeight.w500,
                                                          color: Theme.of(context).colorScheme.textClrChange,
                                                        ),
                                                        Container(
                                                          alignment: Alignment.center,
                                                          height: 25.h,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: Colors.orange.shade500,
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                            child: CustomText(
                                                              text: project.priority ?? "",
                                                              color: AppColors.whiteColor,
                                                              size: 12.sp,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          date != null
                                              ? Row(
                                                  children: [
                                                    const HeroIcon(
                                                      HeroIcons.calendar,
                                                      style: HeroIconStyle.solid,
                                                      color: AppColors.blueColor,
                                                    ),
                                                    SizedBox(width: 15.w),
                                                    CustomText(
                                                      text: date,
                                                      color: AppColors.greyColor,
                                                      size: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0),
                                child: Center(
                                  child: state.hasReachedMax
                                      ? const Text('')
                                      : const SpinKitFadingCircle(
                                          color: AppColors.primary,
                                          size: 40.0,
                                        ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        }
        return const Text("");
      },
    );
  }
}

Widget titleTask(BuildContext context, String title) {
  return SizedBox(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: CustomText(
        text: title,
        color: Theme.of(context).colorScheme.textClrChange,
        size: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
} 