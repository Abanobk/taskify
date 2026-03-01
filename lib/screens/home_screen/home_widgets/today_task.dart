import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_event.dart';
import '../../../bloc/task/task_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/constants.dart';
import '../../../data/model/task/task_model.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/row_dashboard.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';

import '../../widgets/html_widget.dart';
import '../../widgets/user_client_box.dart';
import '../home_screen.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import '../../../utils/widgets/my_theme.dart';
import 'package:intl/intl.dart';

class TodayTask extends StatefulWidget {
  const TodayTask({super.key});

  @override
  State<TodayTask> createState() => _TodayTaskState();
}

class _TodayTaskState extends State<TodayTask> {
  String? fromDate;
  String? toDate;
  void onDeleteTask(task) {
    context.read<TaskBloc>().add(DeleteTask(task));
    flutterToastCustom(
        msg: AppLocalizations.of(context)!.deletedsuccessfully,
        color: AppColors.primary);
  }

  @override
  void initState() {
    _todayTask();

    BlocProvider.of<TaskBloc>(context)
        .add(TodaysTaskList(fromDate!, fromDate!));

    super.initState();
  }

  _todayTask() {
    DateTime now = DateTime.now();
    fromDate = DateFormat('yyyy-MM-dd').format(now);

    DateTime oneWeekFromNow = now.add(const Duration(days: 7));
    toDate = DateFormat('yyyy-MM-dd').format(oneWeekFromNow);


  }

  @override
  Widget build(BuildContext context) {

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TodaysTaskLoading) {
          return const NotesShimmer();
        } else if (state is TaskPaginated) {
          return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!state.hasReachedMax &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  context
                      .read<TaskBloc>()
                      .add(LoadMoreToday(fromDate!, toDate!));
                }
                return false;
              },
              child: state.task.isNotEmpty
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            titleTask(
                              context,
                              AppLocalizations.of(context)!.todaysTask,
                            ),
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                router.push('/seeAllTask');
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                height: 30.h,
                                width: 100.w,
                                // color: AppColors.red,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 18.w),
                                  child: CustomText(
                                    textAlign: TextAlign.end,
                                    text: AppLocalizations.of(context)!.seeall,
                                    // text: getTranslated(context, 'myweeklyTask'),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                    size: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 260.h,
                          width: double.infinity,
                          // color: Colors.red,
                          alignment: Alignment.centerLeft,
                          child: ListView.builder(
                              padding: EdgeInsets.only(
                                  top: 18.h,
                                  right: 18.w,
                                  left: 18.w,
                                  bottom: 18.h),
                              // physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: state.hasReachedMax
                                  ? state.task.length
                                  : state.task.length + 1,
                              itemBuilder: (context, index) {
                                if (index < state.task.length) {
                                  Tasks task = state.task[index];
                                  String? date;
                                  if (task.createdAt != null) {
                                    date = formatDateFromApi(
                                        task.createdAt!, context);
                                  }

                                  return Padding(
                                      padding: EdgeInsets.only(
                                        right: 10.w,
                                      ),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          router.push(
                                            '/taskdetail',
                                            extra: {
                                              "id": task.id,
                                              // your list of LeaveRequests
                                            },
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                isLightTheme
                                                    ? MyThemes.lightThemeShadow
                                                    : MyThemes.darkThemeShadow,
                                              ],
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .containerDark,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          width: 250.w,
                                          // height: 150.h,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w,
                                                vertical: 14.h),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  text: task.title!,
                                                  size: 24.sp,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                SizedBox(
                                                  height: 8.h,
                                                ),
                                                task.description != null
                                                    ?  htmlWidget(task.description!,context,width:290.w,height: 36.h)

                                                    : SizedBox(
                                                        height: 36.h,
                                                  child: Align(
                                                    alignment: Alignment.centerLeft, // Horizontally left, vertically centered
                                                    child:CustomText(

                                                    text: AppLocalizations.of(context)!.nodescription,
                                                    color: AppColors
                                                        .greyColor,
                                                    size: 12,
                                                    fontWeight:
                                                    FontWeight.w500,
                                                  )),
                                                      ),
                                                Divider(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .dividerClrChange),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 7.h),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    userClientDialog(
                                                                      from:
                                                                          'user',
                                                                      context:
                                                                          context,
                                                                      title: AppLocalizations.of(
                                                                              context)!
                                                                          .allusers,
                                                                      list: task
                                                                              .users!
                                                                              .isEmpty
                                                                          ? []
                                                                          : task
                                                                              .users,
                                                                    );
                                                                  },
                                                                  child: RowDashboard(
                                                                      list: task
                                                                          .users!,
                                                                      title:
                                                                          "user")),
                                                            ),
                                                            Expanded(
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    userClientDialog(
                                                                      from:
                                                                          'client',
                                                                      context:
                                                                          context,
                                                                      title: AppLocalizations.of(
                                                                              context)!
                                                                          .allclients,
                                                                      list: task
                                                                              .clients!
                                                                              .isEmpty
                                                                          ? []
                                                                          : task
                                                                              .clients,
                                                                    );
                                                                  },
                                                                  child: RowDashboard(
                                                                      list: task
                                                                          .clients!,
                                                                      title:
                                                                          "client")),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          const HeroIcon(
                                                            HeroIcons.calendar,
                                                            style: HeroIconStyle
                                                                .solid,
                                                            color: AppColors
                                                                .blueColor,
                                                          ),
                                                          SizedBox(
                                                            width: 20.w,
                                                          ),
                                                          CustomText(
                                                            text: date ?? "",
                                                            color: AppColors
                                                                .greyColor,
                                                            size: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          )
                                                          // : CustomText(
                                                          //     text: "",
                                                          //     color: AppColors
                                                          //         .greyColor,
                                                          //     size: 12,
                                                          //     fontWeight:
                                                          //         FontWeight
                                                          //             .w500,
                                                          //   )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                                } else {
                                  // Show a loading indicator when more notes are being loaded
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
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
                              }),
                        ),
                      ],
                    )
                  : const SizedBox.shrink()
              // : NoData(),
              );
        } else if (state is TaskError) {
          // Show error message
          return Center(
            child: Text(
              state.errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        // Handle other states
        return const SizedBox.shrink();
      },
    );
  }
}
