import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

class Treeviewservice {
  final ApiClient client = const ApiClient();

  Future<List<FileNode>> LoadTreeview() async {
    try {
      final response = await client.get("file/tree");

      final List data = jsonDecode(response.body);
      print("===============dd");
      print(data);

      return data.map((e) => FileNode.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<FileNode>> loadChildren(String path) async {
    final response = await client.get("file/tree?path=$path");

    final List data = jsonDecode(response.body);
    print("===============dd");
    print(data);
    return data.map((e) => FileNode.fromJson(e)).toList();
  }

  Future<void> downloadFile(String path, String fileName) async {
    try {
      final response = await client.get("file/download?path=$path");

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        // Dùng p.join để nối đường dẫn an toàn
        final file = File(p.join(dir.path, fileName));

        await file.writeAsBytes(response.bodyBytes);
        print("Downloaded: ${file.path}");
      } else {
        // Ép lỗi văng ra ngoài để bên UI (khối try-catch của _handleFileDownloadAndOpen) hứng được và hiện SnackBar cho user biết
        throw Exception("Server trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      // Đảm bảo lỗi luôn được đẩy ra ngoài UI
      rethrow;
    }
  }

  // ... các hàm loadChildren, downloadFile giữ nguyên ...
Future<String> uploadFile(String remotePath, File localFile) async {
    try {
      // 1. Gọi hàm postFile của ApiClient
      // Endpoint truyền vào trùng khớp với @PostMapping("/upload") ở Backend của bạn
      final streamedResponse = await client.postFile(
        "file/upload", // Endpoint (ApiClient tự nối baseUrl đằng trước)
        localFile,
        fileField: "file", // Khớp với @RequestParam("file") bên Spring Boot
        fields: {
          "path": remotePath, // Khớp với @RequestParam("path") bên Spring Boot
        },
      );

      // 2. Chuyển đổi streamedResponse thành Response thông thường để đọc nội dung text trả về
      final response = await http.Response.fromStream(streamedResponse);

      // 3. Kiểm tra kết quả trả về từ Server
      if (response.statusCode == 200) {
        // Trả về chuỗi: "Upload file thành công: ..." từ Spring Boot
        return response.body; 
      } else {
        // Nếu Server trả về 400 hoặc 500, ném text lỗi ra ngoài UI hứng
        throw Exception(response.body); 
      }
    } catch (e) {
      // Đẩy lỗi ra ngoài để khối try-catch bên TreeViewPage xử lý hiện SnackBar
      rethrow; 
    }
  }

}
