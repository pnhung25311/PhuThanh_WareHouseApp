import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Location.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Unit.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Category.model.dart';

class InfoService {
  static Future<List<Country>> LoadDtataCountry() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Country");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Country.fromJson(e)).toList();
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

  static Future<List<Supplier>> LoadDtataSupplier() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Supplier");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Supplier.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<Manufacturer>> LoadDtataManufacturer() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Country");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Manufacturer.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<Unit>> LoadDtataUnit() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Country");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Unit.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<Location>> fetchLocations() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Location");
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Location.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<Category>> getAllCategory() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Category");
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Category.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<String> addAppendix(String table, Map<String, dynamic> body) async {
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
}
