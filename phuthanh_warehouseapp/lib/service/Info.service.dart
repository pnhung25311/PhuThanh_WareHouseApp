import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Employee.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Location.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Unit.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Category.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';

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

  static Future<List<Supplier>> LoadDtataSupplierCategory(
    String condition,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/supplier/category/" + condition,
      );

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

  static Future<List<Employee>> LoadDtataEmployee() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Employee");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Employee.fromJson(e)).toList();
      } else {
        print("=======>" + response.statusCode.toString());
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<VehicleType>> LoadDtataVehicleType() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/VehicleType");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => VehicleType.fromJson(e)).toList();
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
      final response = await apiClient.get("dynamic/get-all/Manufacturer");

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
      final response = await apiClient.get("dynamic/get-all/Unit");

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

  static Future<String> addAppendix(String table, String body) async {
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

  static Future<List<Product>> LoadProduct() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Product");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // print(data);
        return data.map((e) => Product.fromJson(e)).toList();
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

  static Future<String> addProduct(String table, String body) async {
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

  static Future<Product?> findProduct(String condition) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/Product/ProductID/$condition",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return Product.fromJson(data.first);
        }
        return null;
      } else {
        print("=======> ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map<String, dynamic>> UpdateProduct(
    String condition,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        "dynamic/update/Product/ProductAID/$condition",
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

  static Future<Map<String, dynamic>> getAllPages(int pages, int size) async {
    const apiClient = ApiClient();
    final response = await apiClient.get(
      "dynamic/get-all/pages/Product?page=${pages}&size=$size"
    );
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": response.body,
      };
  }
}
