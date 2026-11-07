import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/ScreenshotInfo.model.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/UploadResult.model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Gọi API backend quản lý ảnh/video (mỗi `deviceName` có nhiều folder):
/// - POST/GET(list)/DELETE/PUT(rename) `/screenshot/folder`: quản lý folder
/// - GET    `/screenshot/list`  : danh sách file trong 1 folder
/// - GET    `/screenshot/view`  : nội dung (bytes) của 1 file
/// - POST   `/screenshot/upload`: upload file vào 1 folder
/// - DELETE `/screenshot/delete`: xóa 1 file
/// - PUT    `/screenshot/rename`: đổi tên 1 file
class ScreenshotService {
  /// Folder mặc định của mỗi người dùng.
  static const String defaultFolder = 'main';

  /// Giá trị đại diện cho mục "Tất cả" (xem file của mọi folder). Dùng `*` vì
  /// đây là ký tự không hợp lệ trong tên folder nên không thể trùng folder thật.
  static const String allFolders = '*';

  /// Địa chỉ domain (đã trỏ về server API) dùng cho link copy/gửi cho người
  /// khác. Chỉ dùng để tạo link; app vẫn gọi API qua ApiClient (IP LAN/public).
  static const String shareBaseUrl = 'https://img.vietyqn.vn/api/';

  final ApiClient _api = const ApiClient();

  /// Server thay ký tự không hợp lệ của tên thư mục (\ / : * ? " < > |) bằng
  /// `_`; làm tương tự ở client để chọn đúng folder vừa tạo/đổi tên.
  static String sanitizeFolderName(String name) =>
      name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

  String _query(Map<String, String> params) => params.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  String _fileQuery(String deviceName, String folderName, String fileName) =>
      _query({
        'deviceName': deviceName,
        'folderName': folderName,
        'fileName': fileName,
      });

  // ===== Folder =====

