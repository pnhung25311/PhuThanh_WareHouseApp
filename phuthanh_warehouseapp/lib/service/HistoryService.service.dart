import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/History.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/ViewHistory.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class HistoryService {
  static Future<List<ViewHistory>> LoadDtata(String condition) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find-history/vwHistory"+AppState.instance.get("StatusHome")+"/DataWareHouseAID/" + condition,
      );
      print("dynamic/find-history/History"+AppState.instance.get("StatusHome")+"/DataWareHouseAID/" + condition);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ViewHistory.fromJson(e)).toList();
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

  static Future<History?> FindByIDHistory(String condition) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/history/productID/" + condition,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return History.fromJson(data);
      } else {
        print("=======>" + response.statusCode.toString());
        // throw Exception("Failed to load data (${response.statusCode})");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map<String, dynamic>> AddHistory(
    String table,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert/history" +
            AppState.instance.get("StatusHome") +
            "/" +
            table,
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
}
