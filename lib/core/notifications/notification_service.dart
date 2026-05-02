import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../auth/auth_service.dart';
import '../network/api_client.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

  static Future<void> initialize() async {
    await _requestPermission();
    await _initializeLocalNotifications();
    await _createAndroidNotificationChannel();
    await _setupFirebaseListeners();
    await _printFcmToken();
  }

  static Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permission status: ${settings.authorizationStatus}');
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> _createAndroidNotificationChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  static Future<void> _setupFirebaseListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened from background');
      _handleNotificationClick(message);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('Notification opened from terminated state');
      _handleNotificationClick(initialMessage);
    }

    _firebaseMessaging.onTokenRefresh.listen((String token) {
      debugPrint('FCM token refreshed: $token');

      registerToken(token: token);
    });
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data.toString(),
    );
  }

  static void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;

    debugPrint('Clicked notification data: $data');

    // Example with GetX:
    //
    // final screen = data['screen'];
    // final id = data['id'];
    //
    // if (screen == 'report_details') {
    //   Get.toNamed('/report-details', arguments: {'id': id});
    // }
  }

  static Future<String?> getFcmToken() async {
    return _firebaseMessaging.getToken();
  }

  static bool get _canSyncToken {
    if (!Platform.isAndroid) {
      return false;
    }

    if (!Get.isRegistered<AuthService>() || !Get.isRegistered<ApiClient>()) {
      return false;
    }

    final authService = Get.find<AuthService>();
    return authService.isAuthenticated.value &&
        (authService.accessToken.value?.isNotEmpty ?? false);
  }

  static Future<void> registerCurrentToken() async {
    if (!_canSyncToken) {
      return;
    }

    final token = await getFcmToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await registerToken(token: token);
  }

  static Future<void> registerToken({required String token}) async {
    if (!_canSyncToken || token.isEmpty) {
      return;
    }

    try {
      await Get.find<ApiClient>().dio.post(
        '/notifications/tokens',
        data: {'token': token, 'platform': 'android'},
      );
    } catch (error) {
      debugPrint('Failed to register FCM token: $error');
    }
  }

  static Future<void> unregisterCurrentToken() async {
    if (!_canSyncToken) {
      return;
    }

    final token = await getFcmToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await Get.find<ApiClient>().dio.delete(
        '/notifications/tokens',
        data: {'token': token},
      );
    } catch (error) {
      debugPrint('Failed to unregister FCM token: $error');
    }
  }

  static Future<void> _printFcmToken() async {
    final token = await getFcmToken();
    debugPrint('FCM TOKEN: $token');
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
