import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/History.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/ViewHistory.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class HistoryService {
  Future<List<ViewHistory>> LoadDtata(String condition) async {
    try {
      const apiClient = ApiClient();
      final DrawerItem item = AppState.instance.get("itemDrawer");

      final response = await apiClient.get(
        "dynamic/find-history/vw" +
            item.wareHouseDataBaseHistory.toString() +
            "/DataWareHouseAID/" +
            condition,
      );
      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(data.map((e) => ViewHistory.fromJson(e)).toList());
        return data.map((e) => ViewHistory.fromJson(e)).toList();
      } else {
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print("====================");
      print(e);
      return [];
    }
  }

  Future<History?> FindByIDHistory(String condition) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/history/productID/" + condition,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return History.fromJson(data);
      } else {
        // throw Exception("Failed to load data (${response.statusCode})");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>> AddHistory(
    String table,
    String tableWh,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert/" + table + "/" + tableWh,
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
