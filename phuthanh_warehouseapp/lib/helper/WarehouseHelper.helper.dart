import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';


class WareHouseHelper {
  /// Xóa các field trong danh sách [fieldsToClear]
  static WareHouse clearFields(WareHouse item, List<String> fieldsToClear) {
    // Chuyển tất cả tên field cần xóa về chữ thường
    final lowerFields = fieldsToClear.map((f) => f.toLowerCase()).toSet();

    // Lấy dữ liệu hiện tại từ object
    final data = item.toJson();

    // Duyệt từng key và xóa nếu nằm trong danh sách cần clear
    for (final entry in data.entries.toList()) {
      final keyLower = entry.key.toLowerCase();

      if (lowerFields.contains(keyLower)) {
        data[entry.key] = _getDefaultValue(entry.value);
      }
    }

    return WareHouse.fromJson(data);
  }

  /// Trả về giá trị mặc định tương ứng (rỗng/null)
  static dynamic _getDefaultValue(dynamic value) {
    if (value is String) return "";
    if (value is num) return 0;
    if (value is bool) return false;
    return null;
  }
}
