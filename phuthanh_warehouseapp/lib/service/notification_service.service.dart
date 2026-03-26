import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // ⭐ SINGLETON
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 🔥 INIT (chỉ chạy 1 lần)
  Future<void> init() async {
    if (_initialized) return;   // ⭐ cực quan trọng
    _initialized = true;

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings: settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    print("🔔 NotificationService READY");
  }

  /// 🔔 SHOW
  Future<void> showNotification({
    int id = 0,
    String title = 'Thông báo',
    String body = 'Thông báo',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Thông báo',
      channelDescription: 'Notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }
}