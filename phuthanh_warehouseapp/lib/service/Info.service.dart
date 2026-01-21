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
  Future<List<Country>> LoadDtataCountry() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Country");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Country.fromJson(e)).toList();
      } else {
        // throw Exception("Failed to load data (${response.statusCode})");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Supplier>> LoadDtataSupplier() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Supplier");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Supplier.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Supplier>> LoadDtataSupplierCategory(String condition) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/supplier/category/" + condition,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Supplier.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Employee>> LoadDtataEmployee() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Employee");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Employee.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<VehicleType>> LoadDtataVehicleType() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/VehicleType");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => VehicleType.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Manufacturer>> LoadDtataManufacturer() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Manufacturer");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Manufacturer.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Unit>> LoadDtataUnit() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Unit");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Unit.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Location>> fetchLocations() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Location");
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Location.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Category>> getAllCategory() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/Category");
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Category.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> addAppendix(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert/" + table.toString(),
        body,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "";
      }
    } catch (e) {
      // log nếu cần
      print(e);
      return "";
    }
  }

  Future<Map<String, dynamic>> LoadProduct() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get("dynamic/get-all/vwProduct");

      final List<dynamic> data = jsonDecode(response.body);
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => Product.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }

  Future<String> addProduct(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert/" + table.toString(),
        body,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "";
      }
    } catch (e) {
      // log nếu cần
      print(e);
      return "";
    }
  }

  Future<bool> checkProductID(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/check-exists/" + table.toString(),
        body,
      );
      if (response.body == "true") {
        print("Mã đã tồn tại");
        return true;
      } else {
        print("Mã chưa tồn tại");
        return false;
      }
    } catch (e) {
      // log nếu cần
      print(e);
      // return "";
      return true;
    }
  }

  Future<Map<String, dynamic>> findProduct(String condition) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/find/Product/ProductID/$condition",
      );

      final List<dynamic> data = jsonDecode(response.body);
      print("==================>");
      print(data);
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": Product.fromJson(data.first),
      };
    } catch (e) {
      print("==================>");
      print(e);
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }

  Future<Map<String, dynamic>> UpdateProduct(
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

  Future<List<Product>> getAllPages(int size, int threads) async {
    const apiClient = ApiClient();

    try {
      final response = await apiClient.get(
        "dynamic/get-all/pages/vwProduct?size=$size&threads=$threads",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("[API] ⚠️ Exception at: $e");
      return [];
    }
  }

  Future<List<Product>> fetchAllProducts({int size = 50}) async {
    final stopwatchTotal = Stopwatch()..start();

    List<Product> allProducts = [];
    int page = 0;
    bool hasMore = true;

    try {
      // Gọi batch đầu tiên để biết tổng số trang
      List<Product> firstBatch = await getAllPages(page, size);
      allProducts.addAll(firstBatch);

      if (firstBatch.length < size) {
        stopwatchTotal.stop();
        return allProducts;
      }

      page++;
      int parallelBatch = 5; // bạn có thể đổi sang 10, 20, 50...

      while (hasMore) {
        final batchStopwatch = Stopwatch()..start();

        List<Future<List<Product>>> batchFutures = [];
        for (int i = 0; i < parallelBatch; i++) {
          batchFutures.add(getAllPages(page + i, size));
        }

        // Chạy song song
        List<List<Product>> results = await Future.wait(batchFutures);

        batchStopwatch.stop();

        // Gộp kết quả
        for (var batch in results) {
          allProducts.addAll(batch);
          if (batch.length < size) {
            hasMore = false;
            break;
          }
        }

        page += parallelBatch;
      }

      stopwatchTotal.stop();
      return allProducts;
    } catch (e) {
      print("❌ Error fetching all products: $e");
      return allProducts;
    }
  }

  Future<int> reTurnAIDWhToAddHistory(
    String table,
    String columnCondition,
    String condition,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/getAID/" +
            table +
            "/DataWareHouseAID/" +
            columnCondition +
            "/" +
            condition,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return 0;
      }
    } catch (e) {
      print("ERROR getItemhWareHouse: $e");
      return 0;
    }
  }

  Future<double> reTurnQtyWhToAddHistory(String table, int condition) async {
    try {
      print("object");
      const apiClient = ApiClient();
      final response = await apiClient.get(
        "dynamic/returnQty/" + table + "/" + condition.toString(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data;
      } else {
        return 0;
      }
    } catch (e) {
      print("ERROR getItemhWareHouse: $e");
      return 0;
    }
  }
}
