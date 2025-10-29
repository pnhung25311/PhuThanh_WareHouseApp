import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/system/StatusSystem.model.dart';

class StatusSystemService {
  static Future<List<StatusSystem>> GetAllStatusSystem() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/StatusSystem");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => StatusSystem.fromJson(e)).toList();
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
}
