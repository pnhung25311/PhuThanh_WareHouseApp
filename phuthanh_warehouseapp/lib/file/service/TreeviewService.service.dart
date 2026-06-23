import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class Treeviewservice {
  final ApiClient client = const ApiClient();

  /// 1. Tải các vùng thư mục gốc ban đầu được phân quyền cho User
  Future<List<FileNode>> loadTreeview() async {
    try {
      // Gọi đúng endpoint khớp với @GetMapping("/file/tree") của Spring Boot
      final response = await client.get("file/tree");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => FileNode.fromJson(e)).toList();
      } else {
        throw Exception(
          "Không thể tải danh sách thư mục gốc: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Lỗi kết nối hệ thống: ${e.toString()}");
    }
  }

  /// 2. Tải các thư mục/file con bên trong dựa vào virtualPath ảo
  /// @param virtualPath có định dạng: "aliasName/relativePath" (Ví dụ: "drive-d/HopDong2026")
  Future<List<FileNode>> loadChildren(String accID, String virtualPath) async {
    try {
      // Gọi đúng endpoint khớp với @GetMapping("/files/tree") của Spring Boot
      String conditionApi = virtualPath == ""
          ? "files/tree?accountId=$accID"
          : "files/tree?accountId=$accID&path=$virtualPath";
      final response = await client.get(conditionApi);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => FileNode.fromJson(e)).toList();
      } else {
        throw Exception("Bạn không có quyền truy cập vào thư mục này!");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. Download file dựa vào virtualPath và lưu vào bộ nhớ máy Local
  /// Hàm download file trong TreeviewService.service.dart của bạn cần đảm bảo cấu trúc:
  Future<void> downloadFile(String virtualPath, String fullLocalPath) async {
    try {
      // 👉 BẮT BUỘC: Mã hóa an toàn component đường dẫn (biến & thành %26, khoảng trắng thành %20)
      final String encodedPath = Uri.encodeComponent(virtualPath);

      final response = await client.get("file/download?path=$encodedPath");

      if (response.statusCode == 200) {
        final File file = File(fullLocalPath);

        // Tự tạo thư mục cha nếu chưa tồn tại trên điện thoại
        final int lastSlashIndex = fullLocalPath.lastIndexOf('/');
        if (lastSlashIndex != -1) {
          final String parentFolderPath = fullLocalPath.substring(
            0,
            lastSlashIndex,
          );
          final Directory parentDir = Directory(parentFolderPath);
          if (!await parentDir.exists()) {
            await parentDir.create(recursive: true);
          }
        }

        // Ghi dữ liệu luồng byte vào thiết bị
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception("Tải file thất bại. Server phản hồi: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 4. Upload file local lên thư mục đích ảo trên Server (Kiểm tra writeAccountIds)
  /// @param remoteVirtualPath Thư mục đích (Ví dụ: "drive-d/HopDong2026")
  Future<String> uploadFile(String remoteVirtualPath, File localFile) async {
    try {
      // Gọi chính xác endpoint /api/file/upload đã cấu hình ở Backend
      final streamedResponse = await client.postFile(
        "file/upload",
        localFile,
        fileField: "file",
        fields: {"path": remoteVirtualPath},
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body; // "Upload file thành công!"
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 5. Xóa file hoặc thư mục vật lý đệ quy từ xa thông qua đường dẫn ảo
  /// @param virtualPath Đường dẫn của mục cần xóa (Ví dụ: "drive-c/Thư mục test/luong.txt")
  /// Xóa file hoặc thư mục vật lý đệ quy từ xa thông qua đường dẫn ảo
  Future<String> deleteFileOrFolder(String virtualPath) async {
    try {
      final String encodedPath = Uri.encodeComponent(virtualPath);
      // Gọi API DELETE, backend tự bóc tách accountId từ Jwt Token
      final response = await client.delete("file/delete?path=$encodedPath", "");

      if (response.statusCode == 200) {
        return response.body; // "Xóa mục dữ liệu vật lý thành công!"
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 6. Sao chép (Copy) file hoặc thư mục sang thư mục đích
  /// @param sourcePath Đường dẫn tệp/thư mục nguồn (Ví dụ: "drive-c/Data/tailieu.pdf")
  /// @param targetDirectoryPath Thư mục đích muốn dán vào (Ví dụ: "drive-d/Backup")
  Future<String> copyFileOrFolder({
    required String sourcePath,
    required String targetDirectoryPath,
  }) async {
    try {
      // Mã hóa query parameters để tránh lỗi ký tự đặc biệt hoặc khoảng trắng khi truyền URL
      final String encodedSrc = Uri.encodeComponent(sourcePath);
      final String encodedTarget = Uri.encodeComponent(targetDirectoryPath);

      // Gọi endpoint POST khớp với @PostMapping("/files/copy") ở Spring Boot
      // Truyền tham số dưới dạng query parameters (?sourcePath=...&targetDirectoryPath=...)
      final response = await client.post(
        "files/copy?sourcePath=$encodedSrc&targetDirectoryPath=$encodedTarget",
        "", // Body để trống vì dữ liệu đã truyền trên URL thông qua RequestParam
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về text: "Sao chép dữ liệu thành công!"
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception("Lỗi hệ thống khi sao chép: ${e.toString()}");
    }
  }

  /// 7. Di chuyển / Cắt (Move / Cut) file hoặc thư mục sang thư mục đích
  /// @param sourcePath Đường dẫn tệp/thư mục nguồn cần cắt
  /// @param targetDirectoryPath Thư mục đích muốn chuyển tới
  Future<String> moveFileOrFolder({
    required String sourcePath,
    required String targetDirectoryPath,
  }) async {
    try {
      final String encodedSrc = Uri.encodeComponent(sourcePath);
      final String encodedTarget = Uri.encodeComponent(targetDirectoryPath);

      // Gọi endpoint POST khớp với @PostMapping("/files/move") ở Spring Boot
      final response = await client.post(
        "files/move?sourcePath=$encodedSrc&targetDirectoryPath=$encodedTarget",
        "", // Body để trống
      );

      if (response.statusCode == 200) {
        return response.body; // Trả về text: "Di chuyển dữ liệu thành công!"
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception("Lỗi hệ thống khi di chuyển: ${e.toString()}");
    }
  }

  // Trong TreeviewService.service.dart
  Future<void> createFolder(
    String accid,
    String parentPath,
    String folderName,
  ) async {
    final url = 'file/create-folder';
    final response = await client.post(
      url,
      jsonEncode({
        'accountId': accid,
        'parentPath': parentPath,
        'folderName': folderName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> renameItem(
    String accid,
    String currentPath,
    String newName,
  ) async {
    final url = 'file/rename';
    final response = await client.post(
      url,
      jsonEncode({
        'accountId': accid,
        'currentPath': currentPath,
        'newName': newName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
