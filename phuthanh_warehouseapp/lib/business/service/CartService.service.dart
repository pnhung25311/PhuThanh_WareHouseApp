import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';

class CartService {
  final ApiClient client = const ApiClient();

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

  // Nếu sau này bạn muốn lọc theo status, partner, supplier...
  // Future<Map<String, dynamic>> getCartsByStatus(String status) async { ... }

  Future<Map<String, dynamic>> createCart(String body ) async {
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
}
