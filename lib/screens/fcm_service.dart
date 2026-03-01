import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String?> getFCMToken() async {
  if (Platform.isIOS) {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    if (!iosInfo.isPhysicalDevice) {
      print('Skipping FCM token fetch: running on iOS simulator.');
      return null;
    }
  }

  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if (!androidInfo.isPhysicalDevice) {
      print('Skipping FCM token fetch: running on Android emulator.');
      return null;
    }
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission (iOS only)
  await messaging.requestPermission();

  // IMPORTANT: For iOS, get APNS token first
  if (Platform.isIOS) {
    try {
      String? apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        print("🍎 APNS Token: $apnsToken");
      } else {
        print("⚠️ APNS token is null - retrying...");
        // Wait a bit and retry
        await Future.delayed(Duration(seconds: 2));
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          print("❌ Failed to get APNS token after retry");
          return null;
        }
      }
    } catch (e) {
      print("❌ Error getting APNS token: $e");
      return null;
    }
  }

  // Now get the FCM token
  try {
    final token = await messaging.getToken();
    print("🔥 FCM Token: $token");
    return token;
  } catch (e) {
    print("❌ Error getting FCM token: $e");
    return null;
  }
}
