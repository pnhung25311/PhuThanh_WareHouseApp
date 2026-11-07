// 4 model danh mục tra cứu (read-only), khớp đúng field JSON theo tài liệu
// API `get-all-dmhangsx` / `get-all-dmhangxe` / `get-all-dmnuocsx` / `get-all-dmkh`.

class Manufacturer {
  final String maHang;
  final String tenHang;

  Manufacturer({required this.maHang, required this.tenHang});

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      maHang: (json['maHang'] ?? '').toString().trim(),
      tenHang: (json['tenHang'] ?? '').toString().trim(),
    );
  }
}

class VehicleBrand {
  final String maHangxe;
  final String tenHangxe;

  VehicleBrand({required this.maHangxe, required this.tenHangxe});

  factory VehicleBrand.fromJson(Map<String, dynamic> json) {
    return VehicleBrand(
      maHangxe: (json['maHangxe'] ?? '').toString().trim(),
      tenHangxe: (json['tenHangxe'] ?? '').toString().trim(),
    );
  }
}

class Country {
  final String maNuoc;
  final String tenNuoc;

  Country({required this.maNuoc, required this.tenNuoc});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      maNuoc: (json['maNuoc'] ?? '').toString().trim(),
      tenNuoc: (json['tenNuoc'] ?? '').toString().trim(),
    );
  }
}

/// Khách hàng / nhà cung cấp (bảng `dmkh`).
class Customer {
  final String maKh;
  final String tenKh;
  final String tenKh2;
  final String maSoThue;
  final String diaChi;
  final String dienThoai;
  final String fax;
  final String email;

  Customer({
    required this.maKh,
    required this.tenKh,
    required this.tenKh2,
    required this.maSoThue,
    required this.diaChi,
    required this.dienThoai,
    required this.fax,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      maKh: (json['maKh'] ?? '').toString().trim(),
      tenKh: (json['tenKh'] ?? '').toString().trim(),
      tenKh2: (json['tenKh2'] ?? '').toString().trim(),
      maSoThue: (json['maSoThue'] ?? '').toString().trim(),
      diaChi: (json['diaChi'] ?? '').toString().trim(),
      dienThoai: (json['dienThoai'] ?? '').toString().trim(),
      fax: (json['fax'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
    );
  }
}
