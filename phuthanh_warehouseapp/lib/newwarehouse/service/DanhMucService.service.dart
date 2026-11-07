import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/DanhMuc.model.dart';
import 'package:phuthanh_warehouseapp/model/shared/Employee.model.dart';

/// Danh mục tra cứu read-only: hãng SX, hãng xe, nước SX, khách hàng/NCC (4 API
/// riêng cho module kho mới), cộng thêm danh sách nhân viên (API dynamic dùng
/// chung với hệ thống cũ). Không có CRUD phía server — chỉ đọc để đổ
/// dropdown/màn xem phụ lục.
class DanhMucService {
  Future<Map<String, dynamic>> getAllHangSx() async {
    return _getAll('get-all-dmhangsx', Manufacturer.fromJson);
  }

  Future<Map<String, dynamic>> getAllHangXe() async {
    return _getAll('get-all-dmhangxe', VehicleBrand.fromJson);
  }

  Future<Map<String, dynamic>> getAllNuocSx() async {
    return _getAll('get-all-dmnuocsx', Country.fromJson);
  }

  Future<Map<String, dynamic>> getAllKhachHang() async {
    return _getAll('get-all-dmkh', Customer.fromJson);
  }

  Future<Map<String, dynamic>> getAllEmployees() async {
    return _getAll('dynamic/get-all/Employee', Employee.fromJson);
  }

  /// Đồng bộ danh mục từ nguồn gốc (ERP/hệ thống khác) về server.
  Future<Map<String, dynamic>> syncDanhMuc() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post('dong-bo-danh-muc', '');

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": response.body.isNotEmpty
              ? response.body
              : 'Đồng bộ thất bại',
        };
      }
      return {"isSuccess": true, "statusCode": response.statusCode};
    } catch (e) {
      print("ERROR syncDanhMuc: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> _getAll<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(endpoint);

      if (response.statusCode != 200) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "body": <T>[],
        };
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "body": <T>[],
        };
      }

      final items = decoded
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "body": items,
      };
    } catch (e) {
      print("ERROR DanhMucService.$endpoint: $e");
      return {"isSuccess": false, "statusCode": 0, "body": <T>[]};
    }
  }
}
