// import 'dart:convert';

import 'dart:convert';

import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/info/DataCheck.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Sheet.model.dart';

class SheetService {
  Future<Map<String, dynamic>> AddSheetWh(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post("dynamic/insert/" + table, body);
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

  Future<List<Sheet>> LoadDtataSheet(String table) async {
    try {
      const apiClient = ApiClient();
      // final DrawerItem item = AppState.instance.get("itemDrawer");

      final response = await apiClient.get("dynamic/get-all/" + table);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Sheet.fromJson(e)).toList();
      } else {
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Map<String, dynamic>> UpdateSheet(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        "dynamic/update-in/" + table + "/SheetAID",
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

  Future<List<DataCheck>> LoadDtataCheck(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final res = await apiClient.post("dynamic/find-array/$table", body);

      final List<dynamic> jsonList = jsonDecode(res.body); // ✅ API trả về List

      // 🔥 API trả về 1 object → bọc thành list
      return jsonList
          .map((e) => DataCheck.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<DataCheck?> getDataCheckById(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/findone/" + table,
        body,
        // jsonEncode({"productID": id}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          return null;
        }
        return DataCheck.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      print("ở đay data");
      return null;
    }
  }

  Future<Map<String, dynamic>> upDateDataCheck(
    String table,
    String id,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        "dynamic/update/" + table + "/CheckAID/" + id.toString(),
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

  Future<Sheet?> findSheet(
    String table,
    String column,
    String condition,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/$table/$column/$condition",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Sheet.fromJson(data.first);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