  Future<List<String>> listFolders(String deviceName) async {
    final response = await _api.get(
      'screenshot/folder/list?${_query({'deviceName': deviceName})}',
    );
    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách folder: ${response.body}');
    }
    final List data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((e) => e.toString()).toList();
  }

  /// Trả về HTTP status: 200 thành công, 409 đã tồn tại, 400 tên không hợp lệ.
  Future<int> createFolder(String deviceName, String folderName) async {
    final response = await _api.post(
      'screenshot/folder?${_query({'deviceName': deviceName, 'folderName': folderName})}',
      '',
    );
    return response.statusCode;
  }

  /// Xóa folder và toàn bộ file bên trong (không khôi phục được).
  Future<bool> deleteFolder(String deviceName, String folderName) async {
    final response = await _api.deleteFile(
      'screenshot/folder?${_query({'deviceName': deviceName, 'folderName': folderName})}',
    );
    return response.statusCode == 200;
  }

  /// Trả về HTTP status: 200 thành công, 404 không thấy folder, 409 trùng tên.
  Future<int> renameFolder(
    String deviceName,
    String folderName,
    String newFolderName,
  ) async {
    final response = await _api.put(
      'screenshot/folder/rename?${_query({'deviceName': deviceName, 'folderName': folderName, 'newFolderName': newFolderName})}',
      '',
    );
    return response.statusCode;
  }

  // ===== File =====

  /// Danh sách file của mọi folder thuộc [deviceName] (mỗi file có `folderName`).
  Future<List<ScreenshotInfo>> listByDevice(String deviceName) async {
    final response = await _api.get(
      'screenshot/list-by-device?${_query({'deviceName': deviceName})}',
    );
    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách đã lưu: ${response.body}');
    }
    final List data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((e) => ScreenshotInfo.fromJson(e)).toList();
  }

  Future<List<ScreenshotInfo>> listScreenshots(
    String deviceName,
    String folderName,
  ) async {
    final response = await _api.get(
      'screenshot/list?${_query({'deviceName': deviceName, 'folderName': folderName})}',
    );
    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách đã lưu: ${response.body}');
    }
    final List data = jsonDecode(utf8.decode(response.bodyBytes));
    return data
        .map((e) => ScreenshotInfo.fromJson(e, fallbackFolder: folderName))
        .toList();
  }

  /// Tải nội dung 1 file. Ưu tiên đường dẫn theo [token] (server mới); nếu
  /// không có token hoặc server không trả file thì thử đường dẫn cũ theo
  /// tên người dùng / folder / tên file.
  Future<Uint8List> viewScreenshot(
    String deviceName,
    String folderName,
    String fileName, {
    String token = '',
  }) async {
    if (token.isNotEmpty) {
      final byToken = await _api.get(_tokenPath(token));
      if (byToken.statusCode == 200) return byToken.bodyBytes;
    }
    final response = await _api.get(
      'screenshot/view?${_fileQuery(deviceName, folderName, fileName)}',
    );
    if (response.statusCode != 200) {
      throw Exception('Không thể tải file (HTTP ${response.statusCode})');
    }
    return response.bodyBytes;
  }

  /// Thumbnail của video local (khung hình đầu tiên).
  Future<Uint8List> localVideoThumbnail(String path) async {
    final data = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 160,
      quality: 60,
    );
    if (data == null) throw Exception('Không tạo được thumbnail video');
    return data;
  }

  /// Đường dẫn (tính từ gốc API) xem thẳng 1 file theo mã (token): không chứa
  /// tên người dùng, folder hay tên file và không yêu cầu đăng nhập.
  static String _tokenPath(String token) =>
      'screenshot/i/${Uri.encodeComponent(token)}';

  /// Link để copy gửi cho người khác: `<shareBaseUrl>screenshot/i/<token>`.
  String publicViewLink(String token) => '$shareBaseUrl${_tokenPath(token)}';

  /// Thumbnail của video trên server: để native đọc trực tiếp từ URL
  /// `/screenshot/view` và chỉ tải phần cần để lấy khung hình, không phải
  /// tải cả video về.
  Future<Uint8List> remoteVideoThumbnail(
    String deviceName,
    String folderName,
    String fileName, {
    String token = '',
    int maxWidth = 160,
  }) async {
    final baseUrl = await _api.getBaseUrl();
    final urls = [
      if (token.isNotEmpty)
        '$baseUrl${_tokenPath(token)}',
      '${baseUrl}screenshot/view?${_fileQuery(deviceName, folderName, fileName)}',
    ];
    for (final url in urls) {
      final data = await VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: maxWidth,
        quality: 60,
      );
      if (data != null) return data;
    }
    throw Exception('Không tạo được thumbnail video');
  }

  /// Upload 1 file vào folder (HTTP 200 là thành công). Giữ nguyên tên file
  /// gốc; nếu trùng tên trong folder, server tự thêm hậu tố (1), (2)...
  /// [onProgress] nhận (số byte đã gửi, tổng byte) để hiện thanh tiến độ.
  Future<UploadResult> uploadScreenshot(
    File file,
    String deviceName,
    String folderName, {
    void Function(int sent, int total)? onProgress,
  }) async {
    final streamedResponse = await _api.postFile(
      'screenshot/upload',
      file,
      fields: {'deviceName': deviceName, 'folderName': folderName},
      onProgress: onProgress,
    );
    final response = await http.Response.fromStream(streamedResponse);
    return UploadResult(
      statusCode: response.statusCode,
      body: utf8.decode(response.bodyBytes, allowMalformed: true),
    );
  }

  /// Trả về true nếu xóa thành công (HTTP 200).
  Future<bool> deleteScreenshot(
    String deviceName,
    String folderName,
    String fileName,
  ) async {
    final response = await _api.deleteFile(
      'screenshot/delete?${_fileQuery(deviceName, folderName, fileName)}',
    );
    return response.statusCode == 200;
  }

  /// Trả về true nếu đổi tên thành công (HTTP 200).
  Future<bool> renameScreenshot(
    String deviceName,
    String folderName,
    String fileName,
    String newFileName,
  ) async {
    final response = await _api.put(
      'screenshot/rename?${_fileQuery(deviceName, folderName, fileName)}'
      '&newFileName=${Uri.encodeQueryComponent(newFileName)}',
      '',
    );
    return response.statusCode == 200;
  }
}
