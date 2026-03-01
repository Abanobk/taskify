import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:taskify/bloc/project_discussion/project_media/project_media_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/project/milestone.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

import '../../bloc/activity_log/activity_log_bloc.dart';
import '../../bloc/activity_log/activity_log_event.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../../bloc/project_discussion/project_timeline/status_timeline_bloc.dart';

import '../../bloc/status/status_bloc.dart';
import '../../bloc/status/status_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../config/app_images.dart';
import '../../config/internet_connectivity.dart';
import '../../config/strings.dart';
import '../../data/model/task/task_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import '../task/task_discussion_screen/subtask_screen.dart';
import '../widgets/speech_to_text.dart';
import 'discussion_screen/activity_log.dart';
import 'discussion_screen/media_screen.dart';
import 'discussion_screen/milestone_screen.dart';
import 'discussion_screen/status_timeline.dart';
import '../../../src/generated/i18n/app_localizations.dart';

class DiscussionTabs extends StatefulWidget {
  final bool? fromDetail;
  final int? id;
  const DiscussionTabs({super.key, this.fromDetail, this.id});

  @override
  State<DiscussionTabs> createState() => _DiscussionTabsState();
}

class _DiscussionTabsState extends State<DiscussionTabs>
    with TickerProviderStateMixin {
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool? isLoading = true;
  bool isLoadingMore = false;
  int _selectedIndex = 0;
  String? selectedColorName;
  final Connectivity _connectivity = Connectivity();
  TextEditingController searchController = TextEditingController();
  TextEditingController mediaSearchController = TextEditingController();
  TextEditingController activityLogSearchController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  String fromDate = "";
  String toDate = "";
  TextEditingController startDateBetweenController = TextEditingController();
  TextEditingController endDateBetweenController = TextEditingController();
  TextEditingController startDateBetweenstartController =
      TextEditingController();
  TextEditingController endDateBetweenendController = TextEditingController();
  String fromDateBetween = "";
  String toDateBetween = "";
  String fromEndDateBetweenStart = "";
  String toDateEndBetweenEnd = "";
  late SpeechToTextHelper speechHelper;
  String selectedTabText = "";
  int isWhichIndex = 0;
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  DateTime selectedDateBetweenStarts = DateTime.now();
  DateTime? selectedDateBetweenEnds = DateTime.now();
  DateTime selectedDateEndBetweenStarts = DateTime.now();
  DateTime? selectedDateEndBetweenEnds = DateTime.now();
  bool? isFirstTimeUSer;
  bool? isFirst;
  String mileStoneSearchQuery = '';
  String mediaSearchQuery = '';
  String activityLogSearchQuery = '';

  TextEditingController titleController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late TabController _tabController;

  String? statusname;
  bool isDownloading = false;
  double progress = 0.0;

  List<String> status = ["Complete", "Incomplete"];
  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Date between');

  String filterName = 'Date between';

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }






  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
  }


  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }

  void onShowCaseCompleted() {
    _setIsFirst(false);
  }



  @override
  void initState() {
    super.initState();

    // Use local variable, no need to store as field
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
      }
    });

    searchController.addListener(() {
      setState(() {});
    });
    mediaSearchController.addListener(() {
      setState(() {});
    });
    activityLogSearchController.addListener(() {
      setState(() {});
    });

    _tabController = TabController(length: 5, vsync: this);

    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          context.read<ProjectMilestoneBloc>().add(SearchProjectMilestone(
              widget.id, mileStoneSearchQuery, "", "", "", "", "", "", ""));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _getFirstTimeUser();
    BlocProvider.of<ProjectMilestoneBloc>(context)
        .add(MileStoneList(id: widget.id));
    BlocProvider.of<ActivityLogBloc>(context)
        .add(AllActivityLogList(type: "project", typeId: widget.id));
    BlocProvider.of<ProjectMediaBloc>(context).add(MediaList(id: widget.id));
    BlocProvider.of<StatusTimelineBloc>(context).add(StatusTimelineList(id: widget.id));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
  // if your SpeechToTextHelper needs disposal
    _tabController.dispose();
    searchController.dispose();
    mediaSearchController.dispose();
    activityLogSearchController.dispose();
    super.dispose();
  }


  ValueNotifier<List<File>> selectedFilesNotifier = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'jpg',
          'xlsx',
          'png',
          'zip',
          'rar',
          'txt'
        ],
      );

      if (result != null) {
        List<File> pickedFiles =
            result.paths.whereType<String>().map((path) => File(path)).toList();

        // Update the ValueNotifier
        selectedFilesNotifier.value = [
          ...selectedFilesNotifier.value,
          ...pickedFiles
        ];

        print("Selected Files: ${selectedFilesNotifier.value}");
      }
    }

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _appBar(isLightTheme),
              SizedBox(height: 20.h),

              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(), // 👈 this disables sliding

                  controller: _tabController,
                  children: [
                   if( context.read<PermissionsBloc>().isManageMilestone == true )   MileStoneScreen(
                      id: widget.id,
                    ),
                    context.read<PermissionsBloc>().isManageMedia == true
                        ? MediaScreen(id: widget.id)
                        : SizedBox.shrink(),
                    StatusTimeline(id: widget.id),
                    context.read<PermissionsBloc>().isManageActivityLog == true ? ProjectActivityLogScreen(id: widget.id):SizedBox.shrink(),
                    context.read<PermissionsBloc>().isManageTask == true ? SubTaskScreen(taskId: widget.id!,from:"projectTask"):SizedBox.shrink()
                  ],
                ),
              ),
              // Add bottom space to ensure content is visible behind the floating bar
              // SizedBox(height: 60.h),
            ],
          ),

          // Floating action button
          Visibility(
            visible: _selectedIndex != 2 &&
                _selectedIndex != 3 , // Hide for index 2 and 3
            child: Positioned(
              right: 20.w,
              bottom: 100.h,
              child: FloatingActionButton(
                isExtended: true,
                onPressed: () {
                  if (_selectedIndex == 0 && context.read<PermissionsBloc>().iscreateMilestone == true) {
                    // Milestone tab + permission
                    router.push("/milestone", extra: {
                      "isCreate": true,
                      "projectId": widget.id,
                      "milestone": Milestone(
                        id: 0,
                        title: "",
                        description: "",
                        startDate: "",
                        status: "",
                        endDate: "",
                        progress: 0,
                        createdAt: "",
                        cost: "",
                        createdBy: "",
                        updatedAt: "",
                      )
                    });
                  }
                  else if (_selectedIndex == 1 && context.read<PermissionsBloc>().iscreateMedia == true) {
                    // Media tab + permission
                    _uploadFile(
                      pickFile: _pickFile,
                      selectedFileName: selectedFilesNotifier,
                    );
                  }  else if (_selectedIndex == 4 && context.read<PermissionsBloc>().iscreatetask == true) {
                    // Media tab + permission
                    BlocProvider.of<UserBloc>(context).add(UserList());
                    BlocProvider.of<StatusBloc>(context).add(StatusList());
                    router.push('/createtask', extra: {
                      "id": 0,
                      "isCreate": true,
                      "title": "",
                      "desc": "",
                      "start": "",
                      "end": "",
                      "users": [],
                      'priority': "",
                      'priorityId': 0,
                      'statusId': 0,
                      'note': "",
                      'tasksModel':Tasks.empty(),
                      'project': "",
                      'projectId': 0,
                      'status': "",
                      'req': <Tasks>[],
                    });
                  } else {
                    // No permission: do nothing or show a toast/snackbar if you want
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.add,
                  color: AppColors.whiteColor,
                ),
              ),
              // return empty widget if condition not met
            ),
          ),

          // Floating bottom navigation
          Positioned(
            bottom: 20.h,
            left: 18.w,
            right: 18.w,
            child: _floatingBottomNavBar(context, isLightTheme),
          ),
        ],
      ),
    );
  }


  Widget _tabItem(
    HeroIcons icon,
    String text,
    Color color,
    int index,
  ) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _navigateToIndex(index);
        isWhichIndex = index;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(
            icon,
            style: HeroIconStyle.outline,
            size: 18.sp,
            color: color,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: isSelected
                ? Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Text(
                      text,
                      key: ValueKey(text), // Smooth transition
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _appBar(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: BackArrow(
        onTap: () {
          router.pop();
        },
        projectId: widget.id,
        discussionScreen: "projectDiscussion",
        iSBackArrow: true,
        iscreatePermission: true,
        title: (() {
          switch (_selectedIndex) {
            case 0:
              return AppLocalizations.of(context)!.milestone;
            case 1:
              return AppLocalizations.of(context)!.media;
            case 2:
              return AppLocalizations.of(context)!.statustimeline;
            case 3:
              return AppLocalizations.of(context)!.activityLog;
              case 4:
              return AppLocalizations.of(context)!.tasksFromDrawer;
            default:
              return AppLocalizations.of(context)!.milestone;
          }
        })(),
        onPress: () {
          // _createEditStatus(isLightTheme: isLightTheme, isCreate: true);
        },
      ),
    );
  }

  Widget _floatingBottomNavBar(BuildContext context, bool isLightTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: 50.h, // Reduced height
          decoration: BoxDecoration(
            color: isLightTheme
                ? Colors.white
                    .withValues(alpha:0.15) // More transparent for light theme
                : Colors.black
                    .withValues(alpha:0.15), // More transparent for dark theme
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isLightTheme
                  ? Colors.white.withValues(alpha:0.2)
                  : Colors.white.withValues(alpha:0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLightTheme
                    ? Colors.black.withValues(alpha:0.05)
                    : Colors.black.withValues(alpha:0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (context.read<PermissionsBloc>().isManageMilestone == true)
                _tabItem(HeroIcons.listBullet, "Milestone", AppColors.mileStoneColor, 0),
              if (context.read<PermissionsBloc>().isManageMedia == true)
                _tabItem(HeroIcons.photo, "Media", AppColors.photoColor, 1),
              _tabItem(HeroIcons.bars3, "Status", AppColors.yellow, 2),
              if (context.read<PermissionsBloc>().isManageActivityLog == true) _tabItem(HeroIcons.chartBar, "Activity", AppColors.activityLogColor, 3),
              if (context.read<PermissionsBloc>().isManageTask == true) _tabItem(HeroIcons.documentCheck, "Task", AppColors.primary, 4),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _uploadFile({pickFile, selectedFileName}) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              height: 455.h,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                height: 40.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.greyColor
                                      .withValues(alpha: 0.3),
                                ),
                                child: HeroIcon(
                                  HeroIcons.cloudArrowUp,
                                  style: HeroIconStyle.outline,
                                  size: 25.sp,
                                  color: AppColors.greyColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Upload files",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text("Select and upload the files ",
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 35,
                          // color: Colors.red,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(
                          border: DashedBorder.fromBorderSide(
                              dashLength: 15,
                              side: BorderSide(
                                  color: AppColors.greyColor, width: 1)),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Container(
                              height: 70.h,
                              width: 70.w,
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                image: DecorationImage(
                                    image: AssetImage(AppImages.cloudGif),
                                    fit: BoxFit.cover),
                              )),
                          const SizedBox(height: 8),
                          FittedBox(
                            child: CustomText(
                                text: AppLocalizations.of(context)!
                                    .chooseafileorclickbelow,
                                size: 20.sp,
                                textAlign:
                                    TextAlign.center, // Center align if needed
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange),
                          ),
                          CustomText(
                            text: AppLocalizations.of(context)!.formatandsize,
                            color: AppColors.greyColor,
                            size: 15.sp,
                            textAlign: TextAlign
                                .center, // Make sure it wraps instead of cutting off
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: pickFile,
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6)),
                                height: 30.h,
                                width: 100.w,
                                margin: EdgeInsets.symmetric(vertical: 10.h),
                                child: CustomText(
                                  text:
                                      AppLocalizations.of(context)!.browsefile,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.pureWhiteColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    InkWell(
                      onTap: () {
                        print("gklr dlgknv ");
                        context.read<ProjectMediaBloc>().add(UploadMedia(
                            id: widget.id!,
                            media: selectedFilesNotifier.value));
                        selectedFilesNotifier.value = [];
                        router.pop();
                      },
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6)),
                          height: 30.h,
                          width: 100.w,
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          child: CustomText(
                            text: AppLocalizations.of(context)!.upload,
                            size: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pureWhiteColor,
                          )),
                    ),
                    // if (selectedFilesNotifier.value.isNotEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 12),
                    //     child: Text("Selected File: ${selectedFilesNotifier.value}"),
                    //   ),
                  ],
                ),
              ),
            ),
          );
        });
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
}
