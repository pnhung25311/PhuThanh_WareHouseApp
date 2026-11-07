// import 'package:flutter/material.dart';

class FunctionConvertHelper {
  String convertToPublicIP(String url) {
    const localIP = '192.168.1.54';
    const publicIP = '14.224.207.115';

    if (url.contains(localIP)) {
      return url.replaceAll(localIP, publicIP);
    }
    return url;
  }

  /// Đổi IP nội bộ -> public khi không ở mạng LAN, đồng thời percent-encode
  /// URL (khoảng trắng, tiếng Việt có dấu trong tên file...) để `Image.network`
  /// tải được — thiếu bước này thì ảnh có tên phức tạp sẽ âm thầm lỗi.
  /// `Uri.encodeFull` giữ nguyên ký tự `%` nên gọi lại nhiều lần không bị
  /// double-encode.
  String resolveNetworkUrl(String url, bool isInternalNetwork) {
    final resolved = isInternalNetwork ? url : convertToPublicIP(url);
    return Uri.encodeFull(resolved);
  }
}
