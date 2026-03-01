import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../src/generated/i18n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:taskify/bloc/setting/settings_state.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/config/app_images.dart';
import 'package:taskify/data/localStorage/hive.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/permissions/permissions_state.dart';
import '../../bloc/setting/settings_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import '../../data/model/Project/all_project.dart';
import '../../routes/routes.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/toast_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.navigateAfterSeconds,
    required this.imageUrl,
    this.title,
  });

  final int navigateAfterSeconds;
  final String imageUrl;
  final String? title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool? isFirstTimeUser;
  bool? isBiometricActiveIs;
  String? fcmToken;
  bool _isAuthenticating = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  /// **Initialize all required setups**
  Future<void> _initializeSplash() async {
    await _checkInternetConnection();
    await _getFirstTimeUser();
    await _getLanguage();
    await _getFCMToken();
    await _handleFCMNotifications();
    await getBiometric();

    await Future.delayed(Duration(seconds: widget.navigateAfterSeconds), await _authenticateAndNavigate);
  }

  /// **Check Internet Connection**
  Future<void> _checkInternetConnection() async {
    List<ConnectivityResult> results = await CheckInternet.initConnectivity();
    if (results.isNotEmpty) {
      setState(() {});
    } else {
      flutterToastCustom(
          msg: AppLocalizations.of(context)!.nointernet, color: AppColors.red);
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {});
        });
      }
    });
  }

  /// **Retrieve First-Time User Status**
  Future<void> _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUser = box.get(firstTimeUserKey) ?? true;
  }

  /// **Fetch Device Language Settings**
  Future<void> _getLanguage() async {
    await LanguageBloc.initLanguage();
  }

  /// **Fetch and Store FCM Token**
  Future<void> _getFCMToken() async {
    if (_isRequestingPermission) {
      debugPrint("[Debug] Permission request already in progress, skipping...");
      return;
    }

    try {
      _isRequestingPermission = true;
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Check current permission status
      NotificationSettings settings = await messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint("[Debug] Notifications already authorized");
      } else {
        // Request permission if not already granted
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint("[Debug] Notification permission requested");
      }

      // iOS only: Wait for APNs token
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint("[Debug] APNs token not yet available. Try again later.");
        } else {
          debugPrint("[Debug] APNs token received: $apnsToken");
        }
      }

      // Optionally, retrieve and store the FCM token
      fcmToken = await messaging.getToken();
      debugPrint("[Debug] FCM Token: $fcmToken");
    } catch (e) {
      debugPrint("[Debug] FCM Token Error: $e");

    } finally {
      _isRequestingPermission = false;
    }
  }

  /// **Handle FCM Notifications**
  Future<void> _handleFCMNotifications() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        context.read<PermissionsBloc>().add(GetPermissions());
        _navigateBasedOnNotification(message);
      }
    });
  }

  /// **Navigate based on Notification Type**
  void _navigateBasedOnNotification(RemoteMessage message) {
    final payload = {
      'type': message.data['type'],
      'item': jsonDecode(message.data['item']),
    };
    final Map<String, dynamic> data = payload["item"];
    final String type = data['type'];

    switch (type) {
      case "project":
        router.push('/projectdetails', extra: {
          "id": data['item']['id'],
          "fromNoti": true,
          "projectModel": ProjectModel.empty()
        });
        break;
      case "task":
        router.push('/taskdetail',
            extra: {"id": data['item']['id'], "fromNoti": true});
        break;
      case "meeting":
        router.push('/meetings', extra: {"fromNoti": true});
        break;
      case "leave_request":
        router.push('/leaverequest', extra: {"fromNoti": true});
        break;
      case "workspace":
        router.push('/workspaces', extra: {"fromNoti": true});
        break;
      default:
        _authenticateAndNavigate();
    }
  }

  Future<bool> getBiometric() async {
    isBiometricActiveIs = await HiveStorage.getBiometricAuth();
    debugPrint("[Debug] Biometric setting: $isBiometricActiveIs");
    return isBiometricActiveIs!;
  }

  /// **Authenticate with Biometrics and Navigate**
  Future<void> _authenticateAndNavigate() async {
    try {
      if (isBiometricActiveIs!) {
        bool isAuthenticated = await _authenticateWithDeviceCredentials();
        if (!isAuthenticated) {
          debugPrint("[Debug] Authentication failed, stopping navigation");
          return;
        }
      }
      final token = await HiveStorage.isToken();
      if (token == false) {
        isFirstTimeUser == true
            ? router.go('/onboarding')
            : router.go('/login');
        return;
      }

      final settingsBloc = context.read<SettingsBloc>();
      final permissionsBloc = context.read<PermissionsBloc>();

      permissionsBloc.stream.listen(
            (state) {
          if (state is PermissionsSuccess) {
            router.go('/dashboard');
          } else if (state is PermissionsError) {
            flutterToastCustom(msg: "${state.errorMessage}");
          }
        },
        onError: (error) => flutterToastCustom(msg: "Something went wrong"),
      );

      settingsBloc.stream.listen(
            (state) {
          if (state is SettingsSuccess) {
            debugPrint("[Debug] Settings Loaded");
          } else if (state is SettingsError) {
            debugPrint("[Debug] Settings Error: ${state.errorMessage}");
            flutterToastCustom(msg: state.errorMessage);
          }
        },
        onError: (error) => flutterToastCustom(msg: "Something went wrong"),
      );

      settingsBloc.add(const SettingsList("general_settings"));
      permissionsBloc.add(GetPermissions());
    } catch (e) {
      debugPrint("[Debug] Authentication Error: $e");
      flutterToastCustom(msg: "Error: $e", color: AppColors.red);
    }
  }

  Future<bool> _authenticateWithDeviceCredentials() async {
    if (_isAuthenticating) {
      debugPrint("[Debug] Authentication already in progress");
      flutterToastCustom(
        msg: "Authentication already in progress",
        color: AppColors.orangeYellowishColor,
      );
      return false;
    }

    _isAuthenticating = true;
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final availableBiometrics = await _auth.getAvailableBiometrics();
      debugPrint("[Debug] Can check biometrics: $canCheckBiometrics");
      debugPrint("[Debug] Device supported: $isSupported");
      debugPrint("[Debug] Available biometrics: $availableBiometrics");

      // Check if no lock screen is configured (no biometrics enrolled and no PIN/pattern)
      if (isBiometricActiveIs! && (!canCheckBiometrics && availableBiometrics.isEmpty)) {
        flutterToastCustom(
          msg: "No device lock configured. Please set up a PIN, pattern, or biometric in device settings.",
          color: AppColors.red,
        );
        debugPrint("[Debug] No device lock configured");
        return false;
      }

      // Check if biometrics are supported and enrolled
      if (!canCheckBiometrics || !isSupported || availableBiometrics.isEmpty) {
        debugPrint("[Debug] Biometric authentication not supported or not enrolled");
        flutterToastCustom(
          msg: "No device lock configured. Please set up a PIN, pattern, or biometric in device settings.",
          color: AppColors.red,
        );
        return false;
      }

      final bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate using Face Unlock, PIN, or Pattern',
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      debugPrint("[Debug] Authentication result: $isAuthenticated");
      return isAuthenticated;
    } catch (e) {
      debugPrint("[Debug] Biometric Auth Error: $e");
      if (e.toString().contains("auth_in_progress")) {
        flutterToastCustom(
          msg: "Authentication already in progress",
          color: AppColors.orangeYellowishColor,
        );
      } else if (e.toString().contains("NotAvailable")) {
        flutterToastCustom(
          msg: "Biometric authentication not available",
          color: AppColors.red,
        );
      } else if (e.toString().contains("NotEnrolled")) {
        flutterToastCustom(
          msg: "No biometrics enrolled. Set up in device settings.",
          color: AppColors.orangeYellowishColor,
        );
      } else if (e.toString().contains("LockedOut")) {
        flutterToastCustom(
          msg: "Too many failed attempts. Use PIN or Pattern.",
          color: AppColors.red,
        );
      } else {
        flutterToastCustom(
          msg: "Authentication error. Try again.",
          color: AppColors.red,
        );
      }
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            image: DecorationImage(image: AssetImage(AppImages.splashLogoGif)),
          ),
        ),
      ),
    );
  }
}