import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';

/// Chạy trong isolate riêng qua `compute()` — bảng vật tư có thể có hàng
/// chục nghìn dòng, decode + map JSON đồng bộ trên main isolate sẽ treo UI.
List<Dmvt> _parseDmvtList(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) return <Dmvt>[];
  return decoded.map((e) => Dmvt.fromJson(e as Map<String, dynamic>)).toList();
}

class DmvtService {
  /// Upload 1 file ảnh (chọn từ thư viện hoặc chụp trực tiếp) lên server cho
  /// vật tư có mã `maVt`, trả về URL để lưu vào `img1/img2/img3`. `imageSlot`
  /// là 1/2/3 — file gửi lên được đổi tên thành `img1`/`img2`/`img3` (giữ
  /// nguyên đuôi mở rộng) tương ứng ô ảnh đang upload.
  Future<Map<String, dynamic>> uploadImage(
    String maVt,
    File file,
    int imageSlot,
  ) async {
    try {
      const apiClient = ApiClient();
      final dotIndex = file.path.lastIndexOf('.');
      final ext = dotIndex != -1 ? file.path.substring(dotIndex) : '';
      final streamedResponse = await apiClient.postFile(
        'upload/$maVt',
        file,
        filename: 'img$imageSlot$ext',
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }

      // Server trả về thẳng chuỗi URL (không bọc JSON) — gắn thẳng vào img1/2/3.
      final url = response.body.trim();
      if (url.isEmpty) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": "Server không trả về URL ảnh sau khi upload",
        };
      }
      return {"isSuccess": true, "statusCode": response.statusCode, "url": url};
    } catch (e) {
      print("ERROR uploadImage: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAllDmvt() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get('get-all-dmvt');

      if (response.statusCode != 200) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "body": <Dmvt>[],
        };
      }

      final items = await compute(_parseDmvtList, response.body);
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "body": items,
      };
    } catch (e) {
      print("ERROR getAllDmvt: $e");
      return {"isSuccess": false, "statusCode": 0, "body": <Dmvt>[]};
    }
  }

  Future<Map<String, dynamic>> createMaterial(Dmvt material) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        'materials',
        jsonEncode(material.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "body": jsonDecode(response.body),
      };
    } catch (e) {
      print("ERROR createMaterial: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  /// `ma_vt` không được sửa sau khi tạo — server sẽ từ chối nếu client cố đổi,
  /// nên hàm này chỉ dùng để cập nhật các trường còn lại.
  Future<Map<String, dynamic>> updateMaterial(int aid, Dmvt material) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        'update-dmvt/$aid',
        jsonEncode(material.toJson()),
      );

      if (response.statusCode != 200) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }
      return {"isSuccess": true, "statusCode": response.statusCode};
    } catch (e) {
      print("ERROR updateMaterial: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteMaterial(int aid) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.delete('delete-dmvt/$aid', '');

      if (response.statusCode != 200 && response.statusCode != 204) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }
      return {"isSuccess": true, "statusCode": response.statusCode};
    } catch (e) {
      print("ERROR deleteMaterial: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  /// Thêm mới hàng loạt vật tư — server validate-all-or-nothing: nếu có bất kỳ
  /// dòng nào lỗi thì không dòng nào được tạo. `errors` (nếu có) trả về theo
  /// từng dòng để hiển thị lại trên preview cho người dùng sửa.
  Future<Map<String, dynamic>> bulkCreateMaterials(List<Dmvt> materials) async {
    try {
      const apiClient = ApiClient();
      final body = jsonEncode({
        'items': materials.map((m) => m.toJson()).toList(),
      });
      final response = await apiClient.post('materials/bulk', body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final decoded = _tryDecode(response.body);
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
          "errors": (decoded is Map && decoded['errors'] is List)
              ? decoded['errors']
              : null,
        };
      }
      return {"isSuccess": true, "statusCode": response.statusCode};
    } catch (e) {
      print("ERROR bulkCreateMaterials: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(String body) {
    final decoded = _tryDecode(body);
    if (decoded is Map && decoded['message'] is String)
      return decoded['message'] as String;
    return body.isNotEmpty ? body : 'Đã xảy ra lỗi không xác định';
  }
}
