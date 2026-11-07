/// Các kho cố định của hệ thống — không lấy động qua API, mỗi kho có 1 mã
/// `khoCode` dùng chung cho cả API tồn kho (`/api/ton-kho/{khoCode}`) lẫn
/// API lịch sử nhập/xuất (`/api/lich-su-kho/{khoCode}`).
class Warehouse {
  final int id;
  final String tenKho;
  final String khoCode;

  const Warehouse({
    required this.id,
    required this.tenKho,
    required this.khoCode,
  });

  String get inventoryEndpoint => 'ton-kho/$khoCode';
}

const List<Warehouse> kWarehouses = [
  Warehouse(id: 1, tenKho: 'Kho Chính', khoCode: 'dmvt'),
  Warehouse(id: 2, tenKho: 'Kho Làng Khánh', khoCode: 'dmvt-lk'),
  Warehouse(id: 3, tenKho: 'Kho Khe Dây', khoCode: 'dmvt-kd'),
  Warehouse(id: 4, tenKho: 'Kho 397', khoCode: 'dmvt-397'),
  Warehouse(id: 5, tenKho: 'Kho Khoáng Sản', khoCode: 'dmvt-ks'),
  Warehouse(id: 6, tenKho: 'Kho Công Ty', khoCode: 'dmvt-cty'),

  Warehouse(id: 7, tenKho: 'Kho Hoàng Văn Dũng', khoCode: 'dmvt-kho-hvd'),
  Warehouse(id: 8, tenKho: 'Kho Lê Văn Thiện', khoCode: 'dmvt-kho-lvt'),
  Warehouse(id: 9, tenKho: 'Kho Phú Thành', khoCode: 'dmvt-kho-pt'),
  Warehouse(id: 10, tenKho: 'Kho Việt Ý', khoCode: 'dmvt-kho-vy'),
  Warehouse(id: 11, tenKho: 'Kho Z', khoCode: 'dmvt-kho-z'),
];

/// 6 kho dùng chung API lịch sử/điều chuyển (`dieu-chuyen-kho`). Các kho theo
/// công ty (pt, vy, lvt, hvd, z) dùng API xuất điều chuyển công ty riêng.
const Set<String> kTransferKhoCodes = {
  'dmvt',
  'dmvt-lk',
  'dmvt-kd',
  'dmvt-397',
  'dmvt-ks',
  'dmvt-cty',
};

/// Chỉ 5 kho này có cột `NoLot` (số lô); kho khác bỏ qua noLot khi ghi.
const Set<String> kNoLotKhoCodes = {
  'dmvt',
  'dmvt-lk',
  'dmvt-kd',
  'dmvt-397',
  'dmvt-ks',
};
