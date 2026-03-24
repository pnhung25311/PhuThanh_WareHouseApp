import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/service/notification_service.service.dart';
import 'websocket_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() => _instance;

  NotificationManager._internal();

  final WebSocketService _ws = WebSocketService();

  final List<Map<String, dynamic>> notifications = [];

  void init(BuildContext context) {
    _ws.connect((data) {
      notifications.insert(0, data);
      NotificationService.show(
        title: "Thông báo",
        body: data['message'] ?? "",
        payload: data.toString(),
      );
      // 🔥 Popup realtime
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'] ?? "")));

      print("📩 Notification: $data");
    });
  }

  void dispose() {
    _ws.disconnect();
  }
}
