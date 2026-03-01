import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/task_discussion/task_media/task_media_state.dart';
import '../../../bloc/task_discussion/task_timeline/task_status_timeline_bloc.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../utils/widgets/custom_text.dart';

import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/no_data.dart';
import '../../widgets/no_permission_screen.dart';

class TaskStatusTimeline extends StatefulWidget {
  final int? id;
  const TaskStatusTimeline({super.key, this.id});

  @override
  State<TaskStatusTimeline> createState() => _TaskStatusTimelineState();
}

class _TaskStatusTimelineState extends State<TaskStatusTimeline> {
  bool? isFirst;
  bool isLoadingMore = false;
  bool? isFirstTimeUSer;

  TextEditingController milestoneSearchController = TextEditingController();
  bool? isLoading = true;



  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    // filterCount = 0;

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<TaskStatusTimelineBloc>(context)
        .add(TaskStatusTimelineList());

    setState(() {
      isLoading = false;
    });
  }


  void onShowCaseCompleted() {
    _setIsFirst(false);
  }

  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: context.read<PermissionsBloc>().isManageProject == true
            ? Column(
                children: [
                  Expanded(
                    child: BlocConsumer<TaskStatusTimelineBloc,
                        TaskStatusTimelineState>(
                      listener: (context, state) {
                        if (state is TaskStatusTimelinePaginated) {
                          isLoading = false;
                          setState(() {});
                        }
                      },
                      builder: (context, state) {
                        print("fdxgxg $state");
                        if (state is TaskMediaLoading) {
                          return const NotesShimmer();
                        } else if (state is TaskStatusTimelinePaginated) {
                          // Show notes list with pagination
                          return NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo is ScrollStartNotification) {
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss keyboard
                              }
                              // Check if the user has scrolled to the end and load more notes if needed
                              if (!state.hasReachedMax &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent &&
                                  isLoading == false) {
                                isLoading = true;
                                setState(() {});
                                // context.read<ProjectMilestoneBloc>().add(
                                //     ProjectMilestoneLoadMore(
                                //         widget.id,
                                //         mileStoneSearchQuery,
                                //         "",
                                //         "",
                                //         "",
                                //         "",
                                //         "",
                                //         "",
                                //         ""));
                              }
                              return false;
                            },
                            child: context
                                        .read<PermissionsBloc>()
                                        .isManageProject ==
                                    true
                                ? state.TaskTimeline.isNotEmpty
                                    ? ListView.builder(
                                        padding: EdgeInsets.only(
                                            left: 18.w,
                                            right: 18.w,
                                            bottom: 150.h),
                                        // physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.hasReachedMax
                                            ? state.TaskTimeline.length
                                            : state.TaskTimeline.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index <
                                              state.TaskTimeline.length) {

                                            return StatusTimelineCard(
                                                state.TaskTimeline,
                                                state.TaskTimeline[index],
                                                index); // No
                                          } else {
                                            // Show a loading indicator when more notes are being loaded
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0),
                                              child: Center(
                                                child: state.hasReachedMax
                                                    ? const Text('')
                                                    : const SpinKitFadingCircle(
                                                        color:
                                                            AppColors.primary,
                                                        size: 40.0,
                                                      ),
                                              ),
                                            );
                                          }
                                        })
                                    : NoData(
                                        isImage: true,
                                      )
                                : NoPermission(),
                          );
                        } else if (state is TaskStatusTimelineError) {
                          // Show error message
                          return const NotesShimmer();
                        }
                        // Handle other states
                        return Container();
                      },
                    ),
                  )
                ],
              )
            : const NoPermission());
  }

  Widget StatusTimelineCard(projectTimelineList, projectTimeline, index) {
    Color? colorOfNewStatus;
    Color? colorOfOldStatus;

    switch (projectTimeline.oldColor) {
      case "primary":
        colorOfOldStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfOldStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfOldStatus = Colors.green;
        break;
      case "danger":
        colorOfOldStatus = Colors.red;
        break;
      case "warning":
        colorOfOldStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfOldStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfOldStatus = Colors.black;
        break;
      default:
        colorOfOldStatus = Colors.grey; // Fallback color
    }
    switch (projectTimeline.newColor) {
      case "primary":
        colorOfNewStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfNewStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfNewStatus = Colors.green;
        break;
      case "danger":
        colorOfNewStatus = Colors.red;
        break;
      case "warning":
        colorOfNewStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfNewStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfNewStatus = Colors.black;
        break;
      default:
        colorOfNewStatus = Colors.grey; // Fallback color
    }
    // Output: 2025-03-03
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: TimelineTile(
        isFirst: index == 0,
        isLast: index == projectTimelineList.length - 1,
        beforeLineStyle: LineStyle(color: colorOfNewStatus, thickness: 3),
        indicatorStyle: IndicatorStyle(
          width: 15.w,
          color: colorOfNewStatus,
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(10.0),
          child: customContainer(
              addWidget: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          projectTimeline.timeDiff,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.textClrChange),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "${projectTimeline.changedAt}  ${projectTimeline.changedAtTime}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      "changed status from ",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.textClrChange),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          // width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  colorOfOldStatus), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: CustomText(
                                  text: projectTimeline.previousStatus,
                                  color: AppColors.whiteColor,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                        Text(
                          " >> ",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.textClrChange),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          // width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  colorOfNewStatus), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: CustomText(
                                  text: projectTimeline.status,
                                  color: AppColors.whiteColor,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              context: context),
        ),
      ),
    );
  }
}
