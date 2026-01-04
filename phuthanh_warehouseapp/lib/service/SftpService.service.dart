import 'dart:io';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
// import 'package:http/http.dart' as http;

class SftpService {
  final ApiClient api = const ApiClient();

  /// ✅ Upload file sử dụng ApiClient.postFile()
  Future<String?> uploadFile(File file, String productID) async {
    final response = await api.postFile("upload/$productID", file);

    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return body;
    } else {
      print("❌ Upload thất bại: ${response.statusCode} - $body");
      return null;
    }
  }

  /// 🗑️ Xóa file (gọi ApiClient.delete)
  Future<bool> deleteFile(String imageUrl, String productID) async {
    final fileName = imageUrl.split('/').last.split('.').first;
    final response = await api.delete(
      "delete/$productID?fileName=$fileName",
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Lỗi xóa: ${response.statusCode} - ${response.body}");
      return false;
    }
  }
}
