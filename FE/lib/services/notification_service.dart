import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/providers/detection_provider.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Thông báo quan trọng từ Camera',
    importance: Importance.max,
  );

  static Future<void> init() async {
    const initAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const initIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
        android: initAndroid, iOS: initIOS);
    await _localNotifications.initialize(initSettings);

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }

    // Chỉ gọi requestPermission của FCM nếu Firebase sẵn sàng
    if (Platform.isAndroid ||
        (Platform.isIOS && Firebase.apps.isNotEmpty)) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint(
          '🔔 Notification authorization status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional permission');
      } else {
        debugPrint('❌ User declined or has not accepted permission');
      }
    }
  }

  static Future<void> showNotification(
      RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    // Luôn xử lý logic vẽ khung nếu là detection
    if (data['type'] == 'detection') {
      _processDetection(message);
    }

    // Chỉ dừng lại nếu không có nội dung hiển thị (tiêu đề/nội dung)
    if (notification == null && data['title'] == null) return;
    
    final title = notification?.title ?? data['title'];
    final body = notification?.body ?? data['body'];

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Thông báo quan trọng từ Camera',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const details =
        NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      notification.hashCode,
      title,
      body,
      details,
    );
  }

  static void _processDetection(RemoteMessage message) {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      final data = message.data;
      final cameraId = data['cameraId'];
      final x = double.tryParse(data['x'] ?? '') ?? 0.0;
      final y = double.tryParse(data['y'] ?? '') ?? 0.0;
      final w = double.tryParse(data['w'] ?? '') ?? 0.0;
      final h = double.tryParse(data['h'] ?? '') ?? 0.0;

      if (cameraId != null) {
        Provider.of<DetectionProvider>(context, listen: false)
            .updateDetection(cameraId, x, y, w, h);
        debugPrint("🎯 Detection processed for $cameraId");
      }
    } catch (e) {
      debugPrint("❌ Error processing detection: $e");
    }
  }

  static void listenFCM() {
    if (!(Platform.isAndroid ||
        (Platform.isIOS && Firebase.apps.isNotEmpty))) {
      return; // iOS chưa init Firebase → thoát
    }
    FirebaseMessaging.onMessage.listen((m) {
      debugPrint("📩 Received FCM Message: ${m.data}");
      showNotification(m);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      debugPrint("User tapped notification: ${m.data}");
      if (m.data['type'] == 'detection') {
        _processDetection(m);
      }
    });
  }

  static Future<String?> getToken() async {
    if (Platform.isAndroid ||
        (Platform.isIOS && Firebase.apps.isNotEmpty)) {
      return FirebaseMessaging.instance.getToken();
    }
    return null;
  }

  static void listenTokenRefresh(
      Function(String) onRefresh) {
    if (Platform.isAndroid ||
        (Platform.isIOS && Firebase.apps.isNotEmpty)) {
      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        debugPrint("🔄 Token refreshed: $t");
        onRefresh(t);
      });
    }
  }
}
