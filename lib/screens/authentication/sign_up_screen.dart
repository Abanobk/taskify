import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskify/bloc/auth/auth_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../bloc/roles/role_bloc.dart';
import '../../bloc/roles/role_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../src/generated/i18n/app_localizations.dart';import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../utils/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedLabel = "As a Client";
  int _selectedIndex = 0;
  bool? isLoading;
  int? roleId;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();
  String? isMember;
  bool? _showPassword = true;
  bool? _showConPassword = true;
  FocusNode? emailFocus,
      firstnameFocus,
      lastnameFocus,
      comapnyFocus,
      roleFocus,
      conPasswordFocus,
      passFocus = FocusNode();
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void validateAndSubmit() async {
    FocusScope.of(context).unfocus();
    if (firstnameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        conPasswordController.text.isNotEmpty) {
      if (_selectedIndex == 0) {
        selectedLabel = "client";
      }
      if (_selectedIndex == 1) {
        selectedLabel = "member";
      }
      if (!emailController.text.contains('@')) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.entervalidemail,
        );
        return;
      }

      if (passwordController.text != conPasswordController.text) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pasconpassnotcorrect,
        );
        return;
      }
      isLoading = true;
      BlocProvider.of<AuthBloc>(context).add(AuthSignUp(
          context: context,
          email: emailController.text,
          role: roleId ?? 0,
          firstname: firstnameController.text,
          lastname: lastNameController.text,
          company: companyController.text,
          confirmPass: conPasswordController.text,
          type: selectedLabel,
          password: passwordController.text));
      final signUp = context.read<AuthBloc>();
      signUp.stream.listen((state) {
        if (state is AuthSignUpLoadSuccess) {
          isLoading = false;
          if (mounted) {
            flutterToastCustom(
              msg: AppLocalizations.of(context)!.registeredsuccessfully,
              color: AppColors.primary,
            );
            router.push("/login");
          }
        }

        if (state is AuthSignUpLoadFailure) {
          isLoading = false;
          flutterToastCustom(msg: state.message);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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
    BlocProvider.of<RoleBloc>(context).add(RoleList());
    super.initState();
  }

  Widget _buildToggleSwitch(bool isLightTheme) {
    return Container(
      height: 50.h,
      width: 370.w,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),
        color: Theme.of(context).colorScheme.containerDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
        ],
      ),
      child: ToggleSwitch(
        cornerRadius: 11,
        activeBgColor: const [AppColors.primary],
        inactiveBgColor: Theme.of(context).colorScheme.containerDark,
        minHeight: 40,
        minWidth: double.infinity,
        initialLabelIndex: _selectedIndex,
        totalSwitches: 2,
        customTextStyles: [
          TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          )
        ],
        labels: [
          AppLocalizations.of(context)!.asaclient,
          AppLocalizations.of(context)!.asateammember,
        ],
        onToggle: (index) {
          setState(() {
            _selectedIndex = index!;
            roleController.clear();
          });
        },
      ),
    );
  }

  Widget _buildSignUpForm(bool isLightTheme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          signUpText(context),
          SizedBox(height: 30.h),
          const SizedBox(height: 10),
          _buildToggleSwitch(isLightTheme),
          SizedBox(height: 30.h),
          CustomTextField(
            controller: firstnameController,
            labelText: AppLocalizations.of(context)!.firstname,
            isRequired: true,
            onFieldSubmitted: (v) =>
                _fieldFocusChange(context, firstnameFocus!, lastnameFocus),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: lastNameController,
            labelText: AppLocalizations.of(context)!.lastname,
            isRequired: true,
            onFieldSubmitted: (v) =>
                _fieldFocusChange(context, lastnameFocus!, comapnyFocus),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: emailController,
            labelText: AppLocalizations.of(context)!.email,
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            onFieldSubmitted: (v) =>
                _fieldFocusChange(context, emailFocus!, passFocus),
          ),
          const SizedBox(height: 20),
          if (_selectedIndex == 0) ...[
            CustomTextField(
              controller: companyController,
              labelText: AppLocalizations.of(context)!.company,
              onFieldSubmitted: (v) =>
                  _fieldFocusChange(context, comapnyFocus!, emailFocus),
            ),
            const SizedBox(height: 20),
          ],
          CustomTextField(
            controller: passwordController,
            labelText: 'Password',
            isRequired: true,
            isPassword: true,
            showPassword: _showPassword!,
            focusNode: passFocus,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
            onTogglePassword: () =>
                setState(() => _showPassword = !_showPassword!),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: conPasswordController,
            labelText: AppLocalizations.of(context)!.conPassword,
            isRequired: true,
            isPassword: true,
            showPassword: _showConPassword!,
            focusNode: conPasswordFocus,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[ ]'))],
            onTogglePassword: () =>
                setState(() => _showConPassword = !_showConPassword!),
          ),
          const SizedBox(height: 40),
          _buildSignUpButton(),
          const SizedBox(height: 10),
          _buildSignInLink(),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSignUpLoadSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.go('/login');
          });
        }
        return InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
            validateAndSubmit();
          },
          child: CustomButton(
            height: 50.h,
            isLoading: isLoading,
            isLogin: true,
            isBorder: true,
            text: AppLocalizations.of(context)!.signUp,
            textcolor: AppColors.pureWhiteColor,
          ),
        );
      },
    );
  }

  Widget _buildSignInLink() {
    return SizedBox(
      width: 370.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: AppLocalizations.of(context)!.alreadyhaveanaccount,
            size: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyForgetColor,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => router.go('/login'),
            child: CustomText(
              text: AppLocalizations.of(context)!.signIn,
              size: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
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
            body: signupBloc(isLightTheme, isLoading));
  }

  Widget signupBloc(bool isLightTheme, bool? isLoading) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.go('/login');
          });
        }
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                  top: 80.h,
                  left: 20.w,
                  right: 20.w,
                  child: _buildSignUpForm(isLightTheme),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget signUpText(context) {
  return SizedBox(
    // color: colors.red,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.createNewAccount,
          fontWeight: FontWeight.w700,
          size: 25.sp,
          color: AppColors.primary,
        ),
      ],
    ),
  );
}
