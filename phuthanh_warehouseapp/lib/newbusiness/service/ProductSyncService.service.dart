import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/newbusiness/Product.model.dart';

/// Parse file txt (CSV phân tách bằng `;`, dòng đầu là tên cột) — chạy trong
/// isolate riêng qua `compute()` vì file đồng bộ sản phẩm có thể lên tới vài
/// chục nghìn dòng, decode + map đồng bộ trên main isolate sẽ treo UI.
List<Product> _parseProductSyncCsv(String content) {
  final rows = const CsvToListConverter(fieldDelimiter: ';', shouldParseNumbers: false).convert(content);
  if (rows.isEmpty) return <Product>[];

  final headers = rows.first.map((e) => e.toString().trim()).toList();
  final products = <Product>[];

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    // Giữ nguyên đủ tất cả cột (kể cả rỗng) để màn chi tiết hiển thị đúng
    // toàn bộ 78 cột gốc của file, không chỉ những cột có giá trị.
    final fields = <String, String>{};
    for (var c = 0; c < headers.length; c++) {
      fields[headers[c]] = c < row.length ? (row[c]?.toString().trim() ?? '') : '';
    }
    // Dòng trống hoàn toàn (không có mã vật tư) -> bỏ qua, không phải sản phẩm.
    if (fields[headers.first]?.isEmpty ?? true) continue;
    products.add(Product(fields));
  }

  return products;
}

class ProductSyncService {
  /// `GET /api/file/download-product-sync` — trả thẳng nội dung file txt
  /// trong response body (không phải JSON), nên đọc `bodyBytes` rồi tự decode
  /// UTF-8 (không dựa vào charset của response, tránh lỗi tiếng Việt).
  Future<Map<String, dynamic>> downloadAndParse() async {
    try {
      const apiClient = ApiClient();
      final response = await apiClient.get('file/download-product-sync');

      if (response.statusCode != 200) {
        return {"isSuccess": false, "statusCode": response.statusCode, "body": <Product>[]};
      }

      final content = utf8.decode(response.bodyBytes);
      final products = await compute(_parseProductSyncCsv, content);
      return {"isSuccess": true, "statusCode": response.statusCode, "body": products};
    } catch (e) {
      print("ERROR downloadAndParse: $e");
      return {"isSuccess": false, "statusCode": 0, "body": <Product>[]};
    }
  }
}
