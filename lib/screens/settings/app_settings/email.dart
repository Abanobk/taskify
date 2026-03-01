import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/screens/settings/app_settings/widgets/custom_list.dart';
import '../../../bloc/setting/settings_bloc.dart';
import '../../../bloc/setting/settings_event.dart';
import '../../../bloc/setting/settings_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../config/internet_connectivity.dart';
import '../../../src/generated/i18n/app_localizations.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/back_arrow.dart';
import 'package:taskify/screens/status/widgets/notes_shimmer_widget.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/no_internet_screen.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../widgets/custom_cancel_create_button.dart';
import '../../widgets/custom_textfields/custom_textfield.dart';

class EmailSettingScreen extends StatefulWidget {
  const EmailSettingScreen({super.key});

  @override
  State<EmailSettingScreen> createState() => _EmailSettingScreenState();
}

class _EmailSettingScreenState extends State<EmailSettingScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController smtpPortController = TextEditingController();
  TextEditingController emailContentController = TextEditingController();
  TextEditingController smtpHostController = TextEditingController();

  bool? isSignUpVisible;
  String? selectedType;
  String? smtpEncryption;

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
    BlocProvider.of<SettingsBloc>(context).add(const SettingsList("email_settings"));

    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void onUpdateEmail(BuildContext context,email,password,smtoEncryption,
      smtpHost,smtpPost,emailContentType) {
    print("sDZfjlcmfvj m ");
    print("sDZfjlcmfvj m $email");
    print("sDZfjlcmfvj m $password");
    print("sDZfjlcmfvj m $smtoEncryption");
    print("sDZfjlcmfvj m $smtpHost");
    print("sDZfjlcmfvj m $smtpPost");
    print("sDZfjlcmfvj m $emailContentType");
    if( email!= null  &&  password!= null  && smtpHost!= null
        && smtpPost!= null  && emailContentType!=null && smtoEncryption != null ) {
      context.read<SettingsBloc>().add(UpdateSettingsEmail(
        email:email,
        password: password,
        smtpEncryption: smtoEncryption!,
        smtpHost: smtpHost,
        smtpPort: smtpPost, emailContentType: emailContentType!,
      ));
    }else{

      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );


    }   }
  void _handleEmailContentTypeSelected(String category) {
    setState(() {
      selectedType = category;
    });

  }
  void _handleSmtpEncryptionSelected(String category) {
    setState(() {
      smtpEncryption = category;

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
                    title: AppLocalizations.of(context)!.companyemail,
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
        },
        builder: (context, state) {
      if (state is SettingsSuccess) {
        print("g vfdncm ${context.read<SettingsBloc>().companyEmail}");
        emailController.text = context.read<SettingsBloc>().companyEmail??"";
        passwordController.text = context.read<SettingsBloc>().emailPasswordSetting??"";
        smtpHostController.text = context.read<SettingsBloc>().smtpHost??"";
        smtpPortController.text = context.read<SettingsBloc>().smtpPort??"";
        selectedType=context.read<SettingsBloc>().emailContentType??"Please select";
        smtpEncryption=context.read<SettingsBloc>().smtpEncryption??"Please select";
print("ghyujikl;$state");
         return Column(
          children: [
            SizedBox(
              height: 20.w,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.companyemail,
                hinttext: AppLocalizations.of(context)!.pleaseenteremail,
                controller: emailController
                ,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                isPassword: true,
                title: AppLocalizations.of(context)!.password,
                hinttext:
                AppLocalizations.of(context)!.pleaseenterpassword,
                readonly:false ,
                controller: passwordController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.smtphost,
                hinttext: AppLocalizations.of(context)!.pleaseentersmtphost,
                controller: smtpHostController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),
            SizedBox(
              height: 15.h,
            ),
            CustomTextFields(
                title: AppLocalizations.of(context)!.smtpport,
                subtitle: "",
                hinttext: AppLocalizations.of(context)!.pleaseentersmtpport,
                controller: smtpPortController,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                isLightTheme: isLightTheme,
                isRequired: true),

            SizedBox(
              height: 15.h,
            ),
            CustomListField(
                onStorageSelected: (String ) {  },
                onStatusSelected: (String ) {  },
              title:"emailContentType",
              isRequired: true,
              name: selectedType ,
              onrequestMethodSelected: (String ) {  },
              onFollowUpTypeSelected: (String ) {  },
              // smtpName: "",
              onTypeSelected: _handleEmailContentTypeSelected,
                onSmtpEncryptionSelected:(String t){}
            ),    SizedBox(
              height: 15.h,
            ),
            CustomListField(
              onStorageSelected: (String ) {  },
              onStatusSelected: (String ) {  },
              onFollowUpTypeSelected: (String ) {  },
              title:"smtpEncryption",
              isRequired: true,
              name: smtpEncryption,
              // typeName: "",
              onTypeSelected: (String t){},
              onrequestMethodSelected: (String ) {  },
              onSmtpEncryptionSelected: _handleSmtpEncryptionSelected,
            ),
            SizedBox(
              height: 15.h,
            ),
            CreateCancelButtom(
              isCreate: false,
              isLoading: false,
              onpressCancel: () {
                Navigator.pop(context);
              },
              onpressCreate: true == false
                  ? () async {
                onUpdateEmail(context,emailController.text,passwordController.text,
                    smtpEncryption,
                    smtpHostController.text,smtpPortController.text,selectedType);
              }
                  : () {
                onUpdateEmail(context,emailController.text,passwordController.text,
                    smtpEncryption,
                    smtpHostController.text,smtpPortController.text,selectedType);
              },
            ),
            SizedBox(
              height: 100.h,
            ),
          ]);
      }
          if(state is SettingsLoading){
            return NotesShimmer(height: 45.h,title: true,);
          }
          if(state is SettingsError){
            flutterToastCustom(
                msg: state.errorMessage,
                color: AppColors.primary);
            BlocProvider.of<SettingsBloc>(context).add(const SettingsList("email_settings"));

          }
          if(state is UpdateEmailSettingError){
            flutterToastCustom(
                msg: state.errorMessage,
                color: AppColors.primary);
            router.pop();
          }
          if(state is UpdateEmailSettingSuccess){
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.updatedsuccessfully,
                color: AppColors.primary);
            router.pop();
          }
      return SizedBox();
    });
  }
}
