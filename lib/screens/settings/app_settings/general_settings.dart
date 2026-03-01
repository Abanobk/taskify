import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/screens/settings/app_settings/widgets/time_format.dart';
import 'package:taskify/screens/status/widgets/notes_shimmer_widget.dart';
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
import '../lists/static_list.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({super.key});

  @override
  State<AppSettingScreen> createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  TextEditingController titleController = TextEditingController();
  TextEditingController siteUrlController = TextEditingController();
  TextEditingController currencyfullformController = TextEditingController();
  TextEditingController currencySymbolController = TextEditingController();
  TextEditingController currencyCodeController = TextEditingController();
  TextEditingController currencyPositionController = TextEditingController();
  TextEditingController decimalPointsInCurrencyController =
      TextEditingController();
  TextEditingController decimalPointsInCurrency = TextEditingController();
  File? _image;
  File? _FullLogoImage;
  String _fullLogoPath = "";
  String _faviIconPath = "";
  File? _faviIConImage;
  String? filepath;
  String? currencyFormat;
  String? dateFormatName;
  String? timezoneFormatName;
  String? dateFormatKey;
  String? timezoneFormatKey;
  String? timeFormatName;
  String? currencySymbol;
  bool? isUpcomingBirthdayVisible;
  bool? isUpcomingAnniversaryVisible;
  bool? isUpcomingMemberOnLeaveVisible;
  String? currencyPosition;
  String? dateformatIn;
  String? comapanyTitle;
  String? currencyFullForm;
  String? currencyCode;
  String? timeZone;
  String? fullLogo;
  String? halfLogo;
  String? favicon;
  String? allowSignup;
  String? maxAllowedUplaodSize;
  String? maxAttempts;
  String? lockTime;
  String? allowedFileTypes;
  String? siteUrl;
  String? maxFiles;

  void _handleCurrencyFormatSelected(String category) {
    setState(() {
      currencyFormat = category;
    });
  }

  void _handleDateFormatSelected(String category, String key) {
    setState(() {
      dateFormatName = category;
      dateFormatKey = key;
    });
  }

  void _handleTimezoneFormatSelected(String region, String utc) {
    setState(() {
      timezoneFormatName = region;
      timezoneFormatKey = utc;
    });
  }

  void _handleTimeFormatSelected(String category, String catName) {
    print("gjkfxgsdlkfgnz $category");
    setState(() {
      timeFormatName = category;
    });
  }

  void _handleUpcomingBirthday(
    bool status,
  ) {
    setState(() {
      // userId = id;
      isUpcomingBirthdayVisible = status;
    });
  }

  void _handleUpcomingWorkAnniversary(
    bool status,
  ) {
    setState(() {
      // userId = id;
      isUpcomingAnniversaryVisible = status;
    });
  }

  void _handleMembersOnLeave(
    bool status,
  ) {
    setState(() {
      // userId = id;
      isUpcomingMemberOnLeaveVisible = status;
    });
  }

  void _handleCurrencySymbolSelected(String category) {
    print("fkdjfhsdfklesf $category");
    setState(() {
      currencySymbol = category;
    });
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
    getAllData();
    // BlocProvider.of<SettingsBloc>(context).add(const SettingsList(""));
    super.initState();
  }
