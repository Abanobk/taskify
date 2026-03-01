import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:taskify/screens/status/widgets/notes_shimmer_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/setting/settings_event.dart';
import '../../../bloc/setting/settings_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';
import '../../../data/GlobalVariable/globalvariable.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../utils/widgets/back_arrow.dart';
import '../../../utils/widgets/custom_switch.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  TextEditingController maxAttemptsController = TextEditingController();
  TextEditingController lockTimeController = TextEditingController();
  TextEditingController allowedMaxUploadSizeController =
      TextEditingController();
  TextEditingController maxFileAllowedController = TextEditingController();
  TextEditingController allowedFileTypesController = TextEditingController();

  bool? isSignUpVisible;
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }
  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    BlocProvider.of<SettingsBloc>(context).add(const SettingsList("general_settings"));

    super.initState();
  }

  void updateSecuritySettings(BuildContext context) {
    int? maxAttempt = int.tryParse(maxAttemptsController.text);
    int? lockTime = int.tryParse(lockTimeController.text);
    int? allowMaxUploadSize = int.tryParse(allowedMaxUploadSizeController.text);
    int? maxFilesAllowed = int.tryParse(maxFileAllowedController.text);
    if (maxAttempt == null || maxAttempt < 1 ||
        lockTime == null || lockTime < 1 ||
        allowMaxUploadSize == null || allowMaxUploadSize < 1 ||
        maxFilesAllowed == null || maxFilesAllowed < 1) {

      if (maxAttempt == null || maxAttempt < 1) {
        flutterToastCustom(msg: "Max Attempt must be at least 1", color: Colors.red);
        return;
      }

      if (lockTime == null || lockTime < 1) {
        flutterToastCustom(msg: "Lock Time must be at least 1", color: Colors.red);
        return;
      }

      if (allowMaxUploadSize == null || allowMaxUploadSize < 1) {
        flutterToastCustom(msg: "Allowed Max Upload Size must be at least 1", color: Colors.red);
        return;
      }

      if (maxFilesAllowed == null || maxFilesAllowed < 1) {
        flutterToastCustom(msg: "Max Files Allowed must be at least 1", color: Colors.red);
        return;
      }

      return; // Stop execution
    }

    print("sDZfjlcmfvj m ddf");
    context.read<SettingsBloc>().add(UpdateSettingsSecurity(
          maxAttempt: maxAttemptsController.text,
          lockTime: lockTimeController.text,
          allowMaxUploadSize: allowedMaxUploadSizeController.text,
          maxFilesAllowed: maxFileAllowedController.text,
          allowedFileType: allowedFileTypesController.text,
          isAllowedSignUP: isSignUpVisible == true ? "on" : "off",
        ));

    flutterToastCustom(
        msg: AppLocalizations.of(navigatorKey.currentContext!)!
            .updatedsuccessfully,
        color: AppColors.primary);
  }

  void _handleSignUpEnableDisable(
    bool status,
  ) {
    setState(() {
      // userId = id;
      isSignUpVisible = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  appbar(isLightTheme),
                  SizedBox(height: 30.h),
                  companyInfo(isLightTheme)
                ],
              ),
            ),
          );
  }

  Widget appbar(isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(boxShadow: [
                    isLightTheme
                        ? MyThemes.lightThemeShadow
                        : MyThemes.darkThemeShadow,
                  ]),
                  // color: Colors.red,
                  // width: 300.w,
                  child: BackArrow(
                    title: AppLocalizations.of(context)!.security,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget companyInfo(isLightTheme) {
    return BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
      if (state is SettingsSuccess) {
        context.read<SettingsBloc>().dateformat;
      }
    }, builder: (context, state) {
          print("slkgn;xgv $state");
      if (state is SettingsSuccess) {
        maxAttemptsController.text =
            context.read<SettingsBloc>().maxAttempts ?? "";
        lockTimeController.text = context.read<SettingsBloc>().lockTime ?? "";
        allowedMaxUploadSizeController.text =
            context.read<SettingsBloc>().maxAllowedUplaodSize ?? "";
        maxFileAllowedController.text =
            context.read<SettingsBloc>().maxFiles ?? "";
        allowedFileTypesController.text =
            context.read<SettingsBloc>().allowedFileTypes ?? "";
        isSignUpVisible =
            context.read<SettingsBloc>().allowSignup == 0 ? false : true;
        print("fjkndslgfzj,mvn ${context.read<SettingsBloc>().maxAttempts}");
        return Column(
          children: [
            SizedBox(
              height: 25.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                children: [
                  IsCustomSwitch(
                      isCreate: false,
                      status: isSignUpVisible,
                      onStatus: _handleSignUpEnableDisable),
                  SizedBox(
                    width: 20.w,
                  ),
                  CustomText(
                    text: AppLocalizations.of(context)!.enabledisablesignup,
                    fontWeight: FontWeight.w400,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20.w,
            ),
            CustomTextFields(
             keyboardType: TextInputType.number,
                title: AppLocalizations.of(context)!.maxattemots,
                hinttext: AppLocalizations.of(context)!.pleaseentermaxattempts,
                controller: maxAttemptsController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                keyboardType: TextInputType.number,
                title: AppLocalizations.of(context)!.locktime,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseenterlocktime,
                controller: lockTimeController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                keyboardType: TextInputType.number,
                title: AppLocalizations.of(context)!.maxupload,
                hinttext: AppLocalizations.of(context)!.pleaseenterallowedmaxuploadfiles,
                controller: allowedMaxUploadSizeController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                keyboardType: TextInputType.number,
                title: AppLocalizations.of(context)!.maxfilesallowed,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseentermaxfilesallowed,
                controller: maxFileAllowedController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(

                height: 112.h,
                title: AppLocalizations.of(context)!.allowedfiletypes,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseenterallowedfiletype,
                controller: allowedFileTypesController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 20.h,
            ),
            CreateCancelButtom(
              isCreate: false,
              isLoading: false,
              onpressCancel: () {
                Navigator.pop(context);
              },
              onpressCreate: true == false
                  ? () async {
                      // onCreateClient();
                    }
                  : () {
                      updateSecuritySettings(context);
                    },
            ),
            SizedBox(
              height: 100.h,
            ),
          ],
        );
      }
      if (state is UpdateSecuritySetting) {
        BlocProvider.of<SettingsBloc>(context).add(const SettingsList("general_settings"));
        Navigator.pop(context);
      }
      if (state is SecuritySettingsEditError) {
        BlocProvider.of<SettingsBloc>(context).add(const SettingsList("general_settings"));
      }
      if(state is SettingsLoading){
        return NotesShimmer(height: 45.h,title: true,);
      }
      return SizedBox();
    });
  }
}
