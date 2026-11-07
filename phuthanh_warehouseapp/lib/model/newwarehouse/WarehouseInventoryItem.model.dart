import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';

/// Một dòng tồn kho tại 1 kho cụ thể — khớp đúng response thật của các API
/// `/ton-kho/dmvt*` (join Material với các danh mục tra cứu, tên cột phẳng
/// chung với `Dmvt` cộng thêm số lượng tồn và thông tin ghi nhận).
class WarehouseInventoryItem {
  final int dataWareHouseAid;
  final double qty;
  final String? location;
  final String? remark;
  final int? createUser;
  final String? createTime;
  final String? fullName;
  final Dmvt material;

  WarehouseInventoryItem({
    required this.dataWareHouseAid,
    required this.qty,
    this.location,
    this.remark,
    this.createUser,
    this.createTime,
    this.fullName,
    required this.material,
  });

  /// Mọi trường hiển thị của dòng tồn kho (vật tư + vị trí, ghi chú, số tồn...).
  List<String?> get searchFields => [
    ...material.searchFields,
    location,
    remark,
    fullName,
    createTime,
    qty.toString(),
  ];

  factory WarehouseInventoryItem.fromJson(Map<String, dynamic> json) {
    return WarehouseInventoryItem(
      dataWareHouseAid: (json['dataWareHouseAid'] as num?)?.toInt() ?? 0,
      qty: (json['qty'] as num?)?.toDouble() ?? 0,
      location: json['location']?.toString(),
      remark: json['remark']?.toString(),
      createUser: (json['createUser'] as num?)?.toInt(),
      createTime: json['createTime']?.toString(),
      fullName: json['fullName']?.toString(),
      material: Dmvt.fromJson(json),
    );
  }
}
