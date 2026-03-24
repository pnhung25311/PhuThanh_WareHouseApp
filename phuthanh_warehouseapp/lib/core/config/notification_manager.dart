import 'package:flutter/material.dart';
import 'websocket_service.dart';

class NotificationManager {
  static final NotificationManager _instance =
      NotificationManager._internal();

  factory NotificationManager() => _instance;

  NotificationManager._internal();

  final WebSocketService _ws = WebSocketService();

  final List<Map<String, dynamic>> notifications = [];

  void init(BuildContext context) {
    _ws.connect((data) {
      notifications.insert(0, data);

      // 🔥 Popup realtime
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "")),
      );

      print("📩 Notification: $data");
    });
  }

  void dispose() {
    _ws.disconnect();
  }
}