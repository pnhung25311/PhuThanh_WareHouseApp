import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/LichSuKho.model.dart';

/// Chạy trong isolate riêng qua `compute()` — 1 kho có thể tích luỹ rất nhiều
/// dòng lịch sử theo thời gian, decode + map JSON đồng bộ có thể treo UI.
List<LichSuKho> _parseLichSuKhoList(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) return <LichSuKho>[];
  return decoded
      .map((e) => LichSuKho.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// CRUD lịch sử nhập/xuất kho — dùng chung 1 bộ API cho cả 6 kho, phân biệt
/// bằng path variable `{kho}` (`dmvt`, `dmvt-lk`, `dmvt-kd`, `dmvt-397`, `dmvt-ks`).
class LichSuKhoService {
  Future<Map<String, dynamic>> getHistory(String khoCode) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get('lich-su-kho/$khoCode');

      if (response.statusCode != 200) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "body": <LichSuKho>[],
        };
      }

      final items = await compute(_parseLichSuKhoList, response.body);
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "body": items,
      };
    } catch (e) {
      print("ERROR getHistory: $e");
      return {"isSuccess": false, "statusCode": 0, "body": <LichSuKho>[]};
    }
  }

  /// Thêm 1 dòng lịch sử nhập/xuất mới. Server tự set `LastTime`. Tất cả
  /// field đều optional theo tài liệu, nhưng nên luôn truyền `qty`, `time`,
  /// `createUser` để dữ liệu có ý nghĩa.
  Future<Map<String, dynamic>> addHistory({
    required String khoCode,
    int? dataWareHouseAid,
    double? qty,
    int? employeeId,
    String? ncc,
    String? remark,
    String? time,
    String? transferGroupId,
    String? noLot,
    int? createUser,
  }) async {
    try {
      const apiClient = ApiClient();
      final body = jsonEncode({
        if (dataWareHouseAid != null) 'dataWareHouseAid': dataWareHouseAid,
        if (qty != null) 'qty': qty,
        if (employeeId != null) 'employeeId': employeeId,
        if (ncc != null && ncc.isNotEmpty) 'ncc': ncc,
        if (remark != null) 'remark': remark,
        if (time != null) 'time': time,
        if (transferGroupId != null) 'transferGroupId': transferGroupId,
        if (noLot != null) 'noLot': noLot.trim(),
        if (createUser != null) 'createUser': createUser,
      });
      final response = await apiClient.post('lich-su-kho/$khoCode', body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }

      final decoded = _tryDecode(response.body);
      final historyAid = (decoded is Map)
          ? (decoded['historyAid'] as num?)?.toInt()
          : null;
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "historyAid": historyAid,
      };
    } catch (e) {
      print("ERROR addHistory: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  /// Sửa 1 dòng lịch sử đã có (`historyAid` = `HistoryAID`).
  Future<Map<String, dynamic>> updateHistory({
    required String khoCode,
    required int historyAid,
    int? dataWareHouseAid,
    double? qty,
    int? employeeId,
    String? ncc,
    String? remark,
    String? time,
    String? transferGroupId,
    String? noLot,
    int? updateUser,
  }) async {
    try {
      const apiClient = ApiClient();
      final body = jsonEncode({
        if (dataWareHouseAid != null) 'dataWareHouseAid': dataWareHouseAid,
        if (qty != null) 'qty': qty,
        if (employeeId != null) 'employeeId': employeeId,
        if (ncc != null && ncc.isNotEmpty) 'ncc': ncc,
        if (remark != null) 'remark': remark,
        if (time != null) 'time': time,
        if (transferGroupId != null) 'transferGroupId': transferGroupId,
        // PUT ghi đè noLot như các field khác — luôn gửi lại giá trị hiện tại.
        if (noLot != null) 'noLot': noLot.trim(),
        if (updateUser != null) 'updateUser': updateUser,
      });
      final response = await apiClient.put(
        'lich-su-kho/$khoCode/$historyAid',
        body,
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
      print("ERROR updateHistory: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteHistory(
    String khoCode,
    int historyAid, {
    int? updateUser,
  }) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.delete(
        'lich-su-kho/$khoCode/$historyAid'
            '${updateUser != null ? '?updateUser=$updateUser' : ''}',
        '',
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
      print("ERROR deleteHistory: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  /// Xuất điều chuyển giữa 2 kho — `POST /api/dieu-chuyen-kho`. Server ghi
  /// 2 dòng lịch sử (âm ở nguồn, dương ở đích) cùng `noLot` + `TransferGroupID`
  /// trong 1 transaction, tự tạo dòng tồn kho đích nếu chưa có và tính lại tồn
  /// cả 2 bên. Chỉ áp dụng cho 6 kho dmvt, dmvt-lk, dmvt-kd, dmvt-397, dmvt-ks,
  /// dmvt-cty. Lỗi 400: thiếu field, qty <= 0, trùng kho, không đủ tồn; 404:
  /// không thấy dòng tồn kho nguồn.
  Future<Map<String, dynamic>> dieuChuyenKho({
    required String sourceKho,
    required int sourceDataWareHouseAid,
    required String destKho,
    required double qty,
    String? noLot,
    int? employeeId,
    String? remark,
    String? time,
    int? createUser,
  }) async {
    try {
      const apiClient = ApiClient();
      final body = jsonEncode({
        'sourceKho': sourceKho,
        'sourceDataWareHouseAid': sourceDataWareHouseAid,
        'destKho': destKho,
        'qty': qty,
        if (noLot != null && noLot.trim().isNotEmpty) 'noLot': noLot.trim(),
        if (employeeId != null) 'employeeId': employeeId,
        if (remark != null && remark.isNotEmpty) 'remark': remark,
        if (time != null) 'time': time,
        if (createUser != null) 'createUser': createUser,
      });
      final response = await apiClient.post('dieu-chuyen-kho', body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }

      final decoded = _tryDecode(response.body);
      final map = decoded is Map ? decoded : const {};
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "transferGroupId": map['transferGroupId']?.toString(),
        "sourceQtyConLai": (map['sourceQtyConLai'] as num?)?.toDouble(),
        "destQtyMoi": (map['destQtyMoi'] as num?)?.toDouble(),
      };
    } catch (e) {
      print("ERROR dieuChuyenKho: $e");
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
    if (decoded is String) return decoded;
    return body.isNotEmpty ? body : 'Đã xảy ra lỗi không xác định';
  }
}
