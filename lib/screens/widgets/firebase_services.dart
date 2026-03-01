import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../data/model/Project/all_project.dart';
import '../../routes/routes.dart';

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  print("📥 Background FCM received: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initFirebaseMessaging(BuildContext context) async {
    await _requestNotificationPermissions();
    await _getAPNSToken();
    String? fcmToken = await _firebaseMessaging.getToken();
    print('🔑 FCM Token: $fcmToken');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 onMessage called with data: ${message.data}");
      print("Notification: ${message.notification?.title} - ${message.notification?.body}");
      _showForegroundNotification(message);
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚪 App opened from background with data: ${message.data}');
      _handleNotificationTap(message.data);
    });

    // App opened from terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚪 App launched from terminated with data: ${initialMessage.data}');
      _handleNotificationTap(initialMessage.data);
    }

    // Token refresh
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      print('🔁 New FCM Token: $newToken');
    });

    await _initLocalNotificationPlugin();
  }

  Future<void> _getAPNSToken() async {
    if (Platform.isIOS) {
      try {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          print("🍎 APNS Token: $apnsToken");
        } else {
          print("⚠️ APNS token is null - retrying...");
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          print(apnsToken != null ? "🍎 APNS Token (retry): $apnsToken" : "❌ Failed to get APNS token");
        }
      } catch (e) {
        print("❌ Error getting APNS token: $e");
      }
    }
  }

  Future<void> _initLocalNotificationPlugin() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🖱️ Notification tapped: ${response.payload}');
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _handleNotificationTap(data);
          } catch (e) {
            print('❌ Error parsing notification payload: $e');
          }
        }
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'taskify_channel',
          'Taskify Notifications',
          description: 'Notifications for Taskify app',
          importance: Importance.max,
        ),
      );
    }
  }

  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    print('📋 Notification permission status: ${settings.authorizationStatus}');

    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void setupFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 onMessage called with data: ${message.data}');
      print('Notification: ${message.notification?.title}');
      _showForegroundNotification(message);
    });
  }

  void _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'taskify_channel',
      'Taskify Notifications',
      channelDescription: 'Notifications for Taskify app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      actions: [
        AndroidNotificationAction(
          'DECLINE_ACTION',
          'Decline',
          cancelNotification: true,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = jsonEncode(message.data);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'Taskify',
      message.notification?.body ?? '',
      notificationDetails,
      payload: payload,
    );
  }

  static void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('🔥 Handling notification tap with data: $data');
    try {
      debugPrint('🔥 Raw item: ${data['item']}');

      // Parse data['item'] if it exists
      Map<String, dynamic> payload = {};
      if (data.containsKey('item')) {
        if (data['item'] is String) {
          debugPrint('🔥 Parsing item as JSON string: ${data['item']}');
          payload = jsonDecode(data['item']);
        } else if (data['item'] is Map<String, dynamic>) {
          debugPrint('🔥 Item is already a map: ${data['item']}');
          payload = data['item'];
        } else {
          debugPrint('⚠️ Invalid item format: ${data['item']}');
          router.push('/notifications', extra: {'fromNoti': true});
          return;
        }
      } else {
        debugPrint('⚠️ No item field in notification data: $data');
        router.push('/notifications', extra: {'fromNoti': true});
        return;
      }

      // Extract type from the parsed payload
      final String? type = payload['type'];
      if (type == null) {
        debugPrint('⚠️ No type found in payload: $payload');
        router.push('/notifications', extra: {'fromNoti': true});
        return;
      }

      // Extract nested item for project/task details
      Map<String, dynamic> item = payload['item'] is Map<String, dynamic>
          ? payload['item']
          : (payload['item'] is String ? jsonDecode(payload['item']) : {});

      debugPrint('🔁 Navigating to $type with item: $item');

      switch (type) {
        case "project":
          if (item['id'] != null) {
            debugPrint('🔥 Navigating to projectdetails with id: ${item['id']}');
            router.push(
              '/projectdetails',
              extra: {
                "id": item['id'], // Convert to string to handle int
                "fromNoti": true,
                "projectModel": ProjectModel.empty(),
              },
            );
          } else {
            debugPrint('⚠️ Missing project ID in item: $item');
            router.push('/notifications', extra: {'fromNoti': true});
          }
          break;
        case "task":
          if (item['id'] != null) {
            debugPrint('🔥 Navigating to taskdetail with id: ${item['id']}');
            router.push(
              '/taskdetail',
              extra: {
                "id": item['id'], // Convert to string to handle int
                "fromNoti": true,
              },
            );
          } else {
            debugPrint('⚠️ Missing task ID in item: $item');
            router.push('/notifications', extra: {'fromNoti': true});
          }
          break;
        case "meeting":
          debugPrint('🔥 Navigating to meetings');
          router.push('/meetings', extra: {"fromNoti": true});
          break;
        case "leave_request":
          debugPrint('🔥 Navigating to leaverequest');
          router.push('/leaverequest', extra: {"fromNoti": true});
          break;
        case "workspace":
          debugPrint('🔥 Navigating to workspaces');
          router.push('/workspaces', extra: {"fromNoti": true});
          break;
        default:
          debugPrint('⚠️ Unknown notification type: $type');
          router.push('/notifications', extra: {'fromNoti': true});
      }
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
      router.push('/notifications', extra: {'fromNoti': true});
    }
  }

  static void handleNavigation(Map<String, dynamic> payload) {
    _handleNotificationTap(payload);
  }
}