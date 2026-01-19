import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class Warehouseservice {
  NavigationHelper navigationHelper = NavigationHelper();

  Future<Map<String, dynamic>> LoadDtata(String table) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/" + table);

      final List<dynamic> data = jsonDecode(response.body);
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => WareHouse.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }

  Future<Map<String, dynamic>> LoadDtataLimit(
    String table,
    String limit,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/get-all/" + table + "/" + limit,
      );

      final List<dynamic> data = jsonDecode(response.body);
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => WareHouse.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }

  Future<Map<String, dynamic>> getWarehouseById(String table, String id) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/find/" + table,
        jsonEncode({"productID": id}),
      );

      final List<dynamic> data = jsonDecode(response.body);
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => WareHouse.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }


    //   if (response.statusCode == 200) {
    //     final Map<String, dynamic> data = jsonDecode(response.body);
    //     if (data.isEmpty) {
    //       return null;
    //     }
    //     return WareHouse.fromJson(data);
    //   } else {
    //     return null;
    //   }
    // } catch (e) {
    //   print("ở wh" + e.toString());
    //   return null;
    // }
  }

  Future<Map<String, dynamic>> upDateWareHouse(
    String table,
    String id,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        "dynamic/update/" + table + "/dataWareHouseAID/" + id.toString(),
        body,
      );

      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": response.body,
      };
    } catch (e) {
      print(e);
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }

  Future<List<WareHouse>> searchWareHouse(String table, String keyWord) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/search/" + table + "/" + keyWord,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => WareHouse.fromJson(e)).toList();
      } else {
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<DrawerItem>> getItemhWareHouse() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/tables");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return (data as List).map((json) => DrawerItem.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("ERROR getItemhWareHouse: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> addWarehouseRow(
    String table,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert/" + table.toString(),
        body,
      );
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": response.body,
      };
    } catch (e) {
      // log nếu cần
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }

  Future<WareHouse?> FindByIDWareHouse(String condition) async {
    try {
      const apiClient = ApiClient();
      final table = AppState.instance.get("StatusHome");
      final safeTable = table ?? "Product";
      final response = await apiClient.get(
        "dynamic/find/vw$safeTable/productID/$condition",
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
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Lỗi FindByIDWareHouse: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> LoadDtataLimitProduct(String limit) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/get-all/vwProduct/" + limit,
      );

      // if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // } else if (response.statusCode == 200) {
      //   navigationHelper.pushAndRemoveUntil(context, const HomeScreen());
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => Product.fromJson(e)).toList(),
      };
      // } else {
      //   // throw Exception("Failed to load data (${response.statusCode})");
      //   return [];
      // }
    } catch (e) {
      print(e);
      // return [];
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }
}
