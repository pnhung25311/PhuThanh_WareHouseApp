// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   // Handle background messages if needed
//   if (message.notification != null) {
//     await NotificationService().showNotification(
//       title: message.notification!.title ?? "Thông báo",
//       body: message.notification!.body ?? "",
//     );
//   }
// }

// class NotificationService {
//   // ⭐ SINGLETON
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   bool _initialized = false;

//   /// 🔥 INIT (chỉ chạy 1 lần)
//   Future<void> init() async {
//     if (_initialized) return; // ⭐ cực quan trọng
//     _initialized = true;

//     const AndroidInitializationSettings android = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const DarwinInitializationSettings ios = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       defaultPresentAlert: true,
//       defaultPresentBadge: true,
//       defaultPresentSound: true,
//     );

//     const InitializationSettings settings = InitializationSettings(
//       android: android,
//       iOS: ios,
//     );

//     await _plugin.initialize(settings: settings);

//     await _plugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.requestNotificationsPermission();

//     await _plugin
//         .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin
//         >()
//         ?.requestPermissions(alert: true, badge: true, sound: true);
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'channel_id',
//       'Thông báo',
//       description: 'Notification channel',
//       importance: Importance.max,
//     );

//     await _plugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(channel);
//     print("🔔 NotificationService READY");
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 Received foreground message: ${message.messageId}');
//       if (message.notification != null) {
//         NotificationService().showNotification(
//           title: message.notification!.title ?? "Thông báo",
//           body: message.notification!.body ?? "",
//         );
//       }
//     });
//   }

//   /// 🔔 SHOW
//   Future<void> showNotification({
//     int id = 0,
//     String title = 'Thông báo',
//     String body = 'Thông báo',
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'Thông báo',
//       channelDescription: 'Notification channel',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _plugin.show(
//       id: id,
//       title: title,
//       body: body,
//       notificationDetails: details,
//     );
//   }
// }
