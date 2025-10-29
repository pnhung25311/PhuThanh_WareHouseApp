import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/History.dart';

class HistoryService {
  static Future<List<History>> LoadDtata(String condition) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/vwWareHouseHistory/productID/" + condition,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => History.fromJson(e)).toList();
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
      final response = await apiClient.get("dynamic/find/history/productID/" + condition);

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

}
