/// Kết quả 1 lần upload lên server: mã HTTP + nội dung trả về, để báo rõ lý
/// do khi thất bại (ví dụ 413 = file vượt giới hạn dung lượng của server).
class UploadResult {
  final int statusCode;
  final String body;

  const UploadResult({required this.statusCode, required this.body});

  bool get ok => statusCode == 200;

  /// Mô tả ngắn lý do thất bại, dùng để hiển thị cho người dùng.
  String get errorMessage {
    if (statusCode == 413) {
      return 'File quá lớn so với giới hạn của server (HTTP 413)';
    }
    final detail = body.trim();
    final shortDetail =
        detail.length > 160 ? '${detail.substring(0, 160)}...' : detail;
    return shortDetail.isEmpty
        ? 'HTTP $statusCode'
        : 'HTTP $statusCode: $shortDetail';
  }
}
