// lib/models/business_item.dart
class Business {
  final String barcode;
  final String maKeeton;
  final String maCongNghiep;
  final String danhDiem;
  final String boDanhDiemTuongDuong;
  final String tenHangHoa;
  final String thongSoKyThuat;
  final String hangXe;
  final String dongXe;
  final String cumXe;
  final String hangSanXuat;
  final String nuocSanXuat;
  final String nhaCungCapThucTe;
  final String nhaCungCapHopDong;
  final String donViTinh;
  final String? hinhAnh1;
  final String? hinhAnh2;
  final String? hinhAnh3;
  final String ghiChu;

  // Các trường số → đổi sang double?
  final double? giaVon1;
  final double? giaVon2;
  final double? vatVietY;
  final double? vatPhuThanh;
  final double? khoChinh;
  final double? kho397;
  final double? khoKheDay;
  final double? khoKhoangSan;
  final double? khoLangKhanh;

  final String ghiChuVat;
  final String tenHangHoaTheoVat;
  final String coCqVietY;
  final String coCqPhuThanh;
  final String soLuongDuKien;
  final String maSoHoaDon;
  final String viTri;

  // Các trường số lượng bán ra
  final double? tongSoLuongBanRa;
  final double? soLuongBanRaGanNhat;
  final String thoiGianBanRaGanNhat;

  Business.fromJson(Map<String, dynamic> json)
      : barcode = json['Barcode']?.toString() ?? '',
        maKeeton = json['Mã Keeton']?.toString() ?? '',
        maCongNghiep = json['Mã Công Nghiệp']?.toString() ?? '',
        danhDiem = json['Danh điểm']?.toString() ?? '',
        boDanhDiemTuongDuong = json['Bộ danh điểm tương đương']?.toString() ?? '',
        tenHangHoa = json['Tên hàng hóa']?.toString() ?? '',
        thongSoKyThuat = json['Thông số kĩ thuật']?.toString() ?? '',
        hangXe = json['Hãng Xe']?.toString() ?? '',
        dongXe = json['Dòng xe']?.toString() ?? '',
        cumXe = json['Cụm xe']?.toString() ?? '',
        hangSanXuat = json['Hãng Sản Xuất']?.toString() ?? '',
        nuocSanXuat = json['Nước Sản Xuất']?.toString() ?? '',
        nhaCungCapThucTe = json['Nhà cung cấp thực tế']?.toString() ?? '',
        nhaCungCapHopDong = json['Nhà cung cấp hợp đồng']?.toString() ?? '',
        donViTinh = json['Đơn vị tính']?.toString() ?? '',
        hinhAnh1 = _cleanImageUrl(json['Hình ảnh 1']),
        hinhAnh2 = _cleanImageUrl(json['Hình ảnh 2']),
        hinhAnh3 = _cleanImageUrl(json['Hình ảnh 3']),
        ghiChu = json['Ghi chú']?.toString() ?? '',

        // Parse số double, trả về null nếu không hợp lệ
        giaVon1 = _parseDouble(json['Giá vốn 1']),
        giaVon2 = _parseDouble(json['Giá vốn 2']),
        vatVietY = _parseDouble(json['VAT Việt Ý']),
        vatPhuThanh = _parseDouble(json['VAT Phú Thành']),

        khoChinh = _parseDouble(json['Kho chính']),
        kho397 = _parseDouble(json['Kho 397']),
        khoKheDay = _parseDouble(json['Kho Khe Dây']),
        khoKhoangSan = _parseDouble(json['Kho Khoáng Sản']),
        khoLangKhanh = _parseDouble(json['Kho Làng Khánh']),

        ghiChuVat = json['Ghi chu VAT']?.toString() ?? '',
        tenHangHoaTheoVat = json['Tên hàng hóa theo VAT']?.toString() ?? '',
        coCqVietY = json['CoCq Việt Ý']?.toString() ?? '',
        coCqPhuThanh = json['CoCq Phú Thành']?.toString() ?? '',
        soLuongDuKien = json['Số lượng dự kiến']?.toString() ?? '',
        maSoHoaDon = json['Mã số hóa đơn']?.toString() ?? '',
        viTri = json['Vị trí']?.toString() ?? '',

        tongSoLuongBanRa = _parseDouble(json['Tổng số lượng bán ra']),
        soLuongBanRaGanNhat = _parseDouble(json['Số lượng bán ra gần nhất']),
        thoiGianBanRaGanNhat =
            json['Thời gian bán ra gần nhất']?.toString() ?? '';

  static String? _cleanImageUrl(String? url) {
    if (url == null || url.trim().isEmpty || url.trim() == ' ') return null;
    return url.trim();
  }

  /// Helper parse chuỗi thành double, hỗ trợ dấu phẩy
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    String str = value.toString().trim();
    if (str.isEmpty || str == '-') return null;

    // Thay dấu phẩy thành dấu chấm để parse được (nếu dữ liệu dùng dấu phẩy làm phân cách hàng nghìn)
    str = str.replaceAll(',', '');

    try {
      return double.parse(str);
    } catch (_) {
      return null;
    }
  }

  // Getter format giá (dùng khi hiển thị)
  String get formattedGiaVon1 {
    if (giaVon1 == null) return '-';
    return giaVon1!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get formattedTongSoLuongBanRa {
    if (tongSoLuongBanRa == null) return '-';
    return tongSoLuongBanRa!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // Tương tự cho các trường khác nếu cần...
}