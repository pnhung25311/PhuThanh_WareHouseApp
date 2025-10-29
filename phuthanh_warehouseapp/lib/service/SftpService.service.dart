import 'dart:io';
import 'package:http/http.dart' as http;
// import 'dart:convert';

class SftpService {
  Future<String?> uploadFile(File file, String productID) async {
    final uri = Uri.parse("http://192.168.1.11:8080/api/upload/$productID");

    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print("✅ Upload thành công: $responseBody");
      return responseBody; // server trả về URL img
    } else {
      print("❌ Upload thất bại: ${response.statusCode}");
      return null;
    }
  }

  // 🗑️ Xóa ảnh (đúng với route backend: /api/delete/{productID}?fileName=img1)
  Future<bool> deleteFile(String imageUrl, String productID) async {
    try {
      // ✅ Tách tên file (img1, img2, v.v.)
      final fileName = imageUrl
          .split('/')
          .last
          .split('.')
          .first; // lấy img1 từ img1.png
      print(
        "http://192.168.1.11:8080/api/delete/$productID?fileName=$fileName",
      );
      final uri = Uri.parse(
        "http://192.168.1.11:8080/api/delete/$productID?fileName=$fileName",
      );

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print("🗑️ Xóa thành công: $fileName");
        return true;
      } else {
        print("❌ Lỗi xóa: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Lỗi khi gửi request xóa: $e");
      return false;
    }
  }
}
