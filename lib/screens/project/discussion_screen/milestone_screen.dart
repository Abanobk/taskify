import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../bloc/Project/project_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/permissions/permissions_event.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../../../bloc/project_discussion/project_milestone/project_milestone_state.dart';
import '../../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_bloc.dart';
import '../../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_event.dart';
import '../../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/colors.dart';
import '../../../config/constants.dart';
import '../../../config/strings.dart';
import '../../../data/model/project/milestone.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_dimissible.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/html_widget.dart';
import '../../widgets/no_data.dart';
import '../../widgets/no_permission_screen.dart';
import '../../widgets/search_field.dart';
import '../../widgets/speech_to_text.dart';
import '../widgets/dateFilter.dart';

class MileStoneScreen extends StatefulWidget {
  final int? id;
  const MileStoneScreen({super.key,this.id});

  @override
  State<MileStoneScreen> createState() => _MileStoneScreenState();
}

class _MileStoneScreenState extends State<MileStoneScreen> {
  TextEditingController milestoneSearchController = TextEditingController();
  bool? isLoading = true;
  String milestoneSearchQuery = '';
  bool? isFirst;
  bool isLoadingMore = false;
  String fromDate = "";
  String toDate = "";
  String fromDateBetween = "";
  String toDateBetween = "";
  String fromEndDateBetweenStart = "";
  String toDateEndBetweenEnd = "";
  String? statusname;
  bool? isFirstTimeUSer;
  final ValueNotifier<String> filterNameNotifier =
  ValueNotifier<String>('Date between');
  String filterName = 'Date between';
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  DateTime selectedDateBetweenStarts = DateTime.now();
  DateTime? selectedDateBetweenEnds = DateTime.now();
  DateTime selectedDateEndBetweenStarts = DateTime.now();
  DateTime? selectedDateEndBetweenEnds = DateTime.now();

  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  TextEditingController startDateBetweenController = TextEditingController();
  TextEditingController endDateBetweenController = TextEditingController();
  TextEditingController startDateBetweenstartController =
  TextEditingController();
  TextEditingController endDateBetweenendController = TextEditingController();
  late SpeechToTextHelper speechHelper;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          milestoneSearchController.text = result;
          context.read<ProjectMilestoneBloc>().add(SearchProjectMilestone(
              widget.id, milestoneSearchQuery, "", "", "", "", "", "", ""));
        });
        Navigator.pop(context);
      },
    );
    _getFirstTimeUser();
    speechHelper.initSpeech();
  }
  _handleStartEndDate(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    print("fihdid $toDate");
  }

  _handleStartdateBetween(String from, String to) {
    setState(() {
      fromDateBetween = from;
      toDateBetween = to;
    });
  }

  __handleEnddateBetween(String from, String to) {
    setState(() {
      fromEndDateBetweenStart = from;
      toDateEndBetweenEnd = to;
    });
  }
  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<ProjectMilestoneBloc>(context).add(MileStoneList(id: widget.id));

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }
  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
  }
  void onShowCaseCompleted() {
    _setIsFirst(false);
  }
  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }
  final List<String> filter = [
    'Date between',
    'Start date between',
    'End date between',
    'Statuses',
  ];
  Widget _getFilteredWidget(filterName, isLightTheme) {
    switch (filterName) {
      case 'Date between':
        return DateList(
          onSelected: _handleStartEndDate,
          startController: startController,
          endController: endController,
          fromDate: fromDate,
          toDate: toDate,
          selectedDateEnds: selectedDateEnds,
          selectedDateStarts: selectedDateStarts,
        ); // Show ClientList if filterName is "client"
      case 'Start date between':
        return DateList(
          onSelected: _handleStartdateBetween,
          startController: startDateBetweenController,
          endController: endDateBetweenController,
          fromDate: fromDateBetween,
          toDate: toDateBetween,
          selectedDateEnds: selectedDateBetweenEnds,
          selectedDateStarts: selectedDateBetweenStarts,
        ); // Show UserList if filterName is "user"
      case 'End date between':
        return DateList(
          onSelected: __handleEnddateBetween,
          startController: startDateBetweenstartController,
          endController: endDateBetweenendController,
          fromDate: fromEndDateBetweenStart,
          toDate: toDateEndBetweenEnd,
          selectedDateEnds: selectedDateEndBetweenStarts,
          selectedDateStarts: selectedDateEndBetweenEnds,
        );
      case 'Statuses':
        return StatusOfMilestoneField(); // Show TagsList if filterName is "tags"
      default:
        return DateList(
          startController: startController,
          endController: endController,
          fromDate: fromDate,
          toDate: toDate,
          selectedDateEnds: selectedDateEnds,
          selectedDateStarts: selectedDateStarts,
        ); // Default view
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: context.read<PermissionsBloc>().isManageMilestone == true
            ? Column(
          children: [
            CustomSearchField(
              isLightTheme: isLightTheme,
              controller: milestoneSearchController,
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (milestoneSearchController.text.isNotEmpty)
                      SizedBox(
                        width: 20.w,
                        // color: AppColors.red,
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.clear,
                            size: 20.sp,
                            color: Theme.of(context)
                                .colorScheme
                                .textFieldColor,
                          ),
                          onPressed: () {
                            // Clear the search field
                            setState(() {
                              milestoneSearchController.clear();
                            });
                            // Optionally trigger the search event with an empty string
                            context.read<ProjectMilestoneBloc>().add(
                                SearchProjectMilestone(
                                    widget.id,
                                    milestoneSearchQuery,
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    "",
                                    ""));
                          },
                        ),
                      ),
                    BlocBuilder<FilterCountOfMilestoneBloc,
                        FilterCountStateOfMilestone>(
                      builder: (context, state) {
                        return SizedBox(
                          width: 35.w,
                          child: Stack(
                            children: [
                              IconButton(
                                icon: HeroIcon(
                                  HeroIcons.adjustmentsHorizontal,
                                  style: HeroIconStyle.solid,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textFieldColor,
                                  size: 30.sp,
                                ),
                                onPressed: () {
                                  // Your existing filter dialog logic
                                  _filterDialog(context, isLightTheme);
                                },
                              ),
                              if (state.count > 0)
                                Positioned(
                                  right: 5.w,
                                  top: 7.h,
                                  child: Container(
                                    padding: EdgeInsets.zero,
                                    alignment: Alignment.center,
                                    height: 12.h,
                                    width: 10.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CustomText(
                                      text: state.count.toString(),
                                      color: Colors.white,
                                      size: 6,
                                      textAlign: TextAlign.center,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      width: 30.w,
                      child: IconButton(
                        icon: Icon(
                          !speechHelper.isListening
                              ? Icons.mic_off
                              : Icons.mic,
                          size: 20.sp,
                          color: Theme.of(context)
                              .colorScheme
                              .textFieldColor,
                        ),
                        onPressed: () {
                          if (speechHelper.isListening) {
                            speechHelper.stopListening();
                          } else {
                            speechHelper.startListening(
                                context, milestoneSearchController, SearchPopUp());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              onChanged: (value) {
                milestoneSearchQuery = value;
                context.read<ProjectMilestoneBloc>().add(
                    SearchProjectMilestone(
                        widget.id,
                        milestoneSearchQuery,
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        ""));

              },
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: BlocConsumer<ProjectMilestoneBloc,
                  ProjectMilestoneState>(
                listener: (context, state) {
                  if (state is ProjectMilestonePaginated) {
                    isLoadingMore = false;
                    setState(() {});
                  }
                },
                builder: (context, state) {
                  print("klfhdskgf $state");
                  if (state is ProjectMilestoneLoading) {
                    return const NotesShimmer();
                  } else if (state is ProjectMilestonePaginated) {
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
                            isLoadingMore == false) {
                          isLoadingMore = true;
                          setState(() {});
                          context.read<ProjectMilestoneBloc>().add(
                              ProjectMilestoneLoadMore(
                                  widget.id,
                                  milestoneSearchQuery,
                                  "",
                                  "",
                                  "",
                                  "",
                                  "",
                                  "",
                                  ""));
                        }
                        return false;
                      },
                      child: context
                          .read<PermissionsBloc>()
                          .isManageProject ==
                          true
                          ? state.ProjectMilestone.isNotEmpty
                          ? ListView.builder(
                          padding: EdgeInsets.only(
                              left: 18.w,
                              right: 18.w,
                              bottom: 70.h),
                          // physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.hasReachedMax
                              ? state.ProjectMilestone.length
                              : state.ProjectMilestone.length + 1,
                          itemBuilder: (context, index) {
                            if (index <
                                state.ProjectMilestone.length) {
                              Milestone milestone =
                              state.ProjectMilestone[index];
                              String? startDate;
                              String? endDate;

                              if (milestone.startDate != null) {
                                startDate = formatDateFromApi(
                                    milestone.startDate!,
                                    context);
                              }
                              if (milestone.endDate != null) {
                                endDate = formatDateFromApi(
                                    milestone.endDate!, context);
                              }
                              double result =
                                  milestone.progress! / 100;
                              return DismissibleCard(

                                  direction: context.read<PermissionsBloc>().isdeleteProject == true &&
                                      context.read<PermissionsBloc>().iseditMilestone == true
                                      ? DismissDirection.horizontal // Allow both directions
                                      : context.read<PermissionsBloc>().isdeleteMilestone == true
                                      ? DismissDirection.endToStart // Allow delete
                                      : context.read<PermissionsBloc>().iseditMilestone == true
                                      ? DismissDirection.startToEnd // Allow edit
                                      : DismissDirection.none,
                                  title: milestone.id.toString(),
                                  confirmDismiss: (DismissDirection direction) async {
                                    if (direction == DismissDirection.startToEnd) {
                                      if (context.read<PermissionsBloc>().iseditMilestone == true) {
                                        router.push('/milestone', extra: {
                                          'isCreate': false,
                                          'milestone': milestone,
                                          "projectId": widget.id
                                        });
                                        return false;
                                      } else {
                                        // No edit permission, prevent swipe
                                        return false;
                                      }
                                    }

                                    // Handle deletion confirmation
                                    if (direction == DismissDirection.endToStart) {
                                      return await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(AppLocalizations.of(context)!.confirmDelete),
                                            content: Text(AppLocalizations.of(context)!.areyousure),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(true), // Confirm
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(false), // Cancel
                                                child: const Text('Cancel'),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                          false; // Default to false if dialog is dismissed without action
                                    }

                                    return false; // Default case for other directions
                                  },
                                  onDismissed: (DismissDirection direction) {
                                    if (direction == DismissDirection.endToStart &&
                                        context.read<PermissionsBloc>().isdeleteMilestone == true) {
                                      setState(() {
                                        state.ProjectMilestone.removeAt(index);
                                        BlocProvider.of<ProjectMilestoneBloc>(context)
                                            .add(DeleteProjectMilestone( milestone.id!));
                                        BlocProvider.of<ProjectMilestoneBloc>(context)
                                            .add(MileStoneList(id: widget.id));
                                      });
                                    } else if (direction == DismissDirection.startToEnd &&
                                        context.read<PermissionsBloc>().iseditMilestone == true) {}
                                  },
                                  dismissWidget: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 0.h),
                                    child: customContainer(
                                      context: context,
                                      addWidget: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomText(
                                                  text: "#${milestone.id.toString()}",
                                                  size: 14.sp,
                                                  color: Theme.of(context).colorScheme.textClrChange,
                                                  fontWeight: FontWeight.w700,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 0.h),
                                              child: SizedBox(
                                                width: 300.w,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.centerLeft,
                                                      height: 40.h,
                                                      child: CustomText(
                                                        text: milestone.title!,
                                                        size: 24,
                                                        color:
                                                        Theme.of(context).colorScheme.textClrChange,
                                                        fontWeight: FontWeight.w700,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment: Alignment.centerRight,
                                                      width: 100.w,
                                                      height: 40.h,
                                                      child: CustomText(
                                                        text: milestone.cost.toString(),
                                                        size: 14,
                                                        color:
                                                        Theme.of(context).colorScheme.textClrChange,
                                                        fontWeight: FontWeight.w700,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            milestone.description == null || milestone.description == ""
                                                ? SizedBox()
                                                : htmlWidget(milestone.description!, context,
                                                height: 38.h),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              height: 25.h,
                                              width: 110.w, //
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: Colors
                                                      .red.shade800), // Set the height of the dropdown
                                              child: Center(
                                                child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                    child: CustomText(
                                                      text: milestone.status!,
                                                      color: AppColors.whiteColor,
                                                      size: 15.sp,
                                                      fontWeight: FontWeight.w600,
                                                    )),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 10.h),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(
                                                    text: startDate ?? "",
                                                    size: 12.sp,
                                                    color: AppColors.greyColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  Icon(
                                                    Icons.compare_arrows,
                                                    color: AppColors.greyColor,
                                                    size: 20,
                                                  ),
                                                  CustomText(
                                                    text: endDate ?? "",
                                                    size: 12.sp,
                                                    color: AppColors.greyColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 10.h),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: LinearPercentIndicator(
                                                      padding: EdgeInsets.zero,
                                                      width: 200.w,
                                                      animation: true,
                                                      lineHeight: 8.0,
                                                      barRadius: Radius.circular(10),
                                                      animationDuration: 2500,
                                                      percent: result,
                                                      progressColor: AppColors.primary,
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                                                    child: CustomText(
                                                      text: "${milestone.progress.toString()} %",
                                                      size: 15,
                                                      color: Theme.of(context).colorScheme.textClrChange,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )); // No
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
                  } else if (state is ProjectError) {
                    // Show error message
                    return const NotesShimmer();
                  } else if (state is ProjectSuccess) {}
                  // Handle other states
                  return Container();
                },
              ),
            )
          ],
        )
            : const NoPermission());
  }
  void showToastWithProgress(BuildContext context, double progress) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.4),
              color: Theme.of(context).colorScheme.containerDark,
            ),

            // height: 50.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text:
                    "Downloading... ${(progress * 100).toStringAsFixed(0)} %",
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 15.sp,
                  ),
                  SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                    Theme.of(context).colorScheme.textClrChange,
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Remove after a few seconds or upon completion
    Future.delayed(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
  Widget milestoneCard(
      projectMilestone, index, milestone, startDate, endDate, result) {
    return DismissibleCard(
       key: ValueKey(milestone.id),
        direction: context.read<PermissionsBloc>().isdeleteProject == true &&
            context.read<PermissionsBloc>().iseditMilestone == true
            ? DismissDirection.horizontal // Allow both directions
            : context.read<PermissionsBloc>().isdeleteMilestone == true
            ? DismissDirection.endToStart // Allow delete
            : context.read<PermissionsBloc>().iseditMilestone == true
            ? DismissDirection.startToEnd // Allow edit
            : DismissDirection.none,
        title: milestone.id.toString(),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.startToEnd) {
            if (context.read<PermissionsBloc>().iseditMilestone == true) {
              router.push('/milestone', extra: {
                'isCreate': false,
                'milestone': milestone,
                "projectId": widget.id
              });
              return false;
            } else {
              // No edit permission, prevent swipe
              return false;
            }
          }

          // Handle deletion confirmation
          if (direction == DismissDirection.endToStart) {
            return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.confirmDelete),
                  content: Text(AppLocalizations.of(context)!.areyousure),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(true), // Confirm
                      child: const Text('Delete'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false), // Cancel
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            ) ??
                false; // Default to false if dialog is dismissed without action
          }

          return false; // Default case for other directions
        },
        onDismissed: (DismissDirection direction) {
          if (direction == DismissDirection.endToStart &&
              context.read<PermissionsBloc>().isdeleteMilestone == true) {
            setState(() {
              projectMilestone.removeAt(index);
              BlocProvider.of<ProjectMilestoneBloc>(context)
                  .add(DeleteProjectMilestone(milestone.id));
              BlocProvider.of<ProjectMilestoneBloc>(context)
                  .add(MileStoneList(id: widget.id));
            });
          } else if (direction == DismissDirection.startToEnd &&
              context.read<PermissionsBloc>().iseditMilestone == true) {}
        },
        dismissWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.h),
          child: customContainer(
            context: context,
            addWidget: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "#${milestone.id.toString()}",
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.h),
                    child: SizedBox(
                      width: 300.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 40.h,
                            child: CustomText(
                              text: milestone.title!,
                              size: 24,
                              color:
                              Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            width: 100.w,
                            height: 40.h,
                            child: CustomText(
                              text: milestone.cost.toString(),
                              size: 14,
                              color:
                              Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  milestone.description == null || milestone.description == ""
                      ? SizedBox()
                      : htmlWidget(milestone.description!, context,
                      height: 38.h),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 25.h,
                    width: 110.w, //
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors
                            .red.shade800), // Set the height of the dropdown
                    child: Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: CustomText(
                            text: milestone.status!,
                            color: AppColors.whiteColor,
                            size: 15.sp,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: startDate ?? "",
                          size: 12.sp,
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                        ),
                        Icon(
                          Icons.compare_arrows,
                          color: AppColors.greyColor,
                          size: 20,
                        ),
                        CustomText(
                          text: endDate ?? "",
                          size: 12.sp,
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Container(
                          child: LinearPercentIndicator(
                            padding: EdgeInsets.zero,
                            width: 200.w,
                            animation: true,
                            lineHeight: 8.0,
                            barRadius: Radius.circular(10),
                            animationDuration: 2500,
                            percent: result,
                            progressColor: AppColors.primary,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: CustomText(
                            text: "${milestone.progress.toString()} %",
                            size: 15,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
  void _filterDialog(BuildContext context, isLightTheme) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.containerDark,
      context: context,
      isScrollControlled:
      true, // Allows the bottom sheet to take the full height
      builder: (BuildContext context) {
        return FractionallySizedBox(
            heightFactor: 0.5, // 80% of the screen height
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize:
                MainAxisSize.min, // Minimize the size of the bottom sheet
                children: <Widget>[
                  SizedBox(height: 10),
                  // Title
                  CustomText(
                    text: AppLocalizations.of(context)!.selectfilter,
                    color: AppColors.primary,
                    size: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 20), // Spacing

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 230.h, // Set a specific height if needed
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filter.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    filterNameNotifier.value = filter[index];
                                    filterName = filter[index];
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  child: Container(
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        isLightTheme
                                            ? MyThemesFilter.lightThemeShadow
                                            : MyThemesFilter.darkThemeShadow,
                                      ],
                                      color: Theme.of(context)
                                          .colorScheme
                                          .containerDark,
                                    ),
                                    child: Row(
                                      children: [
                                        ValueListenableBuilder<String>(
                                          valueListenable: filterNameNotifier,
                                          builder:
                                              (context, filterName, child) {
                                            return filterName == filter[index]
                                                ? Expanded(
                                              flex: 1,
                                              child: Container(
                                                width: 2,
                                                color: AppColors.primary,
                                              ),
                                            )
                                                : Expanded(
                                                flex: 1, child: SizedBox());
                                          },
                                        ),
                                        Expanded(
                                          flex: 35,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 5.w),
                                            child: Text(
                                              filter[index],
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Vertical Divider

                      // Second Column (Placeholder for future content)
                      Expanded(
                        flex: 4,
                        child: ValueListenableBuilder<String>(
                          valueListenable: filterNameNotifier,
                          builder: (context, filterName, child) {
                            return _getFilteredWidget(filterName, isLightTheme);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h), // Spacing between content and buttons

                  // Actions (Buttons)
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // Apply Button
                        InkWell(
                          onTap: () {
                            if (statusname != null) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                ProjectUpdateFilterCountOfMileStone(
                                    filterType: 'status', isSelected: true),
                              );
                            }
                            if (fromDate.isNotEmpty) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                ProjectUpdateFilterCountOfMileStone(
                                    filterType: 'dateBetweenStart',
                                    isSelected: true),
                              );
                            }

                            if (toDateEndBetweenEnd.isNotEmpty) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                ProjectUpdateFilterCountOfMileStone(
                                    filterType: 'startDateBetweenStart',
                                    isSelected: true),
                              );
                            }
                            if (fromDateBetween.isNotEmpty) {
                              context.read<FilterCountOfMilestoneBloc>().add(
                                ProjectUpdateFilterCountOfMileStone(
                                    filterType: 'endDateBetweenStart',
                                    isSelected: true),
                              );
                            }
                            BlocProvider.of<ProjectMilestoneBloc>(context).add(
                              MileStoneList(
                                id: widget.id,
                                dateBetweenFrom: fromDate,
                                dateBetweenTo: toDate,
                                endDateTo: toDateEndBetweenEnd,
                                endDateFrom: fromEndDateBetweenStart,
                                startDateFrom: fromDateBetween,
                                startDateTo: toDateBetween,
                                status: statusname,
                                fromDate: "",
                              ),
                            );

                            // Clear search controllers
                            startController.clear();
                            endController.clear();
                            startDateBetweenController.clear();
                            endDateBetweenController.clear();
                            startDateBetweenController.clear();
                            endDateBetweenController.clear();
                            startDateBetweenstartController.clear();
                            endDateBetweenendController.clear();

                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 35.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 0.h),
                              child: Center(
                                child: CustomText(
                                  text: AppLocalizations.of(context)!.apply,
                                  size: 12.sp,
                                  color: AppColors.pureWhiteColor,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 30.w),
                        // Clear Button
                        InkWell(
                          onTap: () {
                            setState(() {
                              // // Reset all filter selections
                              context
                                  .read<FilterCountOfMilestoneBloc>()
                                  .add(ProjectResetFilterCountOfMilestone());
                              //
                              // // Clear all selected IDs
                              fromDate = "";
                              toDate = "";
                              toDateEndBetweenEnd = "";
                              fromEndDateBetweenStart = "";
                              fromDateBetween = "";
                              toDateBetween = "";
                              statusname = "";
                              startController.clear();
                              endController.clear();
                              startDateBetweenController.clear();
                              endDateBetweenController.clear();
                              startDateBetweenController.clear();
                              endDateBetweenController.clear();
                              startDateBetweenstartController.clear();
                              endDateBetweenendController.clear();
                              filterNameNotifier.value = 'Date between';
                              BlocProvider.of<ProjectMilestoneBloc>(context)
                                  .add(
                                MileStoneList(
                                  id: widget.id,
                                ),
                              );

                              Navigator.of(context).pop();
                            });
                          },
                          child: Container(
                            height: 35.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Center(
                                child: CustomText(
                                  text: AppLocalizations.of(context)!.clear,
                                  size: 12.sp,
                                  color: AppColors.pureWhiteColor,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }
  Widget StatusOfMilestoneField() {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return Container(
        constraints: BoxConstraints(maxHeight: 900.h),
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: status.length,
          itemBuilder: (BuildContext context, int index) {
            final isSelected = statusname == status[index];

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: InkWell(
                highlightColor: Colors.transparent, // No highlight on tap
                splashColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    statusname = status[index];
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 35.h,
                    decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.purpleShade
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.purple
                                : Colors.transparent)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120.w,
                              // color: Colors.red,
                              child: CustomText(
                                text: status[index],
                                fontWeight: FontWeight.w500,
                                size: 18.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                color: isSelected
                                    ? AppColors.purple
                                    : Theme.of(context)
                                    .colorScheme
                                    .textClrChange,
                              ),
                            ),
                            isSelected
                                ? const HeroIcon(HeroIcons.checkCircle,
                                style: HeroIconStyle.solid,
                                color: AppColors.purple)
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
