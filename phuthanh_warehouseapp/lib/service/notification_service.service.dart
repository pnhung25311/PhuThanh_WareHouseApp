import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 🔥 Init
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await _plugin.initialize(
      settings: settings, // ✅ version mới dùng 'settings'
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("🔔 Click notification: ${response.payload}");
      },
    );

    // ✅ Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 🔔 Show notification
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Thông báo',
      channelDescription: 'Notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // ✅ bắt buộc
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}