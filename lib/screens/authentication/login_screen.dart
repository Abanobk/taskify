
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/bloc/auth/auth_state.dart';
import 'package:taskify/bloc/auth/auth_bloc.dart';
import 'package:taskify/bloc/auth/auth_event.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/bloc/setting/settings_event.dart';
import 'package:taskify/bloc/setting/settings_state.dart';
import 'package:taskify/config/app_images.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/config/constants.dart';
import 'package:taskify/config/end_points.dart';
import 'package:taskify/config/internet_connectivity.dart';
import 'package:taskify/config/strings.dart';
import 'package:taskify/data/localStorage/hive.dart';
import 'package:taskify/data/repositories/Auth/auth_repo.dart';
import 'package:taskify/routes/routes.dart';
import 'package:taskify/screens/authentication/widgets/auth_textfield.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:taskify/utils/widgets/no_internet_screen.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../src/generated/i18n/app_localizations.dart';
import '../widgets/custom_button.dart';
import '../widgets/validation.dart';

/// An enum to represent different user types for login
enum UserType { admin, member, client, none }

/// Service class for handling FCM token operations
class FCMService {
  static Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if (token != null) {
      await HiveStorage.setFcm(token);
      AuthRepository().getFcmId(fcmId: token);
    }
    return token;
  }
}

