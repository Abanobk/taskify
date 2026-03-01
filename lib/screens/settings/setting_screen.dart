import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../src/generated/i18n/app_localizations.dart';import 'package:heroicons/heroicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/widgets/custom_container.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/languages/language_switcher_event.dart';
import '../../bloc/project_filter/project_filter_bloc.dart';
import '../../bloc/project_filter/project_filter_event.dart';
import '../../bloc/task_filter/task_filter_bloc.dart';
import '../../bloc/task_filter/task_filter_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user_profile/user_profile_bloc.dart';
import '../../bloc/user_profile/user_profile_event.dart';
import '../../bloc/user_profile/user_profile_state.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_switch.dart';
import '../../utils/widgets/back_arrow.dart';


class Settingscreen extends StatefulWidget {
  const Settingscreen({super.key});

  @override
  State<Settingscreen> createState() => _SettingscreenState();
}

class _SettingscreenState extends State<Settingscreen> {
  String? photoWidget;
  String? firstNameWidget;
  String? changedFirst;
  int? id;
  String? lastNameWidget;
  String? changedLast;
  String? selectedRoleName;
  String? genderWidget;
  String? emailWidget;
  String? changedEmail;
  String? getLanguageCurrent;
  bool isRtl = false;
  bool? isBiometricActiveIn = false;
  String? roleInWidget;
  Future<String> getLang() async {
    final hiveStorage = HiveStorage();
    getLanguageCurrent = await hiveStorage.getLanguage();


    return getLanguageCurrent ?? defaultLanguage;
  }
  Future<bool> getBiometric() async {

    isBiometricActiveIn = await HiveStorage.getBiometricAuth();

    print( " uhnjmas  $isBiometricActiveIn");

    return isBiometricActiveIn!;
  }
  Future<void> _checkRtlLanguage() async {
    final languageCode = await HiveStorage().getLanguage();
    setState(() {
      isRtl = LanguageBloc.instance.isRtlLanguage(languageCode ?? defaultLanguage);

    });
  }
  @override
  void initState() {
    getBiometric();
    photoWidget = context.read<UserProfileBloc>().profilePic;
    context.read<UserProfileBloc>().add(ProfileListGet());
    context.read<FilterCountBloc>().add(ProjectResetFilterCount());
    context.read<TaskFilterCountBloc>().add(TaskResetFilterCount());
    _checkRtlLanguage();

    _getRole();
    super.initState();
  }
  String? role ;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkRtlLanguage();
  }
  Future<void> _getRole() async {
    role = await HiveStorage.getRole();
    print("fhDZFKh ${role.runtimeType}");
  }
  void _handleIsBiometricActive(
      bool status,
      )async {
    setState(() {
      isBiometricActiveIn = status;
    });
  await  HiveStorage.setBiometricAuth(status);
   var defaultBiometric = await HiveStorage.getBiometricAuth();
   print("defaultBiometric in Settings $defaultBiometric");

  }
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body:
          profileDetails(isLightTheme),

    );
  }

  Widget profileDetails(isLightTheme) {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {

      if (state is UserProfileSuccess) {
        for (var data in state.profile) {
          id = data.id;
          firstNameWidget = data.firstName ?? "First Name";
          lastNameWidget = data.lastName ?? "LastName";
          emailWidget = data.email ?? "Email";
          roleInWidget = data.role ?? "Role";
          photoWidget = data.profile ?? "Photo";
          selectedRoleName = data.role ?? "Role";
        }
      }
      if (state is UserProfileLoading) {
        // return SettingScreenShimmer(isLightTheme);
      }
      else if (state is UserProfileError) {}
    },
        builder: (context, state) {
print("gfhjgkzjhgk $state");
print("gfhjgkzjhgk $role");
      if (state is UserProfileLoading) {
        return   SingleChildScrollView(
          child: Column(
            children: [
             customContainer(
            context: context,
            height: 320.h,
            addWidget: Padding(
              padding: EdgeInsets.only(top: 0.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: BackArrow(
                      iSBackArrow: true,
                      fromDash: true,
                      title: AppLocalizations.of(context)!.settings,
                    ),
                  ),
                  // SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30.h,
                        ),
                    GlowContainer(
                      shape: BoxShape.circle,
                      glowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 10,
                      child:CircleAvatar(
                            radius: 52.r,
                            backgroundColor:
                            Theme.of(context).colorScheme.textFieldColor,
                            child: CircleAvatar(
                              backgroundColor:
                              Theme.of(context).colorScheme.containerDark,
                              radius: 50.r,
                              child: SizedBox(
                                height: 50.h,
                                width: double.infinity,
                                child: Center(
                                  child: SpinKitFadingCircle(
                                    color: AppColors.primary,
                                    size: 40.0,
                                  ),
                                ),
                              ),
                              // backgroundImage: NetworkImage(photoWidget!),
                            ))),
                        SizedBox(
                          height: 15.w,
                        ),
                        firstNameWidget != null && lastNameWidget!= null?  CustomText(
                          text: "$firstNameWidget $lastNameWidget",
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 16.sp,
                          fontWeight: FontWeight.w700,
                        ):CustomText(
                          text: "",
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        // SizedBox(height: 5.h,),
                        CustomText(
                          text: "",
                          // text: getTranslated(context, 'myweeklyTask'),
                          color: AppColors.greyColor,
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        selectedRoleName != null
                            ? Container(
                          alignment: Alignment.center,
                          height: 25.h,
                          width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors
                                  .purple), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 0.5),
                                child: CustomText(
                                  text: selectedRoleName!,
                                  color: AppColors.whiteColor,
                                  size: 16.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        )
                            : Container(
                          alignment: Alignment.center,
                          height: 25.h,
                          width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors
                                  .purple), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 0.5),
                                child: CustomText(
                                  text: "",
                                  color: AppColors.whiteColor,
                                  size: 16.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
          
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
              _account(isLightTheme),
              _privacyAndSecurity(),
              role == "admin"  ? _appSetting() : SizedBox(),

            _logoutAndSetting()
            ],
          ),
        );
      }
      if (state is UserProfileSuccess) {
        id = context.read<UserProfileBloc>().userId;
        firstNameWidget =
            context.read<UserProfileBloc>().firstname ?? "First Name";
        lastNameWidget = context.read<UserProfileBloc>().lastName ?? "LastName";
        emailWidget = context.read<UserProfileBloc>().email ?? "Email";
        roleInWidget = (context.read<UserProfileBloc>().roleId is String)
            ? context.read<UserProfileBloc>().roleId as String
            : "Role";

        photoWidget = context.read<UserProfileBloc>().profilePic ?? "Photo";
        selectedRoleName = context.read<UserProfileBloc>().role ?? "Role";

        return  LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Force always scrollable even if content doesn't exceed screen
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                constraints: BoxConstraints(
                // This ensures the content takes at least the full screen height
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
              child: Column(
                    children: [
          profileInfo(photoWidget, lastNameWidget, firstNameWidget,
              emailWidget, selectedRoleName),
          _account(isLightTheme),
          _privacyAndSecurity(),
                      role == "admin"  ? _appSetting() : SizedBox(),
                      SizedBox(
                        height: 30.h,
                      ),
          _logoutAndSetting(),
                      SizedBox(height: 100.h,)
                    ],
                  ),
        )));});
      }
      return SizedBox();

    });
  }

  void showLanguageDialog(BuildContext context) {
    String? selectedLanguage =
        context.read<LanguageBloc>().state.locale.languageCode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.r), // Set the desired radius here
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                  HiveStorage().storeLanguage(selectedLanguage!);
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

  Widget profileInfo(photoWidget, lastNameWidget, firstNameWidget, emailWidget,
      selectedRoleName) {

    return customContainer(
      context: context,
      // height: 320.h,
      addWidget: Padding(
        padding: EdgeInsets.only(top: 0.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: BackArrow(
                iSBackArrow: true,
                fromDash: true,
                title: AppLocalizations.of(context)!.settings,
              ),
            ),
            // SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
              InkWell(
                onLongPress: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 5.0,
                        // backgroundColor: Colors.white,
                        child: Container(
                            height: 300.h,
                            width: 300.w,
                            padding: EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // shape: BoxShape.circle,
                              //   color: Theme.of(context).colorScheme.backGroundColor,
                              image: DecorationImage(
                                  image: NetworkImage(photoWidget),
                                  fit: BoxFit.cover),
                            )),
                      );
                    },
                  );
                },
                child: GlowContainer(
                  shape: BoxShape.circle,
                  glowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 10,
                  child:  CircleAvatar(
                        radius: 52.r,
                        backgroundColor:
                            Theme.of(context).colorScheme.textFieldColor,
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.containerDark,
                          radius: 51.r,
                          backgroundImage: NetworkImage(photoWidget!),
                        ))),
              ),
                  SizedBox(
                    height: 15.w,
                  ),
                  firstNameWidget != null && lastNameWidget!= null?   CustomText(
                    text: "$firstNameWidget $lastNameWidget",
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 16.sp,
                    fontWeight: FontWeight.w700,
                  ):CustomText(
                    text: "",
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  // SizedBox(height: 5.h,),
                  emailWidget != null ?  CustomText(
                    text: emailWidget,
                    // text: getTranslated(context, 'myweeklyTask'),
                    color: AppColors.greyColor,
                    size: 14.sp,
                    fontWeight: FontWeight.w500,
                  ): CustomText(
                    text: "",
                    // text: getTranslated(context, 'myweeklyTask'),
                    color: AppColors.greyColor,
                    size: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  selectedRoleName != null
                      ? Container(
                          alignment: Alignment.center,
                          height: 25.h,
                          width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors
                                  .primary), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.5),
                                child: CustomText(
                                  text: selectedRoleName!,
                                  color: AppColors.whiteColor,
                                  size: 16.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          height: 25.h,
                          width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors
                                  .primary), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.5),
                                child: CustomText(
                                  text: "",
                                  color: AppColors.whiteColor,
                                  size: 16.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                  SizedBox(
                    height: 15.h,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _account(isLightTheme) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            // isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    text: AppLocalizations.of(context)!.accounts,
                    // text: getTranslated(context, 'myweeklyTask'),
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.textClrChange,
                    thickness: 0.1,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  InkWell(
                    onTap: () {
                      router.push("/profile");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            HeroIcon(
                              HeroIcons.userCircle,
                              style: HeroIconStyle.outline,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            CustomText(
                              text: AppLocalizations.of(context)!.accounts,
                              // text: getTranslated(context, 'myweeklyTask'),
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                              size: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                        isRtl
                            ? HeroIcon(
                                HeroIcons.chevronLeft,
                                style: HeroIconStyle.outline,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              )
                            : HeroIcon(
                                HeroIcons.chevronRight,
                                style: HeroIconStyle.outline,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      showLanguageDialog(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            HeroIcon(
                              HeroIcons.language,
                              style: HeroIconStyle.outline,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            CustomText(
                              text: AppLocalizations.of(context)!.language,
                              // text: getTranslated(context, 'myweeklyTask'),
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                              size: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                        isRtl
                            ? HeroIcon(
                          HeroIcons.chevronLeft,
                          style: HeroIconStyle.outline,
                          color:
                          Theme.of(context).colorScheme.textClrChange,
                        )
                            : HeroIcon(
                          HeroIcons.chevronRight,
                          style: HeroIconStyle.outline,
                          color:
                          Theme.of(context).colorScheme.textClrChange,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                      // Change to dark theme
                      ThemeSwitcher.of(context).changeTheme(
                          theme: isDarkTheme == true
                              ? ThemeData.dark()
                              : ThemeData.light(),
                          isReversed: isDarkTheme == true ? true : false);
                      isDarkTheme == true
                          ? SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle.dark)
                          : SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle.light);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            HeroIcon(
                              HeroIcons.sun,
                              style: HeroIconStyle.outline,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            CustomText(
                              text: AppLocalizations.of(context)!.theme,
                              // text: getTranslated(context, 'myweeklyTask'),
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                              size: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                        BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, themeState) {
                            return Container(
                              height: 30, // Adjust as needed
                              width: 30,
                              alignment: Alignment.center,
                              // color: Colors.red,
                              child: ThemeSwitcher(
                                clipper: const ThemeSwitcherCircleClipper(),
                                builder: (context) {
                                  bool isDarkTheme =
                                      Theme.of(context).brightness ==
                                          Brightness.dark;
                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    alignment: Alignment.center,
                                    icon: Icon(
                                      themeState is DarkThemeState
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      size: 25,
                                      color: themeState is DarkThemeState
                                          ? Colors.yellow
                                          : Colors.blue,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<ThemeBloc>()
                                          .add(ToggleThemeEvent());
                                      // Change to dark theme
                                      ThemeSwitcher.of(context).changeTheme(
                                          theme: isDarkTheme == true
                                              ? ThemeData.dark()
                                              : ThemeData.light(),
                                          isReversed: isDarkTheme == true
                                              ? true
                                              : false);
                                      isDarkTheme == true
                                          ? SystemChrome
                                              .setSystemUIOverlayStyle(
                                                  SystemUiOverlayStyle.dark)
                                          : SystemChrome
                                              .setSystemUIOverlayStyle(
                                                  SystemUiOverlayStyle.light);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          HeroIcon(
                            HeroIcons.fingerPrint,
                            style: HeroIconStyle.outline,
                            color:
                            Theme.of(context).colorScheme.textClrChange,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          CustomText(
                            text: AppLocalizations.of(context)!.biometricactive,
                            // text: getTranslated(context, 'myweeklyTask'),
                            color:
                            Theme.of(context).colorScheme.textClrChange,
                            size: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                      IsCustomSwitch(
                          isCreate: false,
                          status: isBiometricActiveIn,
                          onStatus: _handleIsBiometricActive),
                    ],
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacyAndSecurity() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.privacyandsecurity,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 20,
                fontWeight: FontWeight.w700,
              ),
              Divider(
                color: Theme.of(context).colorScheme.textClrChange,
                thickness: 0.1,
              ),
              SizedBox(
                height: 10.h,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  router.push('/privacy', extra: {
                    "title": AppLocalizations.of(context)!.privacypolicy,

                    // "index": index,
                    // 'project': state.Project,
                    // "users": state.Project[index].users,
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        HeroIcon(
                          HeroIcons.shieldCheck,
                          style: HeroIconStyle.outline,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        CustomText(
                          text: AppLocalizations.of(context)!.privacypolicy,
                          // text: getTranslated(context, 'myweeklyTask'),
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                    isRtl
                        ? HeroIcon(
                      HeroIcons.chevronLeft,
                      style: HeroIconStyle.outline,
                      color:
                      Theme.of(context).colorScheme.textClrChange,
                    )
                        : HeroIcon(
                      HeroIcons.chevronRight,
                      style: HeroIconStyle.outline,
                      color:
                      Theme.of(context).colorScheme.textClrChange,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  router.push(
                    '/aboutUs',
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        HeroIcon(
                          HeroIcons.informationCircle,
                          style: HeroIconStyle.outline,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        CustomText(
                          text: AppLocalizations.of(context)!.aboutus,
                          // text: getTranslated(context, 'myweeklyTask'),
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                    isRtl
                        ? HeroIcon(
                      HeroIcons.chevronLeft,
                      style: HeroIconStyle.outline,
                      color:
                      Theme.of(context).colorScheme.textClrChange,
                    )
                        : HeroIcon(
                      HeroIcons.chevronRight,
                      style: HeroIconStyle.outline,
                      color:
                      Theme.of(context).colorScheme.textClrChange,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  router.push(
                    '/termsconditions',
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        HeroIcon(
                          HeroIcons.document,
                          style: HeroIconStyle.outline,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        CustomText(
                          text:
                              AppLocalizations.of(context)!.termsandconditions,
                          // text: getTranslated(context, 'myweeklyTask'),
                          color: Theme.of(context).colorScheme.textClrChange,
                          size: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                    isRtl
                        ? HeroIcon(
                      HeroIcons.chevronLeft,
                      style: HeroIconStyle.outline,
                      color:
                      Theme.of(context).colorScheme.textClrChange,
                    )
                        : HeroIcon(
                      HeroIcons.chevronRight,
                      style: HeroIconStyle.outline,
                      color:
                      Theme.of(context).colorScheme.textClrChange,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),

        ],
      ),
    );
  }
  Widget _appSetting(){
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal:18.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            height: 10.h,
          ),
          CustomText(
            text: AppLocalizations.of(context)!.appsettings,
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 20,
            fontWeight: FontWeight.w700,
          ),
          Divider(
            color: Theme.of(context).colorScheme.textClrChange,
            thickness: 0.1,
          ),
          SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/appSetting',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.cog,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.generalsetting,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/companyInfo',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.documentChartBar,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.comapnyinfo,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ), SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/customfields',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.cube,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.customfields,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ), SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/security',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.lockClosed,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.security,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/updateRolePermission',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.lockOpen,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.permissions,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/emailSetting',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.envelope,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.companyemail,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/messagingintegration',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.chatBubbleBottomCenterText,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.messagingintegration,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ), SizedBox(
            height: 10.h,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              router.push(
                '/mediastorage',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HeroIcon(
                      HeroIcons.swatch,
                      style: HeroIconStyle.outline,
                      color: Theme.of(context).colorScheme.textClrChange,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    CustomText(
                      text:
                      AppLocalizations.of(context)!.mediastorage,
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: Theme.of(context).colorScheme.textClrChange,
                      size: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                isRtl
                    ? HeroIcon(
                  HeroIcons.chevronLeft,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                )
                    : HeroIcon(
                  HeroIcons.chevronRight,
                  style: HeroIconStyle.outline,
                  color:
                  Theme.of(context).colorScheme.textClrChange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutAndSetting() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          BlocProvider.of<AuthBloc>(context).add(LoggedOut(
            context: context,
          ));
          router.replace('/login');
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primary),
          height: 30.h,
          width: 110.w,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeroIcon(
                HeroIcons.arrowLeftStartOnRectangle,
                style: HeroIconStyle.outline,
                color: AppColors.pureWhiteColor,
                size: 15,
              ),
              SizedBox(
                width: 5.h,
              ),
              CustomText(
                text: AppLocalizations.of(context)!.logout,
                // text: getTranslated(context, 'myweeklyTask'),
                color: AppColors.pureWhiteColor,
                size: 13,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
