/// Thông tin 1 ảnh/video đã lưu trên server
/// (tương ứng response của GET /api/screenshot/list).
class ScreenshotInfo {
  final String deviceName;
  final String folderName;
  final String fileName;

  /// Mã ngẫu nhiên do server cấp cho file (dùng làm link không lộ tên người dùng).
  /// Rỗng nếu server chưa trả trường `token`.
  final String token;
  final int size;
  final int lastModified; // epoch milliseconds

  ScreenshotInfo({
    required this.deviceName,
    required this.folderName,
    required this.fileName,
    this.token = '',
    required this.size,
    required this.lastModified,
  });

  /// [fallbackFolder] dùng khi server không trả `folderName` trong JSON.
  factory ScreenshotInfo.fromJson(
    Map<String, dynamic> json, {
    String fallbackFolder = '',
  }) {
    final folder = json['folderName']?.toString() ?? '';
    return ScreenshotInfo(
      deviceName: json['deviceName']?.toString() ?? '',
      folderName: folder.isEmpty ? fallbackFolder : folder,
      fileName: json['fileName']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      lastModified: (json['lastModified'] as num?)?.toInt() ?? 0,
    );
  }

  DateTime get lastModifiedDate =>
      DateTime.fromMillisecondsSinceEpoch(lastModified);
}
