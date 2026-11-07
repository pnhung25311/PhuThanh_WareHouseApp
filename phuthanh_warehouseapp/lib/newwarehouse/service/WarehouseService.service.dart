import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/WarehouseInventoryItem.model.dart';

/// Chạy trong isolate riêng qua `compute()` — kho chính có thể có hàng chục
/// nghìn dòng, decode + map JSON đồng bộ trên main isolate sẽ treo UI.
List<WarehouseInventoryItem> _parseInventoryItems(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) return <WarehouseInventoryItem>[];
  return decoded
      .map((e) => WarehouseInventoryItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

class WarehouseService {
  /// Tồn kho của 1 trong 6 kho cố định — mỗi kho có endpoint riêng
  /// (`Warehouse.inventoryEndpoint`, ví dụ `ton-kho/dmvt-lk`).
  Future<Map<String, dynamic>> getInventory(String endpoint) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(endpoint);

      if (response.statusCode != 200) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "body": <WarehouseInventoryItem>[],
        };
      }

      final items = await compute(_parseInventoryItems, response.body);
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "body": items,
      };
    } catch (e) {
      print("ERROR getInventory: $e");
      return {
        "isSuccess": false,
        "statusCode": 0,
        "body": <WarehouseInventoryItem>[],
      };
    }
  }

  /// Kiểm tra 1 vật tư (`productAid`) đã có dòng tồn kho tại kho `khoCode`
  /// chưa — `GET /api/ton-kho/{kho}/kiem-tra/{id}`. Bắt buộc gọi trước khi
  /// ghi lịch sử nhập/xuất/điều chuyển để lấy đúng `dataWareHouseAid`: thiếu
  /// field này thì server bỏ qua luôn bước cập nhật `Qty` tồn kho.
  Future<Map<String, dynamic>> checkMaterialInWarehouse(
    String khoCode,
    int productAid,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        'ton-kho/$khoCode/kiem-tra/$productAid',
      );

      if (response.statusCode != 200) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "exists": false,
          "dataWareHouseAid": null,
        };
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "exists": false,
          "dataWareHouseAid": null,
        };
      }

      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "exists": decoded['exists'] == true,
        "dataWareHouseAid": (decoded['dataWareHouseAid'] as num?)?.toInt(),
      };
    } catch (e) {
      print("ERROR checkMaterialInWarehouse: $e");
      return {
        "isSuccess": false,
        "statusCode": 0,
        "exists": false,
        "dataWareHouseAid": null,
      };
    }
  }

  /// Tạo mới 1 dòng tồn kho cho vật tư `productAid` tại kho `khoCode` —
  /// `POST /api/nhap-kho/{kho}`. Dùng khi vật tư chưa từng xuất hiện ở kho đó
  /// (theo `checkMaterialInWarehouse`), trước khi ghi lịch sử nhập/xuất/điều
  /// chuyển. `qty` ở đây chỉ là giá trị khởi tạo — `Qty` thật sự sẽ được
  /// server tính lại (SUM lịch sử) ngay khi có dòng lịch sử đầu tiên.
  Future<Map<String, dynamic>> nhapKho({
    required String khoCode,
    required int productAid,
    double qty = 0,
    String? location,
    String? remark,
    required int createUser,
  }) async {
    try {
      const apiClient = ApiClient();
      final body = jsonEncode({
        'productAid': productAid,
        'qty': qty,
        'location': location,
        'remark': remark,
        'createUser': createUser,
      });
      final response = await apiClient.post('nhap-kho/$khoCode', body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": _extractErrorMessage(response.body),
        };
      }

      final decoded = _tryDecode(response.body);
      final dataWareHouseAid = (decoded is Map)
          ? (decoded['dataWareHouseAid'] as num?)?.toInt()
          : null;
      if (dataWareHouseAid == null) {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "message": 'Server không trả về dataWareHouseAid sau khi nhập kho',
        };
      }
      return {
        "isSuccess": true,
        "statusCode": response.statusCode,
        "dataWareHouseAid": dataWareHouseAid,
      };
    } catch (e) {
      print("ERROR nhapKho: $e");
      return {"isSuccess": false, "statusCode": 0, "message": e.toString()};
    }
  }

  /// Cập nhật 1 dòng tồn kho đã có — `PUT /api/ton-kho/{kho}/{id}`
  /// (`id` = `DataWareHouseAID`). API này set thẳng cả `qty`, nên khi chỉ
  /// muốn sửa vị trí/ghi chú, luôn truyền lại `qty` hiện tại (không đổi) để
  /// tránh làm lệch số tồn — số tồn thật chỉ nên đổi qua API lịch sử.
  Future<Map<String, dynamic>> capNhatTonKho({
    required String khoCode,
    required int dataWareHouseAid,
    required double qty,
    String? location,
    String? remark,
    required int updateUser,
  }) async {
    try {
      const apiClient = ApiClient();
      final body = jsonEncode({
        'qty': qty,
        'location': location,
        'remark': remark,
        'updateUser': updateUser,
      });
      final response = await apiClient.put(
        'ton-kho/$khoCode/$dataWareHouseAid',
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
      print("ERROR capNhatTonKho: $e");
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
