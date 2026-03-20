import 'dart:convert';

import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/business/History.model.dart';

class Businessservice {
  final ApiClient client = const ApiClient();

  Future<Map<String, dynamic>> getHistoryExport(String maVt) async {
    try {
      final response = await client.get("business/ct90-history/$maVt");
      final List<dynamic> data = jsonDecode(response.body);

      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => HistoryBusiness.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {
        "isSuccess": false,
        "statusCode": 0,
        "body": <HistoryBusiness>[], // luôn trả list
      };
    }
  }

  Future<Map<String, dynamic>> getHistoryImport(String maVt) async {
    try {
      final response = await client.get("business/ct70y-history/$maVt");
      final List<dynamic> data = jsonDecode(response.body);

      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => HistoryBusiness.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {
        "isSuccess": false,
        "statusCode": 0,
        "body": <HistoryBusiness>[], // luôn trả list
      };
    }
  }

  Future<Map<String, dynamic>> getAllHistory(String table) async {
    try {
      final response = await client.get("business/$table");
      final List<dynamic> data = jsonDecode(response.body);

      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => HistoryBusiness.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {
        "isSuccess": false,
        "statusCode": 0,
        "body": <HistoryBusiness>[], // luôn trả list
      };
    }
  }

  Future<Map<String, dynamic>> upDateCart(
    String table,
    String id,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        "dynamic/update/" + table + "/CartAID/" + id.toString(),
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
