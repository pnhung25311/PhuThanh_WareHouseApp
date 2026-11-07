/// Ảnh/video đã bắt được trên máy nhưng chưa lưu lên server, hiển thị ở tab
/// "Local" của màn hình hệ thống chụp ảnh.
class PendingScreenshot {
  final String filePath;
  final int capturedAt; // epoch milliseconds
  final int size; // bytes

  PendingScreenshot({
    required this.filePath,
    required this.capturedAt,
    required this.size,
  });

  DateTime get capturedAtDate =>
      DateTime.fromMillisecondsSinceEpoch(capturedAt);
}
