import 'dart:io';

import 'package:flutter/services.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/CapturedScreenshot.model.dart';

/// Bọc EventChannel native (Android ContentObserver / iOS
/// userDidTakeScreenshotNotification) để phát ra ảnh mỗi khi người dùng
/// chụp màn hình thiết bị.
class ScreenshotChannel {
  static const EventChannel _channel = EventChannel(
    'com.phuthanh.warehouseapp/screenshot_stream',
  );

  static Stream<CapturedScreenshot>? _stream;

  /// Stream broadcast phát ra mỗi khi có screenshot mới.
  /// An toàn khi gọi nhiều lần (dùng chung 1 stream).
  static Stream<CapturedScreenshot> get onScreenshotTaken {
    _stream ??= _channel.receiveBroadcastStream().map((event) {
      final data = Map<String, dynamic>.from(event as Map);
      return CapturedScreenshot(
        file: File(data['path'] as String),
        fromBackground: data['fromBackground'] == true,
      );
    });
    return _stream!;
  }
}
