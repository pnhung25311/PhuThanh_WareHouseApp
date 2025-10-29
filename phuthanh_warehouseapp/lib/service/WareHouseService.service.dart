import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';

class Warehouseservice {
  static Future<List<WareHouse>> LoadDtata(String table) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/" + table);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => WareHouse.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<WareHouse>> LoadDtataLimit(
    String table,
    String limit,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/get-all/" + table + "/" + limit,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => WareHouse.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<WareHouse?> getWarehouseById(String id) async {
    try {
      const apiClient = ApiClient();
      final table = await MySharedPreferences.getDataString("statusWH");
      final safeTable = table ?? "WareHouseA";
      final response = await apiClient.post("dynamic/find/" + safeTable, {
        "productID": id,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WareHouse.fromJson(data);
      } else {
        print("=======>" + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<WareHouse?> upDateWareHouse(
    String id,
    Map<String, dynamic> wh,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        "dynamic/update/warehousea/productID/" + id.toString(),
        wh,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WareHouse.fromJson(data);
      } else {
        print("=======>" + response.statusCode.toString());
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<WareHouse>> searchWareHouse(
    String table,
    String keyWord,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/search/" + table + "/" + keyWord,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => WareHouse.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<String>> getItemhWareHouse() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/tables");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data);
      } else {
        print("=======>" + response.statusCode.toString());
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<String> addWarehouseRow(
    String table,
    Map<String, dynamic> body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert/" + table.toString(),
        body,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("=======>" + response.statusCode.toString());
        return "";
      }
    } catch (e) {
      // log nếu cần
      print(e);
      return "";
    }
  }

  static Future<WareHouse?> FindByIDWareHouse(String condition) async {
    try {
      const apiClient = ApiClient();
      final table = await MySharedPreferences.getDataString("statusWH");
      final safeTable = table ?? "WareHouseA";
      final response = await apiClient.get(
        "dynamic/find/$safeTable/productID/$condition",
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List && body.isNotEmpty) {
          // ✅ API trả về danh sách
          return WareHouse.fromJson(body[0]);
        } else if (body is Map<String, dynamic>) {
          // ✅ API trả về 1 object
          return WareHouse.fromJson(body);
        } else {
          print("⚠️ Không có dữ liệu phù hợp");
          return null;
        }
      } else {
        print("❌ Lỗi HTTP ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi FindByIDWareHouse: $e");
      return null;
    }
  }
}
