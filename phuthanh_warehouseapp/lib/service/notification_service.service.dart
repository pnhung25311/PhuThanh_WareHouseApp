import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 🔥 INIT
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,

      // ✅ Hiện khi app đang mở (QUAN TRỌNG)
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        print("🔔 Click notification: ${response.payload}");
      },
    );

    /// ✅ Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    /// ✅ iOS (version mới dùng Darwin)
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >() // ✅ dùng cái này
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// 🔔 SHOW NOTIFICATION
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    /// ANDROID
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Thông báo',
      channelDescription: 'Notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    /// IOS (QUAN TRỌNG)
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,

    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    print("👉 SHOW NOTIFICATION");

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}
