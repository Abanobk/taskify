import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/screens/home_screen/home_widgets/upcoming_birthday.dart';
import 'package:taskify/screens/home_screen/home_widgets/work_anniversary.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../bloc/birthday/birthday_bloc.dart';
import '../../bloc/birthday/birthday_event.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/dashboard_stats/dash_board_stats_event.dart';
import '../../bloc/income_expense/income_expense_bloc.dart';
import '../../bloc/income_expense/income_expense_event.dart';
import '../../bloc/leave_req_dashboard/leave_req_dashboard_bloc.dart';
import '../../bloc/leave_req_dashboard/leave_req_dashboard_event.dart';
import '../../bloc/leave_request/leave_request_bloc.dart';
import '../../bloc/leave_request/leave_request_event.dart';

import '../../bloc/notifications/system_notification/notification_bloc.dart';
import '../../bloc/notifications/system_notification/notification_event.dart';
import '../../bloc/notifications/system_notification/notification_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project_filter/project_filter_bloc.dart';
import '../../bloc/project_filter/project_filter_event.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/task_filter/task_filter_bloc.dart';
import '../../bloc/task_filter/task_filter_event.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/languages/language_switcher_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user_profile/user_profile_bloc.dart';
import '../../bloc/user_profile/user_profile_event.dart';
import '../../bloc/work_anniveresary/work_anniversary_bloc.dart';
import '../../bloc/work_anniveresary/work_anniversary_event.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../config/strings.dart';
import '../../data/localStorage/hive.dart';
import '../../src/generated/i18n/app_localizations.dart';import '../../routes/routes.dart';
import '../widgets/buynow.dart';
import 'home_widgets/leave_request.dart';
import 'home_widgets/line_chart.dart';
import 'home_widgets/pie_chart.dart';
import 'home_widgets/today_task.dart';
import 'home_widgets/welcome_card.dart';
import 'home_widgets/current_workspace.dart';
import 'home_widgets/total_stats.dart';
import 'home_widgets/drawer_widgets.dart';
import 'home_widgets/my_project.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  // final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  int? totalProjects = 0;
  int? totalTask = 0;
  int? totalUser = 0;
  int? totalClient = 0;
  int? totalMeeting = 0;
  int? totalTodos = 0;
  String? usersname;
  int? usersId;
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  List<int> clientSelectedId = [];
  List<String> clientSelectedname = [];

  List<int> userSelectedIdForAnni = [];
  List<String> userSelectednameForAnni = [];

  List<int> userSelectedIdForLeavereq = [];
  List<String> userSelectednameLeavereq = [];
  int upcomingDays = 7;
  int upcomingMonths = 30;
  int days = 0;
  String? weekMonth;

  String? hasGuard;
  String searchWord = "";

  String? languageCode;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _buyNowController;
