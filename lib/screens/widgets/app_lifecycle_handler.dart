import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:taskify/data/localStorage/hive.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/routes/routes.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _wasInBackground = false;
  bool? _isBiometricActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricStatus();
  }

  /// Check if biometric authentication is enabled in app settings
  Future<void> _checkBiometricStatus() async {
    _isBiometricActive = await HiveStorage.getBiometricAuth();
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      await _checkBiometricStatus(); // Refresh biometric status

      // Only check biometrics if it's enabled in app settings
      if (_isBiometricActive == true) {
        final token = await HiveStorage.isToken();
        if (token == false) {
          await _handleBiometricAuthentication();
        }
      } else {
        // Biometric is disabled in app, continue normally
        router.go('/home');
      }
      _wasInBackground = false;
    }
  }

  /// Handle biometric authentication logic
  Future<void> _handleBiometricAuthentication() async {
    try {
      // Check if device supports biometric authentication
      bool canAuthenticate = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        // Device doesn't support biometrics, continue normally
        debugPrint("[Debug] Device doesn't support biometric authentication");
        router.go('/home');
        return;
      }

      // Check if biometrics are enrolled
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        // No biometrics enrolled, continue normally without error
        debugPrint("[Debug] No biometrics enrolled on device");
        router.go('/home');
        return;
      }

      // Biometrics are available and enrolled, attempt authentication
      bool isAuthenticated = await _authenticateWithBiometrics();
      if (isAuthenticated) {
        router.go('/home'); // Navigate to home on success
      } else {
        router.go('/login'); // Navigate to login on failure
      }

    } catch (e) {
      // Handle errors gracefully - if biometric check fails, continue normally
      debugPrint("[Debug] Biometric Check Error: $e");
      router.go('/home'); // Continue to home instead of showing error
    }
  }

  /// Authenticate with biometrics
  Future<bool> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return false;

    _isAuthenticating = true;

    try {
      final bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate using Face Unlock, PIN, or Pattern',
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      debugPrint("[Debug] Biometric Auth Error: $e");

      // Handle specific authentication errors
      if (e.toString().contains("auth_in_progress")) {
        flutterToastCustom(
            msg: "Authentication already in progress.", color: Colors.orange);
      } else if (e.toString().contains("NotAvailable")) {
        // Biometric not available, continue normally
        debugPrint("[Debug] Biometric not available during authentication");
      } else if (e.toString().contains("NotEnrolled")) {
        flutterToastCustom(
            msg: "No biometrics enrolled. Set up in settings.",
            color: Colors.orange);
      } else if (e.toString().contains("LockedOut")) {
        flutterToastCustom(
            msg: "Too many failed attempts. Use PIN or Pattern.",
            color: Colors.red);
      } else if (e.toString().contains("UserCancel")) {
        // User cancelled authentication
        debugPrint("[Debug] User cancelled biometric authentication");
      } else {
        flutterToastCustom(
            msg: "Authentication error. Try again.", color: Colors.red);
      }
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}