import 'package:phuthanh_warehouseapp/model/newwarehouse/WarehouseInventoryItem.model.dart';

/// Công ty thành viên của tập đoàn. `code` chính là path variable `{kho}` của
/// các API `/api/ton-kho-cty/{kho}`, `/api/nhap-kho-cty/{kho}`,
/// `/api/xuat-dieu-chuyen-cty/{kho}` (bảng vật lý `WareHouseDmvt<CODE>`).
class Company {
  final String code;
  final String name;

  const Company({required this.code, required this.name});
}

const List<Company> kCompanies = [
  Company(code: 'pt', name: 'Phú Thành'),
  Company(code: 'vy', name: 'Việt Ý'),
  Company(code: 'lvt', name: 'Lê Văn Thiện'),
  Company(code: 'hvd', name: 'Hoàng Văn Dũng'),
  Company(code: 'z', name: 'Z'),
];

/// Kho con (vị trí) trong 1 công ty — 1 dòng của bảng `Warehouse`
/// (`GET /api/dm-kho`).
class SubWarehouse {
  final int id;
  final String name;
  final String? companyName;

  const SubWarehouse({required this.id, required this.name, this.companyName});

  factory SubWarehouse.fromJson(Map<String, dynamic> json) {
    dynamic pick(List<String> keys) {
      for (final k in keys) {
        if (json[k] != null) return json[k];
      }
      return null;
    }

    return SubWarehouse(
      id: (pick(['warehouseId', 'warehouseID', 'WarehouseID']) as num?)?.toInt() ?? 0,
      name: (pick(['wareHouseName', 'warehouseName', 'WareHouseName']) ?? '').toString(),
      companyName: pick(['companyName', 'CompanyName'])?.toString(),
    );
  }

  @override
  bool operator ==(Object other) => other is SubWarehouse && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// 1 dòng tồn kho theo kho con — response `GET /api/ton-kho-cty/{kho}`.
class TonKhoCty {
  final int? warehouseId;
  final WarehouseInventoryItem item;

  const TonKhoCty({required this.warehouseId, required this.item});

  factory TonKhoCty.fromJson(Map<String, dynamic> json) {
    return TonKhoCty(
      warehouseId: (json['warehouseId'] as num?)?.toInt(),
      item: WarehouseInventoryItem.fromJson(json),
    );
  }
}
