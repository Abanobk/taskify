import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:taskify/bloc/comments/comments_bloc.dart';


import '../../../src/generated/i18n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskify/bloc/allowance_single/single_allowance_event.dart';
import 'package:taskify/bloc/contracts/contracts_event.dart';
import 'package:taskify/bloc/contracts_type/contracts_type_event.dart';
import 'package:taskify/bloc/expense/expense_bloc.dart';
import 'package:taskify/bloc/expense_filter/expense_filter_bloc.dart';
import 'package:taskify/bloc/expense_type/expense_type_event.dart';
import 'package:taskify/bloc/interviews/interviews_event.dart';
import 'package:taskify/bloc/items/item_event.dart';
import 'package:taskify/bloc/notes/notes_bloc.dart';
import 'package:taskify/bloc/payment/payment_event.dart';
import 'package:taskify/bloc/payment_method/payment_method_event.dart';
import 'package:taskify/bloc/payslip/payslip/payslip/payslip_bloc.dart';
import 'package:taskify/bloc/payslip/payslip/payslip/payslip_event.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:taskify/bloc/auth/auth_bloc.dart';
import 'package:taskify/bloc/task/task_event.dart';
import 'package:taskify/bloc/taxes/tax_event.dart';
import 'package:taskify/bloc/theme/theme_event.dart';
import 'package:taskify/bloc/user/user_bloc.dart';
import 'package:taskify/routes/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/widgets/firebase_services.dart';
import '../bloc/allowance_single/single_allowance_bloc.dart';
import '../bloc/candidate/candidates_bloc.dart';
import '../bloc/candidate/candidates_event.dart';
import '../bloc/candidate_attachment/candidate_attachment_bloc.dart';
import '../bloc/candidate_interviews/candidate_interviews_bloc.dart';
import '../bloc/candidate_status/candidates_status_bloc.dart';
import '../bloc/candidate_status/candidates_status_event.dart';
import '../bloc/contracts/contracts_bloc.dart';
import '../bloc/contracts_type/contracts_type_bloc.dart';
import '../bloc/custom_fields/custom_field_bloc.dart';
import '../bloc/custom_fields/custom_field_event.dart';
import '../bloc/deduction_single/single_deduction_bloc.dart';
import '../bloc/deduction_single/single_deduction_event.dart';
import '../bloc/estimate_invoice/estimateInvoice_bloc.dart';
import '../bloc/estimate_invoice/estimateInvoice_event.dart';
import '../bloc/estimate_invoice_filter/estimate_invoice_filter_bloc.dart';
import '../bloc/estimate_invoice_item_list/estimateInvoice_list_bloc.dart';
import '../bloc/interviews/interviews_bloc.dart';
import '../bloc/lead_id/leadid_bloc.dart';
import '../bloc/leads/leads_bloc.dart';
import '../bloc/leads_source/lead_source_bloc.dart';
import '../bloc/leads_stage/lead_stage_bloc.dart';
import '../bloc/leads_stage/lead_stage_event.dart';
import '../bloc/payment/payment_bloc.dart';
import '../bloc/payment_filter/payment_filter_bloc.dart';
import '../bloc/payment_method/payment_method_bloc.dart';
import '../bloc/payslip/allowances/allowance_bloc.dart';
import '../bloc/payslip/deductions/deduction_bloc.dart';
import '../bloc/status/status_bloc.dart';
import '../bloc/taxes/tax_bloc.dart';
import '../bloc/units/unit_bloc.dart';
import '../bloc/units/unit_event.dart';
import '../bloc/expense/expense_event.dart';
import '../bloc/client_id/clientid_bloc.dart';
import '../bloc/clients/client_event.dart';
import '../bloc/expense_type/expense_type_bloc.dart';
import '../bloc/income_expense/income_expense_bloc.dart';
import '../bloc/income_expense/income_expense_event.dart';
import '../bloc/items/item_bloc.dart';
import '../bloc/leave_req_dashboard/leave_req_dashboard_bloc.dart';
import '../bloc/leave_req_dashboard/leave_req_dashboard_event.dart';
import '../bloc/meeting/meeting_bloc.dart';
import '../bloc/birthday/birthday_bloc.dart';
import '../bloc/clients/client_bloc.dart';
import '../bloc/leave_request/leave_request_bloc.dart';
import '../bloc/notifications/push_notification/notification_push_bloc.dart';
import '../bloc/notifications/system_notification/notification_bloc.dart';
import '../bloc/priority/priority_bloc.dart';
import '../bloc/priority/priority_event.dart';
import '../bloc/privacy_aboutus_termscond/privacy_aboutus_termscond_bloc.dart';
import '../bloc/project/project_bloc.dart';
import '../bloc/project_discussion/project_media/project_media_bloc.dart';
import '../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../bloc/project_discussion/project_milestone_filter/project_milestone_filter_bloc.dart';
import '../bloc/project_discussion/project_timeline/status_timeline_bloc.dart';
import '../bloc/project_filter/project_filter_bloc.dart';
import '../bloc/project_id/projectid_bloc.dart';
import '../bloc/roles/role_bloc.dart';
import '../bloc/roles_multi/role_multi_bloc.dart';
import '../bloc/setting/settings_bloc.dart';
import '../bloc/tags/tags_bloc.dart';
import '../bloc/tags/tags_event.dart';
import '../bloc/task_discussion/task_media/task_media_bloc.dart';
import '../bloc/task_discussion/task_timeline/task_status_timeline_bloc.dart';
import '../bloc/task_filter/task_filter_bloc.dart';
import '../bloc/task_id/taskid_bloc.dart';
import '../bloc/todos/todos_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user_id/userid_bloc.dart';
import '../bloc/workspace/workspace_bloc.dart';
import '../bloc/activity_log/activity_log_bloc.dart';
import '../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../bloc/languages/language_switcher_bloc.dart';
import '../bloc/languages/language_switcher_state.dart';
import '../bloc/multi_tag/tag_multi_bloc.dart';
import '../bloc/priority_multi/priority_multi_bloc.dart';
import '../bloc/profile_picture/profile_pic_bloc.dart';
import '../bloc/project_multi/project_multi_bloc.dart';
import '../bloc/single_client/single_client_bloc.dart';
import '../bloc/single_select_project/single_select_project_bloc.dart';
import '../bloc/single_select_project/single_select_project_event.dart';
import '../bloc/single_user/single_user_bloc.dart';
import '../bloc/status/status_event.dart';
import '../bloc/status_multi/status_multi_bloc.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import '../bloc/user_profile/user_profile_bloc.dart';
import '../bloc/work_anniveresary/work_anniversary_bloc.dart';
import '../bloc/workspace/workspace_event.dart';
import 'dart:async';
import '../data/localStorage/hive.dart';

