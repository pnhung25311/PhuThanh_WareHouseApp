import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/tapdoan/Company.model.dart';

List<TonKhoCty> _parseTonKho(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) return <TonKhoCty>[];
  return decoded.map((e) => TonKhoCty.fromJson(e as Map<String, dynamic>)).toList();
}

/// Các API kho tập đoàn: 5 công ty dùng chung 1 bộ endpoint `*-cty/{kho}`,
/// phân biệt kho con bằng `warehouseId`. Xuất kho không có endpoint riêng ở
/// đây — dùng `LichSuKhoService.addHistory` (qty âm) như màn chuyển kho cũ.
class KhoTapDoanService {
  /// Danh mục kho con — `GET /api/dm-kho`.
  Future<Map<String, dynamic>> getSubWarehouses() async {
    try {
      final response = await const ApiClient().get('dm-kho');
      if (response.statusCode != 200) {
        return {"isSuccess": false, "statusCode": response.statusCode, "body": <SubWarehouse>[]};
      }
      final decoded = jsonDecode(response.body);
      final items = decoded is List
          ? decoded.map((e) => SubWarehouse.fromJson(e as Map<String, dynamic>)).toList()
          : <SubWarehouse>[];
      return {"isSuccess": true, "statusCode": response.statusCode, "body": items};
    } catch (e) {
      print("ERROR getSubWarehouses: $e");
      return {"isSuccess": false, "statusCode": 0, "body": <SubWarehouse>[]};
    }
  }

  /// Tồn kho của 1 kho con thuộc công ty `khoCode`.
  Future<Map<String, dynamic>> getInventory(String khoCode, int warehouseId) async {
    try {
      final response = await const ApiClient().get('ton-kho-cty/$khoCode?warehouseId=$warehouseId');
      if (response.statusCode != 200) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
          "body": <TonKhoCty>[],
        };
      }
      final items = await compute(_parseTonKho, response.body);
      return {"isSuccess": true, "statusCode": response.statusCode, "body": items};
    } catch (e) {
      print("ERROR getInventory (cty): $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString(), "body": <TonKhoCty>[]};
    }
  }

  /// Nhập kho — server tự cộng vào dòng tồn có sẵn hoặc tạo dòng mới.
  Future<Map<String, dynamic>> nhapKho({
    required String khoCode,
    required int warehouseId,
    required int productAid,
    required double qty,
    String? location,
    String? remark,
    required int createUser,
  }) {
    return _post('nhap-kho-cty/$khoCode', {
      'warehouseId': warehouseId,
      'productAid': productAid,
      'qty': qty,
      'location': location,
      'remark': remark,
      'createUser': createUser,
    });
  }

  /// Xuất điều chuyển 1 dòng tồn nguồn sang kho con khác cùng công ty — 1
  /// transaction phía server (trừ nguồn, cộng đích, ghi 2 dòng lịch sử).
  Future<Map<String, dynamic>> dieuChuyen({
    required String khoCode,
    required int sourceDataWareHouseAid,
    required int destWarehouseId,
    required double qty,
    int? employeeId,
    String? remark,
    required String time,
    required int createUser,
  }) {
    return _post('xuat-dieu-chuyen-cty/$khoCode', {
      'sourceDataWareHouseAid': sourceDataWareHouseAid,
      'destWarehouseId': destWarehouseId,
      'qty': qty,
      if (employeeId != null) 'employeeId': employeeId,
      'remark': remark,
      'time': time,
      'createUser': createUser,
    });
  }

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await const ApiClient().post(endpoint, jsonEncode(body));
      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }
      return {"isSuccess": true, "statusCode": response.statusCode};
    } catch (e) {
      print("ERROR $endpoint: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] is String) return decoded['message'] as String;
      if (decoded is String) return decoded;
    } catch (_) {}
    return body.isNotEmpty ? body : 'Đã xảy ra lỗi không xác định';
  }
}
