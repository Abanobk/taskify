
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskify/data/GlobalVariable/globalvariable.dart';
import '../config/strings.dart';
import '../firebase_options.dart';
import '../screens/widgets/firebase_services.dart';


bool isDarkTheme = false;

Future<void> initializeApp() async {

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  // Initialize Hive first
  await Hive.initFlutter();
  GlobalUserData();

  // Open Hive boxes
  await Future.wait([
    Hive.openBox(authBox),
    Hive.openBox(themeBox),
    Hive.openBox(userBox),
    Hive.openBox(headerBox),
    Hive.openBox(permissionsBox),
    Hive.openBox(languageBoxName),
    Hive.openBox(settingsBox),
  ]);

  // Load theme preference
  final themeBoxIs = Hive.box(themeBox);
  isDarkTheme = themeBoxIs.get(isDarkThemeKey, defaultValue: false);

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

// Create a separate function to initialize notifications after the app starts
Future<void> initializeNotifications(BuildContext context) async {
  final notificationService = NotificationService();
  await notificationService.initFirebaseMessaging(context);

  // Set up FCM token refresh listener
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("New FCM Token: $newToken");
    // Uncomment these if you have the methods available:
    // HiveStorage.setFcm(newToken);
    // AuthRepository().getFcmId(fcmId: newToken);
  });
}
