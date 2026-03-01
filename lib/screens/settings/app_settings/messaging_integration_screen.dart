import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/colors.dart';
import '../../../config/internet_connectivity.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../widgets/side_bar.dart';
import '../slack.dart';
import '../sms_gateway.dart';
import '../whatsapp.dart';



class MessagingIntegrationScreen extends StatefulWidget {
  const MessagingIntegrationScreen({super.key});

  @override
  State<MessagingIntegrationScreen> createState() => _MessagingIntegrationScreenState();
}

class _MessagingIntegrationScreenState extends State<MessagingIntegrationScreen> with TickerProviderStateMixin{
  late TabController _tabController;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  TextEditingController baseUrlController = TextEditingController();
  String? selectedMethod;
  TextEditingController accountSidUrlController = TextEditingController();
  TextEditingController authTokenUrlController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final SlidableBarController sideBarController =
  SlidableBarController(initialStatus: false);
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
    _tabController.dispose();
  }
  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        setState(() {
          _connectionStatus = results;
        });

      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });

    _tabController = TabController(length: 3, vsync: this);

    // Listen for tab changes
    _tabController.addListener(() {
      setState(() {});
    });
    print("jkfehbsgkhgfes");
  }
  @override
  Widget build(BuildContext context) {

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return  _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(

        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: SideBar(
          context: context,
          controller: sideBarController,
          underWidget: Column(
            children: [
              // SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: BackArrow(
                  iSBackArrow: true,
                  title: AppLocalizations.of(context)!.messagingintegration,
                ),
              ),
              SizedBox(height: 20.h),

              _messagingTab(isLightTheme)
            ],
          ),
        ));
  }

  Widget _messagingTab(isLightTheme) {
    return Expanded(
      child: DefaultTabController(
        length: 3,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: TabBar(
                    controller: _tabController, // Attach TabController
                    unselectedLabelColor: Theme.of(context)
                        .colorScheme
                        .textClrChange, // Set unselected label color
                    // selectedLabelColor: Colors.blue, // Set selected label color
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    tabs: [
                      Tab(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          width: double.infinity,
                          child: Center(
                            child: CustomText(
                              text: AppLocalizations.of(context)!.smsgateway,
                              color: _tabController.index == 0
                                  ? AppColors.pureWhiteColor // Selected tab color
                                  : Theme.of(context)
                                  .colorScheme
                                  .textClrChange, // Default color for unselected
                              fontWeight: FontWeight.w700,
                              size: 15.sp,
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          width: double.infinity,
                          child: Center(
                            child: CustomText(
                              text: AppLocalizations.of(context)!.whatsapp,
                              color: _tabController.index == 1
                                  ? AppColors.pureWhiteColor // Selected tab color
                                  : Theme.of(context)
                                  .colorScheme
                                  .textClrChange, // Default color for unselected
                              fontWeight: FontWeight.w700,
                              size: 15.sp,
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          width: double.infinity,
                          child: Center(
                            child: CustomText(
                              text: AppLocalizations.of(context)!.slack,
                              color: _tabController.index == 2
                                  ? AppColors.pureWhiteColor // Selected tab color
                                  : Theme.of(context)
                                  .colorScheme
                                  .textClrChange, // Default color for unselected
                              fontWeight: FontWeight.w700,
                              size: 15.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController, // Attach TabController
                  children: [
                    SmsGateway(),
                    WhatsappScreen(),
                    SlackScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
