import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import 'package:taskify/screens/status/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({super.key});

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController VATNumberController = TextEditingController();

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
    BlocProvider.of<SettingsBloc>(context)
        .add(const SettingsList("company_information"));
    super.initState();
  }
  @override
  void dispose(){
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void onUpdateCompanyInfoSetting(BuildContext context) {
    if (emailController.text.isEmpty &&
        phoneNumberController.text.isEmpty &&
        addressController.text.isEmpty &&
        cityController.text.isEmpty &&
        stateController.text.isEmpty &&
        VATNumberController.text.isEmpty &&
        countryController.text.isEmpty &&
        zipCodeController.text.isEmpty) {
      flutterToastCustom(msg: AppLocalizations.of(context)!.pleasefilldetails,color: AppColors.primary);

      return;
    }
    String email = emailController.text.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      flutterToastCustom(msg: AppLocalizations.of(context)!.emaildoesntcontain);
      return; // Stop further execution
    }

    context.read<SettingsBloc>().add(UpdateSettingsCompanyInfo(
        companyEmail: emailController.text,
        companyPhone: phoneNumberController.text,
        companyAddress: addressController.text,
        companyCity: cityController.text,
        companyState: stateController.text,
        companyCountry: countryController.text,
        companyZip: zipCodeController.text,
        companyVat: VATNumberController.text));
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
                    title: AppLocalizations.of(context)!.comapnyinfo,
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
      print("kjeshGN $state");
      if (state is SettingsSuccess) {
        emailController.text = context.read<SettingsBloc>().email ?? "";
        phoneNumberController.text = context.read<SettingsBloc>().phone ?? "";
        addressController.text = context.read<SettingsBloc>().address ?? "";
        cityController.text = context.read<SettingsBloc>().city ?? "";
        stateController.text =
            context.read<SettingsBloc>().stateOfComapny ?? "";
        countryController.text = context.read<SettingsBloc>().country ?? "";
        zipCodeController.text = context.read<SettingsBloc>().zipcode ?? "";
        websiteController.text = context.read<SettingsBloc>().website ?? "";
        VATNumberController.text = context.read<SettingsBloc>().vatNumber ?? "";
        return Column(
          children: [
            CustomTextFields(
                title: AppLocalizations.of(context)!.email,
                hinttext: AppLocalizations.of(context)!.pleaseentercompanyemail,
                controller: emailController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.phonenumber,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseentercompanyphone,
                controller: phoneNumberController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.address,
                hinttext:
                    AppLocalizations.of(context)!.pleaseentercompanyaddress,
                controller: addressController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.city,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseentercompanycity,
                controller: cityController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.state,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseentercompanystate,
                controller: stateController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.country,
                hinttext:
                    AppLocalizations.of(context)!.pleaseentercompanycountry,
                controller: countryController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {
                  // _fieldFocusChange(
                  //   context,
                  //   firstnameFocus!,
                  //   lastnameFocus,
                  // );
                },
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.zipcode,
                hinttext:
                    AppLocalizations.of(context)!.pleaseentercompanyzipcode,
                controller: zipCodeController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {
                  // _fieldFocusChange(
                  //   context,
                  //   firstnameFocus!,
                  //   lastnameFocus,
                  // );
                },
                isLightTheme: isLightTheme,
                isRequired: false),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.vatnumber,
                hinttext:
                    AppLocalizations.of(context)!.pleaseentercompanyvatnumber,
                controller: VATNumberController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {
                  // _fieldFocusChange(
                  //   context,
                  //   firstnameFocus!,
                  //   lastnameFocus,
                  // );
                },
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
                      onUpdateCompanyInfoSetting(context);
                      // onUpdateClient(currentClient!);
                    },
            ),
            SizedBox(
              height: 100.h,
            ),
          ],
        );
      }
      if (state is SettingsLoading) {
        return NotesShimmer(
          height: 45.h,
          title: true,
        );
      }
      if (state is UpdateCompanyInfoSetting) {
        Navigator.pop(context);
        flutterToastCustom(
            msg: AppLocalizations.of(navigatorKey.currentContext!)!
                .updatedsuccessfully,
            color: AppColors.primary);
        BlocProvider.of<SettingsBloc>(context)
            .add(const SettingsList("company_information"));
      }
      if (state is ComapnyInformationSettingsEditError) {
        flutterToastCustom(msg: state.errorMessage, color: AppColors.primary);
        BlocProvider.of<SettingsBloc>(context)
            .add(const SettingsList("company_information"));
      }
      return SizedBox();
    });
  }
}
