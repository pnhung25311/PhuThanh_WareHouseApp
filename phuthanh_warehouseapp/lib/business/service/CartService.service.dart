import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';

class CartService {
  final ApiClient client = const ApiClient();

  Future<Map<String, dynamic>> LoadCart() async {
    try {
      final response = await client.get("dynamic/get-all/vwProduct");

      final List<dynamic> data = jsonDecode(response.body);
      return {
        "isSuccess": response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": data.map((e) => Cart.fromJson(e)).toList(),
      };
    } catch (e) {
      print(e);
      return {"isSuccess": false, "statusCode": 0, "body": e.toString()};
    }
  }

  Future<Map<String, dynamic>> addCart(
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert/Cart",
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

   Future<Map<String, dynamic>> addCartBatch(
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.post(
        "dynamic/insert-batch/Cart",
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
  /// Lấy tất cả giỏ hàng (hoặc theo filter nếu API hỗ trợ)
  Future<Map<String, dynamic>> getAllCarts() async {
    try {
      // Thay endpoint thật của bạn, ví dụ: "carts", "business/carts", "orders/carts"...
      final response = await client.get(
        "dynamic/get-all/vwCart",
      ); // ← thay endpoint này

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final carts = data.map((e) => Cart.fromJson(e)).toList();

        return {
          "isSuccess": true,
          "statusCode": response.statusCode,
          "body": carts,
        };
      } else {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "body": <Cart>[],
        };
      }
    } catch (e) {
      print('Error fetching carts: $e');
      return {"isSuccess": false, "statusCode": 0, "body": <Cart>[]};
    }
  }

  Future<Map<String, dynamic>> getCartsToEmployee(String body) async {
    try {
      final response = await client.post("dynamic/find-array/vwCart", body);
      print(body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final carts = data.map((e) => Cart.fromJson(e)).toList();
        print(data[0]);
        return {
          "isSuccess": true,
          "statusCode": response.statusCode,
          "body": carts,
        };
      } else {
        return {
          "isSuccess": false,
          "statusCode": response.statusCode,
          "body": <Cart>[],
        };
      }
    } catch (e) {
      print('Error fetching carts: $e');
      return {"isSuccess": false, "statusCode": 0, "body": <Cart>[]};
    }
  }

  Future<Map<String, dynamic>> createCart(String body) async {
    try {
      final response = await client.post(
        "cart", // thay bằng endpoint tạo giỏ hàng thật của bạn
        body,
      );

      return {
        "isSuccess": response.statusCode == 201 || response.statusCode == 200,
        "statusCode": response.statusCode,
        "body": response.body, // hoặc parse nếu cần
      };
    } catch (e) {
      print('Error creating cart: $e');
      return {"isSuccess": false, "statusCode": 0, "body": null};
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

  Future<Map<String, dynamic>> confirmCart(
    String userId,
    String id,
    String body,
  ) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.put(
        "dynamic/confirm-cart/"+userId+"/" + id.toString(),
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


  Future<Map<String, dynamic>> deleteCart(String table, String body) async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.delete("dynamic/delete/" + table, body);
      print(response.body+"hh");
      print(response.statusCode);

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