getAllData(){
    print("FAVICON ${context.read<SettingsBloc>().favicon}");
  titleController.text = context.read<SettingsBloc>().comapanyTitle??"";
  siteUrlController.text = context.read<SettingsBloc>().siteUrl ?? "";
  currencyfullformController.text = context.read<SettingsBloc>().currencyFullForm ?? "";
  currencySymbolController.text = context.read<SettingsBloc>().currencySymbol ?? "";
  currencyCodeController.text = context.read<SettingsBloc>().currencyCode ?? "";
  currencyPosition = context.read<SettingsBloc>().currencyPosition ?? "Please select";
  currencyFormat = context.read<SettingsBloc>().currencyFormat ?? "Please select";
  decimalPointsInCurrencyController.text = context.read<SettingsBloc>().decimalPointsInCurrency ?? "";
  halfLogo = context.read<SettingsBloc>().halfLogo ?? "";
  fullLogo = context.read<SettingsBloc>().fullLogo ?? "";
  favicon = context.read<SettingsBloc>().favicon ?? "";
  dateformatIn = context.read<SettingsBloc>().dateformat ?? "";
  timezoneFormatName = context.read<SettingsBloc>().timeZone ?? "Please select";
  // Get the date format key from SettingsBloc
  String selectedDateFormat = context.read<SettingsBloc>().dateformat ?? "";
  String formattedDateFormat = dateFormat.firstWhere((element) => element.keys.first == selectedDateFormat,
    orElse: () => {selectedDateFormat: "Please select"},
  ).values.first;
  dateFormatName = formattedDateFormat;
  String selectedTimeFormat = context.read<SettingsBloc>().timeFormat ?? "";
  String formattedTimeFormat = timeFormat.firstWhere(
        (element) => element.keys.first == selectedTimeFormat,
    orElse: () => {selectedTimeFormat: "Please select"
    }, // Default case
  ).values.first;

  timeFormatName = formattedTimeFormat;
  isUpcomingBirthdayVisible =
  context.read<SettingsBloc>().upcomingBirthdays == 0 ? false : true;
  isUpcomingAnniversaryVisible = context.read<SettingsBloc>().upcomingAnniversary == 0 ? false : true;
  isUpcomingMemberOnLeaveVisible = context.read<SettingsBloc>().membersOnLeave == 0 ? false : true;
}
  void _onUpdateGeneralSetting(BuildContext context) {
    if (titleController.text.isNotEmpty && siteUrlController.text.isNotEmpty && currencyfullformController.text.isNotEmpty && currencySymbolController.text.isNotEmpty && timezoneFormatName!.isNotEmpty && dateFormatName!.isNotEmpty) {
   print("jgnrjg $_FullLogoImage");
      context.read<SettingsBloc>().add(UpdateGeneralSettings(
            title: titleController.text,
            siteUrl: siteUrlController.text,
            fullLogo: _FullLogoImage,
            favicon: _faviIConImage,
            timezone: timezoneFormatName,
            currencyFullForm: currencyfullformController.text,
            currencyCode: currencyCodeController.text,
            currencySymbol: currencySymbolController.text,
            currencySymbolPosition: currencyPosition,
            currencyFormat: currencyFormat,
            decimalPoints: decimalPointsInCurrencyController.text,
            dateFormat: dateformatIn,
            timeFormat: timeFormatName,
            birthdaySec: isUpcomingBirthdayVisible == true ? 1 : 0,
            workAnniversarySec: isUpcomingAnniversaryVisible == true ? 1 : 0,
            leaveReqSec: isUpcomingMemberOnLeaveVisible == true ? 1 : 0,
          ));

    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  Future<void> _pickImage({required String from}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        filepath = pickedFile.name;
        _image = File(pickedFile.path);
        if (from == "Full logo") {
          _fullLogoPath = pickedFile.path;
          _FullLogoImage = File(pickedFile.path);
        }
        if (from == "Favicon") {
          _faviIconPath = pickedFile.path;
          _faviIConImage = File(pickedFile.path);
        }
      });
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
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
                  settingBody(isLightTheme)
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
                    title: AppLocalizations.of(context)!.generalsetting,
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget settingBody(isLightTheme) {
    return BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
      if (state is SettingsSuccess) {
      }
    }, builder: (context, state) {
          print("cfghh $state");
      if (state is SettingsSuccess) {
        return Column(
          children: [
            CustomTextFields(
                title: AppLocalizations.of(context)!.companytitle,
                hinttext: AppLocalizations.of(context)!.pleaseentertitle,
                controller: titleController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.siteurl,
                subtitle: AppLocalizations.of(context)!.site,
                hinttext: AppLocalizations.of(context)!.pleaseentercompanysiteurl,
                controller: siteUrlController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            logoIconField(isLightTheme, true, fullLogo, "Full logo"),
            SizedBox(
              height: 15.h,
            ),
            logoIconField(isLightTheme, false, favicon, "Favicon"),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.currencyfullform,
                hinttext: AppLocalizations.of(context)!.pleaseentercompanycurrencyfullform,
                controller: currencyfullformController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.currencysymbol,
                subtitle: "",
                hinttext:AppLocalizations.of(context)!.pleaseentercompanycurrencysymbol,
                controller: currencySymbolController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.currencycode,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseentercompanycurrencycode,
                controller: currencyCodeController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CurrencyFormatField(
              onSelectedTimeZoneFormatChange: (String category, String ab) {},
              title: "currencySymbol",
              access: "widget.access",
              isRequired: false,
              isCreate: false,
              name: currencyPosition ?? "",
              onSelectedSymbol: _handleCurrencySymbolSelected,
              onSelectedDateFormat: (String category, String key) {},
              onSelectedTimeFormatChange: (String category, String catkey) {},
              onSelectedFormated: (String category) {},
            ),
            SizedBox(
              height: 15.h,
            ),
            CurrencyFormatField(
              onSelectedTimeZoneFormatChange: (String category, String ab) {},
              title: "currencyFormat",
              access: "widget.access",
              onSelectedFormated: _handleCurrencyFormatSelected,
              isRequired: false,
              isCreate: false,
              name: currencyFormat ?? "",
              onSelectedSymbol: (String category) {},
              onSelectedDateFormat: (String category, String key) {},
              onSelectedTimeFormatChange: (String category, String catkey) {},
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.uptodecimal,
                hinttext: AppLocalizations.of(context)!.pleaseenterdecimalpoints,
                controller: decimalPointsInCurrencyController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {
                  // _fieldFocusChange(
                  //   context,
                  //   firstnameFocus!,
                  //   lastnameFocus,
                  // );
                },
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CurrencyFormatField(
                subtitle: "",
                title: "systemTimezone",
                access: "widget.access",
                onSelectedFormated: (String category) {},
                onSelectedSymbol: (String category) {},
                onSelectedTimeFormatChange: (String category, String catkey) {},
                isRequired: true,
                isCreate: false,
                name: timezoneFormatName ?? "",
                onSelectedDateFormat: (String category, String ab) {},
                onSelectedTimeZoneFormatChange: _handleTimezoneFormatSelected),
            SizedBox(
              height: 15.h,
            ),
            CurrencyFormatField(
              onSelectedTimeZoneFormatChange: (String category, String ab) {},
              subtitle: AppLocalizations.of(context)!.datesystemwide,
              title: "dateFormat",
              access: "widget.access",
              onSelectedFormated: (String category) {},
              onSelectedSymbol: (String category) {},
              onSelectedTimeFormatChange: (String category, String catkey) {},
              isRequired: true,
              isCreate: false,
              name: dateFormatName ?? "",
              onSelectedDateFormat: _handleDateFormatSelected,
            ),
            SizedBox(
              height: 15.h,
            ),
            CurrencyFormatField(
              onSelectedTimeZoneFormatChange: (String category, String ab) {},
              subtitle: AppLocalizations.of(context)!.timesystemwide,
              title: "timeFormat",
              access: "widget.access",
              onSelectedFormated: (String category) {},
              onSelectedSymbol: (String category) {},
              onSelectedTimeFormatChange: _handleTimeFormatSelected,
              isRequired: false,
              isCreate: false,
              name: timeFormatName ?? "",
              onSelectedDateFormat: (String category, String key) {},
            ),
            SizedBox(
              height: 25.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                children: [
                  IsCustomSwitch(
                      isCreate: false,
                      status: isUpcomingBirthdayVisible,
                      onStatus: _handleUpcomingBirthday),
                  SizedBox(
                    width: 20.w,
                  ),
                  CustomText(
                    text: AppLocalizations.of(context)!.upcomingbirthdaysection,
                    fontWeight: FontWeight.w400,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                children: [
                  IsCustomSwitch(
                      isCreate: false,
                      status: isUpcomingAnniversaryVisible,
                      onStatus: _handleUpcomingWorkAnniversary),
                  SizedBox(
                    width: 20.w,
                  ),
                  CustomText(
                    text: AppLocalizations.of(context)!.upcomingworkannisection,
                    fontWeight: FontWeight.w400,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                children: [
                  IsCustomSwitch(
                      isCreate: false,
                      status: isUpcomingMemberOnLeaveVisible,
                      onStatus: _handleMembersOnLeave),
                  SizedBox(
                    width: 20.w,
                  ),
                  CustomText(
                    text: AppLocalizations.of(context)!.membersonleavesection,
                    fontWeight: FontWeight.w400,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  )
                ],
              ),
            ),
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
                      _onUpdateGeneralSetting(context);
                    },
            ),
            SizedBox(
              height: 100.h,
            ),
          ],
        );
      }
      if(state is UpdateGeneralSetting){
        flutterToastCustom(
            msg: AppLocalizations.of(navigatorKey.currentContext!)!
                .updatedsuccessfully,
            color: AppColors.primary);
        BlocProvider.of<SettingsBloc>(context).add(const SettingsList("general_settings"));

      }
      if(state is SettingsLoading){
        return NotesShimmer(height: 45.h,title: true,);
      }
      if (state is GeneralSettingsEditError) {
        BlocProvider.of<SettingsBloc>(context).add(const SettingsList("general_settings"));
      }
      if (state is UpdateGeneralSetting) {
        BlocProvider.of<SettingsBloc>(context).add(const SettingsList("general_settings"));
      }
      return SizedBox();
    });
  }

  Widget logoIconField(isLightTheme, logo, image, isFrom) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text: logo
                    ? AppLocalizations.of(context)!.fulllogo
                    : AppLocalizations.of(context)!.favicon,
                // text: getTranslated(context, 'myweeklyTask'),

                size: 16.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                color: Theme.of(context).colorScheme.textClrChange,


                fontWeight: FontWeight.w700,
              ),
              SizedBox(
                width: 5.h,
              ),
              InkWell(
                onTap: () {
                  logo
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5.0,
                              backgroundColor: Colors.white,
                              child: Container(
                                  height: 300.h,
                                  width: 300.w,
                                  padding: EdgeInsets.all(0.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    // shape: BoxShape.circle,
                                    //   color: Theme.of(context).colorScheme.backGroundColor,
                                    image: DecorationImage(
                                        image: NetworkImage(image),
                                        fit: BoxFit.contain),
                                  )),
                            );
                          },
                        )
                      : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 5.0,
                              backgroundColor: Colors.white,
                              child: Container(
                                  height: 300.h,
                                  width: 300.w,
                                  padding: EdgeInsets.all(0.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    // shape: BoxShape.circle,
                                    //   color: Theme.of(context).colorScheme.backGroundColor,
                                    image: DecorationImage(
                                        image: NetworkImage(image),
                                        fit: BoxFit.contain),
                                  )),
                            );
                          },
                        );
                },
                child: Icon(
                  Icons.visibility,
                  color: AppColors.primary,
                  size: 15.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
            // padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 40.h,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              // color: Colors.red,
              border: Border.all(color: AppColors.greyColor),
              borderRadius: BorderRadius.circular(12),
            ),
            // decoration: DesignConfiguration.shadow(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  InkWell(
                    highlightColor: Colors.transparent, // No highlight on tap
                    splashColor: Colors.transparent,
                    onTap: () {
                      _pickImage(from: isFrom);
                    },
                    child: _image == null
                        ? CustomText(
                            text: AppLocalizations.of(context)!.choosefile,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          )
                        : CustomText(
                            text: AppLocalizations.of(context)!.choosefile,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Container(
                    color: AppColors.greyForgetColor,
                    // color: colors.red,
                    height: 40.h,
                    width: 0.5.w,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  isFrom == "Full logo"
                      ? SizedBox(
                          width: 200.w,
                          child: CustomText(
                            text: _fullLogoPath.isEmpty
                                ? AppLocalizations.of(context)!.nofilechosen
                                : _fullLogoPath,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : SizedBox(
                          width: 200.w,
                          child: CustomText(
                            text: _faviIconPath.isEmpty
                                ? AppLocalizations.of(context)!.nofilechosen
                                : _faviIconPath,
                            fontWeight: FontWeight.w400,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                ],
              ),
            )),
      ],
    );
  }
}
