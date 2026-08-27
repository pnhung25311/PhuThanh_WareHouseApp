// import 'package:flutter/material.dart';
// import 'package:phuthanh_warehouseapp/service/notification_service.service.dart';
// import 'websocket_service.dart';

// class NotificationManager {
//   static final NotificationManager _instance = NotificationManager._internal();

//   factory NotificationManager() => _instance;

//   NotificationManager._internal();

//   final WebSocketService _ws = WebSocketService();

//   final List<Map<String, dynamic>> notifications = [];
//   bool _connected = false;
//   void init(BuildContext context) {
//     if (_connected) return;
//     _connected = true;
//     _ws.connect((data) {
//         notifications.insert(0, data);

//         // 🔔 Notification
//         NotificationService().showNotification(
//           title: "Thông báo",
//           body: data['message'].toString(),
//         );

//         // 🔥 SnackBar
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(content: Text(data['message'] ?? "")),
//         // );

//         print("📩 Notification: $data");
//       });
//   }

//   void dispose() {
//     _ws.disconnect();
//   }
// }