/// A screen that handles user authentication through login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _showPassword = true;
  UserType _userType = UserType.none;
  String? _fcmToken;

  // Connectivity variables
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();

    _markFirstTimeVisit();
    initFCM();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    final results = await CheckInternet.initConnectivity();
    setState(() {
      _connectionStatus = results;
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(_updateConnectionStatus);
  }

  /// Update connection status based on connectivity changes
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    if (results.isNotEmpty) {
      final updatedStatus = await CheckInternet.updateConnectionStatus(results);
      setState(() {
        _connectionStatus = updatedStatus;
      });
    } else {
      _showNoInternetToast();
    }
  }

  /// Initialize FCM token
  // Future<void> _initFCM() async {
  //   final token = await FCMService.getFCMToken();
  //   if (mounted) {
  //     setState(() {
  //       _fcmToken = token;
  //     });
  //   }
  // }
  final fcmService = FCMService();

  void initFCM() async {
    final token = await FCMService.getFCMToken();
    if (token != null) {
      // Send token to your backend if needed
      print("Using FCM token: $token");
    }
  }

  /// Mark app as not first time visit
  void _markFirstTimeVisit() {
    HiveStorage.setIsFirstTime(false);
  }

  /// Show toast message for no internet connection
  void _showNoInternetToast() {
    if (!mounted) return;
    flutterToastCustom(
        msg: AppLocalizations.of(context)!.nointernet,
        color: AppColors.red
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }


  /// Handle user login based on selected user type
  void _handleDemoLogin(UserType type) {
    FocusScope.of(context).unfocus();

    switch (type) {
      case UserType.admin:
        _setLoginCredentials(
            email: "admin@gmail.com",
            password: isDemo ? "123456" : "12345678"
        );
        break;
      case UserType.member:
        _setLoginCredentials(
            email: isDemo ? "member@gmail.com" : "infinitietechnologies09@gmail.com",
            password: isDemo ? "123456" : "12345678"
        );
        break;
      case UserType.client:
        _setLoginCredentials(
            email: isDemo ? "client@gmail.com" : "infinitie.parasgiri@gmail.com",
            password: isDemo ? "123456" : "12345678"
        );
        break;
      case UserType.none:
        break;
    }
  }


  /// Set login credentials in controllers and Bloc
  void _setLoginCredentials({required String email, required String password}) {
    _emailController.text = email;
    _passwordController.text = password;
    context.read<AuthBloc>().add(GetEmail(email: email));
    context.read<AuthBloc>().add(GetPassword(password: password));
  }

  /// Submit login form and handle authentication
  void _submitLoginForm() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showValidationErrorToast();
      return;
    }

    BlocProvider.of<AuthBloc>(context).add(AuthSignIn());
    _listenToAuthEvents();
  }

  /// Show appropriate validation error toast
  void _showValidationErrorToast() {
    if (_emailController.text.isEmpty && _passwordController.text.isEmpty) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.emailpassreq,
      );
    } else if (_emailController.text.isEmpty) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.emailreq,
      );
    } else if (_passwordController.text.isEmpty) {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pasreq,
      );
    }
  }

  /// Listen to authentication events and handle responses
  void _listenToAuthEvents() {
    context.read<AuthBloc>().stream.listen((event) {
      if (!mounted) return;

      if (event is AuthLoadSuccess) {
        _handleAuthSuccess();
      } else if (event is AuthLoadFailure) {
        flutterToastCustom(msg: event.message, color: AppColors.red);
      }
    });
  }

  /// Handle successful authentication
  void _handleAuthSuccess() {
    flutterToastCustom(
        msg: AppLocalizations.of(context)!.successfullyloggedIn,
        color: AppColors.primary
    );

    context.read<SettingsBloc>().add(const SettingsList("general_settings"));
    context.read<PermissionsBloc>().add(GetPermissions());

    _listenToSettingsEvents();
  }

  /// Listen to settings events after successful login
  void _listenToSettingsEvents() {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.stream.listen((state) {
      if (!mounted) return;

      if (state is SettingsSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/dashboard');
        });
      } else if (state is SettingsError) {
        router.go("/emailVerification");
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  /// Launch URL for forgot password
  Future<void> _launchForgotPasswordUrl() async {
    final url = Uri.parse(forgetPasswordUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      flutterToastCustom(
          msg: 'Could not open the link: ${e.toString()}',
          color: AppColors.red
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("$_userType");
    print("$_fcmToken");
    if (_connectionStatus.contains(ConnectivityResult.none)) {
      return const NoInternetScreen();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              _buildBackgroundImage(),
              _buildLogoImage(),
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the login form positioned in the screen
  Widget _buildLoginForm() {
    return Positioned(
      top: 260.h,
      left: 20.w,
      right: 20.w,
      bottom: 0,
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoginHeader(),
              SizedBox(height: 40.h),
              _buildEmailField(),
              SizedBox(height: 30.h),
              _buildPasswordField(),
              SizedBox(height: 10.h),
              _buildForgotPassword(),
              SizedBox(height: 40.h),
              _buildLoginButton(),
              SizedBox(height: 20.h),
              _buildDemoLoginButtons(),
              SizedBox(height: 10.h),
              _buildSignUpPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the background image for the login screen
  Widget _buildBackgroundImage() {
    return Positioned(
      top: 0,
      bottom: 550.h,
      right: 0,
      left: 0,
      child: Container(
        height: 400.h,
        width: 500.w,
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.loginBackgroundImage),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  /// Builds the logo image for the login screen
  Widget _buildLogoImage() {
    return Positioned(
      top: 70,
      right: 30,
      left: 30,
      child: Container(
        height: 70.h,
        width: 150.w,
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.splashLogo),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  /// Builds the login header with welcome text
  Widget _buildLoginHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100.h,
          width: 290.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: AppLocalizations.of(context)!.welcomeBack,
                    fontWeight: FontWeight.w700,
                    size: 30.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                  SizedBox(width: 5.w),
                  CustomText(
                    text: AppLocalizations.of(context)!.to,
                    fontWeight: FontWeight.w700,
                    size: 30.sp,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                ],
              ),
              CustomText(
                text: appName,
                fontWeight: FontWeight.w700,
                size: 30.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        CustomText(
          text: AppLocalizations.of(context)!.logInToYourAccount,
          fontWeight: FontWeight.w600,
          size: 14.sp,
          color: AppColors.greyForgetColor,
        ),
      ],
    );
  }

  /// Builds the email input field
  Widget _buildEmailField() {
    return AuthCustomTextField(
      controller: _emailController,
      focusNode: _emailFocus,
      labelText: AppLocalizations.of(context)!.email,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) => StringValidation.validateEmail(
          value ?? '',

      ),
      onSaved: (value) {
        if (value != null) {
          context.read<AuthBloc>().add(GetEmail(email: value));
        }
      },
      onChanged: (val) {
        context.read<AuthBloc>().add(GetEmail(email: val));
      },
    );
  }

  /// Builds the password input field
  Widget _buildPasswordField() {
    return  AuthCustomTextField(
      controller: _passwordController,
      focusNode: _passFocus,
      labelText: AppLocalizations.of(context)!.password,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _showPassword,
      autofillHints: const [AutofillHints.password],
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
      ],
      validator: (value) => StringValidation.validatePass(
          value ?? '',
          AppLocalizations.of(context)!.pasreq,
          "please enter valid password",
          onlyRequired: false
      ),
      onSaved: (value) {
        if (value != null) {
          context.read<AuthBloc>().add(GetPassword(password: value));
        }
      },
      onChanged: (val) {
        context.read<AuthBloc>().add(GetPassword(password: val));
      },
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _showPassword = !_showPassword;
          });
        },
        icon: Icon(
          _showPassword ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.fontColor.withValues(alpha:0.4),
          size: 22.sp,
        ),
      ),
    );
  }

  /// Builds the forgot password link
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: _launchForgotPasswordUrl,
        child: Padding(
          padding: EdgeInsets.only(right: 5.w),
          child: CustomText(
            text: AppLocalizations.of(context)!.forgetPassword,
            size: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.greyForgetColor,
          ),
        ),
      ),
    );
  }

  /// Builds the login button
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _submitLoginForm();
      },
      child: CustomButton(
        height: 50.h,
        isLoading: false,
        isLogin: true,
        isBorder: true,
        text: AppLocalizations.of(context)!.login,
        textcolor: AppColors.pureWhiteColor,

      ),
    );
  }

  /// Builds the demo login options row
  Widget _buildDemoLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDemoButton(
          label: AppLocalizations.of(context)!.admin,
          color: const Color(0xfff5a525),
          onTap: () => _handleDemoLogin(UserType.admin),
        ),
        _buildDemoButton(
          label: AppLocalizations.of(context)!.member,
          color: const Color(0xfff32660),
          onTap: () => _handleDemoLogin(UserType.member),
        ),
        _buildDemoButton(
          label: AppLocalizations.of(context)!.client,
          color: const Color(0xff36BA98),
          onTap: () => _handleDemoLogin(UserType.client),
        ),
      ],
    );
  }

  /// Helper method to build consistent demo buttons
  Widget _buildDemoButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: CustomButton(
        textcolor: color,
        height: 35.h,
        width: 100.w,
        isLoading: false,
        isLogin: false,
        isBorder: false,
        text: label,

      ),
    );
  }

  /// Builds the sign up prompt
  Widget _buildSignUpPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: AppLocalizations.of(context)!.dontHaveanAccount,
            size: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyForgetColor,
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () => router.push("/signup"),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: CustomText(
                text: AppLocalizations.of(context)!.signUp,
                size: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