import '../data/repositories/comments/comment_repo.dart';



class MyApp extends StatefulWidget {
  final bool isDarkTheme;

  const MyApp({super.key, required this.isDarkTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;
  bool _showLockScreen = false;
  bool defaultBiometric = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  String? fcmToken;

  @override
  void initState() {
    print(_lastLifecycleState);
    super.initState();
    getBiometric();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginAndSecure();
    _initializeNotification();
  }

  Future<String?> _IsLoggedIn() async {
    final String? token = await HiveStorage.getToken();
    print('Token: $token');
    return token;
  }

  Future<void> _checkLoginAndSecure() async {
    final String? token = await _IsLoggedIn();

    if (token == null || token.isEmpty) {
      navigatorKey.currentState?.pushReplacementNamed('/login');
      return;
    }

    defaultBiometric = await HiveStorage.getBiometricAuth();
    print('Initial biometric setting: $defaultBiometric');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> getBiometric() async {
    defaultBiometric = await HiveStorage.getBiometricAuth();
    print('Fetched biometric setting: $defaultBiometric');
    return defaultBiometric;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    await getBiometric();
    print("AppLifecycleState: $state, defaultBiometric: $defaultBiometric");
    _lastLifecycleState = state;

    if (state == AppLifecycleState.paused) {
      setState(() {
        _showLockScreen = true;
      });
    }

    if (state == AppLifecycleState.resumed && _showLockScreen && defaultBiometric) {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();
      print('Can check biometrics: $canCheck, Device supported: $supported');

      if (canCheck && supported) {
        _authenticateUser();
      } else {
        setState(() {
          _showLockScreen = false;
        });
        print('Biometrics not available, bypassing lock screen');
      }
    }
  }

  Future<void> _authenticateUser() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool isAuthenticated = false;

    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      print('Can check biometrics: $canCheckBiometrics');
      print('Device supported: $isSupported');
      print('Default biometric enabled: $defaultBiometric');

      if (defaultBiometric && canCheckBiometrics && isSupported) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to continue',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
        print('Authentication result: $isAuthenticated');
      } else {
        print('Bypassing authentication: Biometrics not available or not enabled');
        isAuthenticated = true;
      }
    } catch (e) {
      print('Authentication error: $e');
      isAuthenticated = false;
    }

    setState(() {
      _showLockScreen = !isAuthenticated;
    });

    if (!isAuthenticated) {
      print('Authentication failed, redirecting to login');
      navigatorKey.currentState?.pushReplacementNamed('/login');
    }
  }

