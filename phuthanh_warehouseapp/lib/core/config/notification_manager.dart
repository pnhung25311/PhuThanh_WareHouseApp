import 'dart:convert';

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifications.insert(0, data);

        // 🔔 Notification
        NotificationService.show(
          title: "Thông báo",
          body: data['message'].toString(),
          payload: jsonEncode(data)
        );

        // 🔥 SnackBar
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(data['message'] ?? "")),
        // );

        print("📩 Notification: $data");
      });
    });
  }

  void dispose() {
    _ws.disconnect();
  }
}
