import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:taskify/screens/settings/setting_screen.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../config/internet_connectivity.dart';
import '../../config/strings.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import '../home_screen/home_screen.dart';
import '../task/all_task_from_dash_screen.dart';
import '../Project/project_from_dashboard.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'bottomNavWidget.dart';

class DashBoard extends StatefulWidget {
  final int initialIndex;
  const DashBoard({super.key, this.initialIndex = 0});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  late TabController _tabController;
  String? workSpaceTitle;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Future<void> getWorkspace() async {
    var box = await Hive.openBox(userBox);
    workSpaceTitle = box.get('workspace_title');
    if (mounted) {
      BlocProvider.of<AuthBloc>(context)
          .add(WorkspaceUpdate(workspaceTitle: workSpaceTitle));
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _selectedIndex = widget.initialIndex;
    getWorkspace();
    _initializeTabController();
  }

  void _initializeConnectivity() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (mounted && results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (mounted) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
  }

  void _initializeTabController() {
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: _selectedIndex,
    );

    _tabController.addListener(() {
      Future.delayed(const Duration(microseconds: 10)).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = _tabController.index;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  final List<Widget> _widgetOptions = [
    const HomeScreen(),
    const ProjectScreen(),
    const AllTaskScreen(),
    const Settingscreen(),
  ];

  Future<bool?> _onWillPop() async {
    if (_selectedIndex == 0) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
          title: Text(AppLocalizations.of(context)!.exitApp),
          content: Text(AppLocalizations.of(context)!.doyouwanttoexitApp),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        ),
      );

      if (shouldExit ?? false) {
        SystemNavigator.pop();
        return true;
      }
      return false;
    } else {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    final isLightTheme = currentTheme is LightThemeState;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: _connectionStatus.contains(ConnectivityResult.none)
            ? const NoInternetScreen()
            : Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
        bottomNavigationBar: _getBottomBar(isLightTheme),
      ),
    );
  }

  Widget _getBottomBar(bool isLightTheme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40.4, sigmaY: 83.4),
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                icon: HeroIcons.home,
                index: 0,
                isLightTheme: isLightTheme,
              ),
              _buildNavButton(
                icon: HeroIcons.wallet,
                index: 1,
                isLightTheme: isLightTheme,
              ),
              _buildNavButton(
                icon: HeroIcons.documentCheck,
                index: 2,
                isLightTheme: isLightTheme,
              ),
              _buildNavButton(
                icon: HeroIcons.cog8Tooth,
                index: 3,
                isLightTheme: isLightTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required HeroIcons icon,
    required int index,
    required bool isLightTheme,
  }) {
    return GlowIconButton(
      icon: icon,
      isSelected: _selectedIndex == index,
      glowColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.textClrChange,
      unselectedColor: AppColors.greyForgetColor,
      onTap: () => _navigateToIndex(index),
    );
  }
}