  Future<void> _initializeNotification() async {
    await NotificationService().initFirebaseMessaging(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ThemeBloc.loadTheme(),
      builder: (context, snapshot) {
        final isDarkTheme = snapshot.data ?? false;
        return MultiProvider(
          providers: [
            BlocProvider(
              create: (context) {
                final themeBloc = ThemeBloc();
                themeBloc.add(InitialThemeEvent(isDarkTheme));
                return themeBloc;
              },
            ),
            BlocProvider(create: (_) => LanguageBloc.instance),
            BlocProvider(create: (_) => AuthBloc()),
            BlocProvider(create: (_) => ProfilePicBloc()),
            BlocProvider(create: (_) => TaskBloc()..add(AllTaskListOnTask())),
            BlocProvider(create: (_) => UserBloc()..add(UserList())),
            BlocProvider(
                create: (_) => EstinateInvoiceBloc()
                  ..add(EstinateInvoiceLists([], [], [], [], "", ""))),
            BlocProvider(create: (_) => NotesBloc()),
            BlocProvider(create: (_) => TodosBloc()),
            BlocProvider(create: (_) => ProjectBloc()),
            BlocProvider(create: (_) => SingleClientBloc()),
            BlocProvider(create: (_) => ActivityLogBloc()),
            BlocProvider(create: (_) => WorkAnniversaryBloc()),
            BlocProvider(create: (_) => LeaveRequestBloc()),
            BlocProvider(create: (_) => ClientidBloc()),
            BlocProvider(
                create: (_) => CandidatesStatusBloc()..add(CandidatesStatusList())),
            BlocProvider(create: (_) => TaskFilterCountBloc()),
            BlocProvider(create: (_) => TaskidBloc()),
            BlocProvider(create: (_) => CandidatesBloc()..add(CandidatesList())),
            BlocProvider(
                create: (context) =>
                ChartBloc()..add(FetchChartData(startDate: "", endDate: ""))),
            BlocProvider(create: (_) => WorkspaceBloc()..add(WorkspaceList())),
            BlocProvider(create: (_) => MeetingBloc()),
            BlocProvider(create: (_) => NotificationBloc()),
            BlocProvider(create: (_) => NotificationPushBloc()),
            BlocProvider(create: (_) => TaskMediaBloc()),
            BlocProvider(create: (_) => ItemInvoiceBloc()),
            BlocProvider(create: (_) => TaskStatusTimelineBloc()),
            BlocProvider(create: (_) => UserProfileBloc()),
            BlocProvider(create: (_) => UseridBloc()),
            BlocProvider(create: (_) => EstimateInvoiceFilterCountBloc()),
            BlocProvider(create: (_) => PaymentMethodBloc()..add(PaymentMethdLists())),
            BlocProvider(create: (_) => TaxBloc()..add(TaxesList())),
            BlocProvider(
                create: (_) => ExpenseBloc()..add(ExpenseLists([], [], "", ""))),
            BlocProvider(
                create: (_) => PaymentBloc()
                  ..add(PaymentLists(
                      userIds: [],
                      invoiceIds: [],
                      paymentMethodIds: [],
                      fromDate: '',
                      toDate: ''))),
            BlocProvider(create: (_) => ExpenseTypeBloc()..add(ExpenseTypeLists())),
            BlocProvider(create: (_) => ProjectidBloc()),
            BlocProvider<FilterCountBloc>(create: (context) => FilterCountBloc()),
            BlocProvider(
                create: (_) => LeaveReqDashboardBloc()
                  ..add(WeekLeaveReqListDashboard([], 7, []))),
            BlocProvider(create: (_) => RoleBloc()),
            BlocProvider(create: (_) => ExpenseFilterCountBloc()),
            BlocProvider(create: (_) => RoleMultiBloc()),
            BlocProvider(create: (_) => TagsBloc()..add(TagsList())),
            BlocProvider(create: (_) => PermissionsBloc()),
            BlocProvider(create: (_) => SingleUserBloc()),
            BlocProvider(create: (_) => ClientBloc()..add(ClientList())),
            BlocProvider(create: (_) => FilterCountOfMilestoneBloc()),
            BlocProvider(create: (_) => BirthdayBloc()),
            BlocProvider(create: (_) => PaymentFilterCountBloc()),
            BlocProvider(create: (_) => DashBoardStatsBloc()),
            BlocProvider(create: (_) => SingleSelectProjectBloc()),
            BlocProvider(create: (_) => SettingsBloc()),
            BlocProvider(create: (_) => ItemsBloc()..add(ItemsList())),
            BlocProvider(create: (_) => UnitBloc()..add(UnitsList())),
            BlocProvider(create: (_) => ProjectMilestoneBloc()..add(MileStoneList())),
            BlocProvider(create: (_) => StatusMultiBloc()),
            BlocProvider(create: (_) => PriorityMultiBloc()),
            BlocProvider(create: (_) => TagMultiBloc()),
            BlocProvider(create: (_) => ProjectMultiBloc()),
            BlocProvider(create: (_) => ProjectMediaBloc()),
            BlocProvider(create: (_) => StatusTimelineBloc()),
            BlocProvider(create: (_) => PrivacyAboutusTermsCondBloc()),
            BlocProvider(create: (_) => CandidateAttachmentBloc()),
            BlocProvider(create: (_) => StatusBloc()..add(StatusList())),
            BlocProvider(create: (_) => InterviewsBloc()..add(InterviewsList())),
            BlocProvider(create: (_) => CandidateInterviewssBloc()),
            BlocProvider(create: (_) => LeadSourceBloc()),
            BlocProvider(create: (_) => LeadBloc()),
            BlocProvider(create: (_) => ContractBloc()..add(ContractList())),
            BlocProvider(create: (_) => ContractTypeBloc()..add(ContractTypeList())),
            BlocProvider(create: (_) => LeadStageBloc()..add(LeadStageLists())),
            BlocProvider(create: (_) => CustomFieldBloc()..add(CustomFieldLists())),
            BlocProvider(create: (_) => PriorityBloc()..add(PriorityLists())),
            BlocProvider(create: (_) => LeadIdBloc()),
            BlocProvider(create: (_) => AllowanceBloc()),
            BlocProvider(create: (_) => DeductionBloc()),
            BlocProvider(
                create: (_) => SingleAllowanceBloc()..add(SingleAllowanceList())),
            BlocProvider(
                create: (_) => SingleDeductionBloc()..add(SingleDeductionList())),
            BlocProvider(create: (_) => PayslipBloc()..add(AllPayslipList())),
            BlocProvider(create: (_) => SingleSelectProjectBloc()..add(SingleProjectList())),

            BlocProvider(create: (_) => CommentsBloc(discussionRepo: DiscussionRepo())),          ],



          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (themeState is DarkThemeState) {
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  ));
                } else {
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ));
                }
              });

              return BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, languageState) {
                  return ScreenUtilInit(
                    designSize: const Size(375, 812),
                    minTextAdapt: true,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: MaterialApp.router(
                          routerConfig: router,
                          locale: languageState.locale,
                          supportedLocales: AppLocalizations.supportedLocales,
                          localizationsDelegates: AppLocalizations.localizationsDelegates,

                          // localizationsDelegates: [
                          //   AppLocalizations.delegate,
                          //   CountryLocalizations.delegate,
                          //   GlobalMaterialLocalizations.delegate,
                          //   GlobalWidgetsLocalizations.delegate,
                          //   GlobalCupertinoLocalizations.delegate,
                          // ],
                          debugShowCheckedModeBanner: false,
                          theme: themeState is LightThemeState
                              ? ThemeData.light()
                              : ThemeData.dark(),
                          builder: (context, child) {
                            return BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, themeState) {
                                return Stack(
                                  children: [
                                    child!,
                                    if (_showLockScreen && defaultBiometric)
                                      Positioned.fill(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                          child: Container(
                                            color: (themeState is LightThemeState
                                                ? Colors.white
                                                : Colors.black)
                                                .withValues(alpha: 0.3),

                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}