// Add ScrollController
  bool isExpand = false;

  void toggleDrawer(bool expanded) {
    setState(() {
      isExpand = expanded;
    });
  }

  void getWorkSpace() async {
    var box = await Hive.openBox(userBox);
    workSpaceTitle = box.get('workspace_title');
  }

  String? fromDate;
  int? statusPending;
  String? toDate;
  bool? isLoading = true;
  String? role;
  bool? isConnectedToInternet;
  StreamSubscription? _internetConnectionStreamSubscription;
  String? photo;
  Timer? _debounce;

  @override
  void initState() {
    _todayTask();
    _buyNowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scrollController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          print('Scroll position: ${_scrollController.position.pixels}');
          print('Has clients: ${_scrollController.hasClients}');
          print('Has content dimensions: ${_scrollController.position.hasContentDimensions}');
        }
      });
    });
    Future.microtask(() {
      if (mounted && _scrollController.hasClients) {
        setState(() {});
      }
    });
    context.read<FilterCountBloc>().add(ProjectResetFilterCount());
    context.read<TaskFilterCountBloc>().add(TaskResetFilterCount());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    statusPending = context.read<LeaveRequestBloc>().statusPending;
    context.read<DashBoardStatsBloc>().totalTodos.toString();
    context.read<DashBoardStatsBloc>().totalProject.toString();

    context.read<DashBoardStatsBloc>().totalTask.toString();
    context.read<DashBoardStatsBloc>().totaluser.toString();
    context.read<DashBoardStatsBloc>().totalClient.toString();
    context.read<DashBoardStatsBloc>().totalMeeting.toString();
    BlocProvider.of<WorkspaceBloc>(context).add(const WorkspaceList());
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    BlocProvider.of<NotificationBloc>(context).add(UnreadNotificationCount());
    BlocProvider.of<SettingsBloc>(context).add(SettingsList("general_settings"));


    _getRole();
    super.initState();
  }


  @override
  void dispose() {
    _debounce?.cancel();
    _buyNowController.dispose();
    _scrollController.dispose(); // Dispose of the controller
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  _todayTask() {
    DateTime now = DateTime.now();
    fromDate = DateFormat('yyyy-MM-dd').format(now);

    DateTime oneWeekFromNow = now.add(const Duration(days: 7));
    toDate = DateFormat('yyyy-MM-dd').format(oneWeekFromNow);
  }

  Future<void> _onRefresh() async {
    _todayTask();

    setState(() {
      isLoading = true;
    });
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    statusPending = context.read<LeaveRequestBloc>().statusPending;
    context.read<DashBoardStatsBloc>().totalTodos.toString();
    context.read<DashBoardStatsBloc>().totalProject.toString();
    context.read<DashBoardStatsBloc>().totalTask.toString();
    context.read<DashBoardStatsBloc>().totaluser.toString();
    context.read<DashBoardStatsBloc>().totalClient.toString();
    context.read<DashBoardStatsBloc>().totalMeeting.toString();
    BlocProvider.of<ChartBloc>(context)
        .add(FetchChartData(endDate: "", startDate: ""));

    BlocProvider.of<WorkspaceBloc>(context).add(const WorkspaceList());
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    BlocProvider.of<NotificationBloc>(context).add(UnreadNotificationCount());
    // BlocProvider.of<TaskBloc>(context).add(TodaysTaskList(fromDate!, toDate!));

    _getRole();
    setState(() {
      isLoading = false;
    });
  }

  String? greetingMessage;
  String? greetingEmoji;
  String? getLanguage;

  void _greeting() {
    greetingMessage = getGreeting(context);
    greetingEmoji = getGreetingEmoji();
  }
  Future<void> _getRole() async {
    final fetchedRole = await HiveStorage.getRole();
    setState(() {
      role = fetchedRole; // Assign the fetched role
      // Conditionally dispatch BLoC events based on role
      if (role != 'client' && role != 'Client') {
        BlocProvider.of<WorkAnniversaryBloc>(context)
            .add(WeekWorkAnniversaryList([], [], 7,[],[]));
        BlocProvider.of<BirthdayBloc>(context).add(WeekBirthdayList(7, [], [],[],[]));
        BlocProvider.of<LeaveReqDashboardBloc>(context)
            .add(WeekLeaveReqListDashboard([], 7,[]));
      }
    });
  }


  void _handleUsersNameForAnni(List<String> userName, List<int> userId) {
    setState(() {
      userSelectednameForAnni = userName;
      userSelectedIdForAnni = userId;
    });
  }

  void _handleUsersNameForLeaveReq(List<String> userName, List<int> userId) {
    setState(() {
      userSelectednameLeavereq = userName;
      userSelectedIdForLeavereq = userId;
    });
  }

  String? photoWidget;
  String? email;
  String? roleInUser;
  String? firstNameUser;
  String? lastNameUSer;
  String? workSpaceTitle;
  bool projectChart = false;
  bool taskChart = false;
  bool isExpanded = false;
  void handleIsProjectChart(
    bool status,
  ) {
    setState(() {
      // userId = id;
      projectChart = status;
    });
  }

  void handleIsTaskChart(
    bool status,
  ) {
    setState(() {
      // userId = id;
      taskChart = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    _todayTask();
    BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    statusPending = context.read<LeaveRequestBloc>().statusPending;
    BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());
    BlocProvider.of<LeaveRequestBloc>(context).add(GetPendingLeaveRequest());
    _greeting();
    hasGuard = context.read<AuthBloc>().guard;
    context.read<AuthBloc>().guard;
    context.read<AuthBloc>().hasAllDataAccess;
    context.read<AuthBloc>().userId;
    // _getRole();
    return BlocProvider(
      create: (context) => ClientBloc()..add(ClientList()),
      child: BuyNowPage(
        animationController: _buyNowController,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          drawer: isExpand ? _drawerIn() : _expandedDrawer(),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(40.h), // Set your custom height here
            child: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: isLightTheme ? Colors.transparent : Colors.black,
                statusBarIconBrightness:
                    isLightTheme ? Brightness.dark : Brightness.light,
                statusBarBrightness:
                    isLightTheme ? Brightness.light : Brightness.dark,
              ),
              backgroundColor: Colors.transparent,
              leadingWidth: 50.w,
              leading: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                child: GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: SizedBox(
                    width: 50.w,
                    height: 30.h,
                    child: HeroIcon(
                      HeroIcons.bars3BottomLeft,
                      style: HeroIconStyle.outline,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Row(
                    children: [
                      Stack(children: [
                        GestureDetector(
                          onTap: () {
                            router.push("/notification");
                          },
                          child: SizedBox(
                            // color: AppColors.red,
                            height: 50.h,
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w, right: 10.w),
                              child: HeroIcon(
                                HeroIcons.bell,
                                style: HeroIconStyle.outline,
                                size: 20.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            right: 5.w,
                            top: 2.h,
                            child: BlocConsumer<NotificationBloc,
                                NotificationsState>(listener: (context, state) {
                              if (state is NotificationPaginated) {}
                            }, builder: (context, state) {
                              if (state is UnreadNotification) {
                                return state.total == 0
                                    ? SizedBox()
                                    : Container(
                                        height: 15.sp,
                                        width: 15.sp,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.yellow.shade800,
                                        ),
                                        child: Center(
                                            child: CustomText(
                                          size: 10,
                                          fontWeight: FontWeight.w600,
                                          text: state.total.toString(),
                                          color: AppColors.pureWhiteColor,
                                        )),
                                      );
                              }
                              return SizedBox();
                            }))
                      ]),
                      GestureDetector(
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                        child: SizedBox(
                          // color: AppColors.red,
                          height: 50.h,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.w, right: 5.w),
                            child: HeroIcon(
                              HeroIcons.language,
                              style: HeroIconStyle.outline,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          body:ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Theme.of(context).colorScheme.backGroundColor,
              onRefresh: _onRefresh,
              child: Builder(
                builder: (context) {
                  bool hasScrollPosition = _scrollController.hasClients &&
                      _scrollController.position.hasContentDimensions;
                  return Scrollbar(
                      controller: _scrollController,
                      thickness: hasScrollPosition ? 4.0 : 0.0,
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const ClampingScrollPhysics(), // Prevent overscroll
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height,
                              ),
                              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        SizedBox(height: 10.h),
                        _welcomeCard(isLightTheme),
                        SizedBox(height: 15.h),
                        _currentWorkspace(isLightTheme),
                        SizedBox(height: 0.h),
                        _totalstats(isLightTheme),
                        Row(
                          children: [
                            SizedBox(width: 9.w),
                            Expanded(
                              child: DoughnutChart(
                                type: "project",
                                title: AppLocalizations.of(context)!.projectstats,
                                isReverse: false,
                                onChangeForProject: handleIsProjectChart,
                                onChangeForTask: (bool _) {},
                              ),
                            ),
                            Expanded(
                              child: DoughnutChart(
                                type: "task",
                                title: AppLocalizations.of(context)!.taskectstats,
                                isReverse: false,
                                onChangeForTask: handleIsTaskChart,
                                onChangeForProject: (bool _) {},
                              ),
                            ),
                            SizedBox(width: 9.w),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: DoughnutChart(
                            title: AppLocalizations.of(context)!.todosoverview,
                            isReverse: true,
                            onChangeForProject: (bool _) {},
                            onChangeForTask: (bool _) {},
                          ),
                        ),
                        SizedBox(height: 15.h),
                        ChartPage(),
                        SizedBox(height: 10.h),
                        context.read<PermissionsBloc>().isManageProject == true
                            ? MyProject(
                                context: context,
                                isLightTheme: isLightTheme,
                                languageCode: languageCode,
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageTask == true
                            ? TodayTask()
                            : const SizedBox.shrink(),
                        (role == "Client" || role == 'client')
                            ? const SizedBox.shrink()
                            :  context.read<SettingsBloc>().upcomingBirthdays==0 ?SizedBox():UpcomingBirthday(
        
                              ),
                        (role == "Client" || role == 'client')
                            ? const SizedBox.shrink()
                            :  context.read<SettingsBloc>().upcomingBirthdays==0 ?SizedBox():SizedBox(height: 20.h),
                        (role == "Client" || role == 'client')
                            ? const SizedBox.shrink()
                            : context.read<SettingsBloc>().upcomingAnniversary==0 ?SizedBox():UpcomingWorkAnniversary(
                                onSelected: _handleUsersNameForAnni,),
                        (role == "Client" || role == 'client')
                            ? SizedBox(height: 20.h)
                            : context.read<SettingsBloc>().membersOnLeave==0 ?SizedBox():LeaveRequest(
                                onSelected: _handleUsersNameForLeaveReq,),
                        SizedBox(height: 60.h),
                      ],
                    ))));
                  },
                ),
              ),
            ),
          ),
      ));

  }

  void _showLanguageDialog(BuildContext context) {
    String? selectedLanguage =
        context.read<LanguageBloc>().state.locale.languageCode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.r), // Set the desired radius here
          ),
          contentPadding: EdgeInsets.only(
            right: 10.w,
            bottom: 30.h,
          ),
          actionsPadding: EdgeInsets.only(
            right: 10.w,
            bottom: 30.h,
          ),
          title: Text(AppLocalizations.of(context)!.chooseLang),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: 50.w,
                  // height: MediaQueryHelper.screenHeight(context) * 0.2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          'English',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'en',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          'हिन्दी',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'hi',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          'عربي',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'ar',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          '한국인',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'ko',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ), //Korean
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          '베트남 사람',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'vi',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ), //Vietnamese
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          '포르투갈 인',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'pt',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ), //Portuguese
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontFamily: "Poppins-Bold",
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontFamily: "Poppins-Bold",
                ),
              ),
              onPressed: () {
                if (selectedLanguage != null) {
                  // HiveStorage().storeLanguage(selectedLanguage!);

                  context.read<LanguageBloc>().add(
                        ChangeLanguage(languageCode: selectedLanguage!),
                      );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _welcomeCard(isLightTheme) {
    return WelcomeCard(
      isLightTheme: isLightTheme,
      greetingMessage: greetingMessage,
      greetingEmoji: greetingEmoji,
      photo: photo,
    );
  }

  Widget _currentWorkspace(isLightTheme) {
    getWorkSpace();
    return CurrentWorkspace(
      isLightTheme: isLightTheme,
      workSpaceTitle: workSpaceTitle,
    );
  }

  Widget _totalstats(isLightTheme) {
    return TotalStats(
      isLightTheme: isLightTheme,
    );
  }

  Widget _drawerIn() {
    return DrawerWidgets(
      isExpand: isExpand,
      toggleDrawer: toggleDrawer,
      statusPending: statusPending,
      firstNameUser: firstNameUser,
      lastNameUSer: lastNameUSer,
      email: email,
      roleInUser: roleInUser,
      photoWidget: photoWidget,
      role: role,
    );
  }

  Widget _expandedDrawer() {
    return DrawerWidgets(
      isExpand: isExpand,
      toggleDrawer: toggleDrawer,
      statusPending: statusPending,
      firstNameUser: firstNameUser,
      lastNameUSer: lastNameUSer,
      email: email,
      roleInUser: roleInUser,
      photoWidget: photoWidget,
      role: role,
    );
  }
}

Widget titleTask(context, title) {
  return SizedBox(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: CustomText(
        text: title,
        // text: getTranslated(context, 'myweeklyTask'),
        color: Theme.of(context).colorScheme.textClrChange,
        size: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
