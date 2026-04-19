class Business {
  final String maVatTu; // NEW
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

  final String nhaCungCapHopDong;
  final String nhaCungCapThucTe;

  final String mucDich; // NEW
  final String mangKinhDoanh; // NEW

  final String donViTinh;

  final String? hinhAnh1;
  final String? hinhAnh2;
  final String? hinhAnh3;

  final String ghiChu;

  final double? giaVon1;
  final double? giaVon2;
  final double? vatVietY;
  final double? vatPhuThanh;

  final String ghiChuVat;
  final String tenVietYVat;
  final String tenPhuThanhVat;
  final String coCqVietY;
  final String coCqPhuThanh;

  final double? khoChinh;
  final double? kho397;
  final double? khoKheDay;
  final double? khoKhoangSan;
  final double? khoLangKhanh;

  final String soLuongDuKien;
  final String maSoHoaDon;
  final String viTri;

  final double? tongSoLuongBanRa;
  final double? soLuongBanRaGanNhat;
  final String thoiGianBanRaGanNhat;

  final double? hkdHoangVanDung;
  final double? hkdLeVanThien;

  Business({
    required this.maVatTu,
    required this.maKeeton,
    required this.maCongNghiep,
    required this.danhDiem,
    required this.boDanhDiemTuongDuong,
    required this.tenHangHoa,
    required this.thongSoKyThuat,
    required this.hangXe,
    required this.dongXe,
    required this.cumXe,
    required this.hangSanXuat,
    required this.nuocSanXuat,
    required this.nhaCungCapHopDong,
    required this.nhaCungCapThucTe,
    required this.mucDich,
    required this.mangKinhDoanh,
    required this.donViTinh,
    this.hinhAnh1,
    this.hinhAnh2,
    this.hinhAnh3,
    required this.ghiChu,
    this.giaVon1,
    this.giaVon2,
    this.vatVietY,
    this.vatPhuThanh,
    required this.ghiChuVat,
    required this.tenVietYVat,
    required this.tenPhuThanhVat,
    required this.coCqVietY,
    required this.coCqPhuThanh,
    this.khoChinh,
    this.kho397,
    this.khoKheDay,
    this.khoKhoangSan,
    this.khoLangKhanh,
    required this.soLuongDuKien,
    required this.maSoHoaDon,
    required this.viTri,
    this.tongSoLuongBanRa,
    this.soLuongBanRaGanNhat,
    required this.thoiGianBanRaGanNhat,
    this.hkdHoangVanDung,
    this.hkdLeVanThien,
  });

  // ================= FROM JSON =================

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      maVatTu: _s(json['Mã vật tư']),
      maKeeton: _s(json['Mã Keeton']),
      maCongNghiep: _s(json['Mã Công Nghiệp']),
      danhDiem: _s(json['Danh điểm']),
      boDanhDiemTuongDuong: _s(json['Bộ danh điểm tương đương']),

      tenHangHoa: _s(json['Tên hàng hóa']),
      thongSoKyThuat: _s(json['Thông số kĩ thuật']),

      hangXe: _s(json['Hãng Xe']),
      dongXe: _s(json['Dòng xe']),
      cumXe: _s(json['Cụm xe']),

      hangSanXuat: _s(json['Hãng Sản Xuất']),
      nuocSanXuat: _s(json['Nước Sản Xuất']),

      nhaCungCapHopDong: _s(json['Nhà cung cấp hợp đồng']),
      nhaCungCapThucTe: _s(json['Nhà cung cấp thực tế']),

      mucDich: _s(json['Mục đích']), // NEW
      mangKinhDoanh: _s(json['Mảng kinh doanh']), // NEW

      donViTinh: _s(json['Đơn vị tính']),

      hinhAnh1: _img(json['Hình ảnh 1']),
      hinhAnh2: _img(json['Hình ảnh 2']),
      hinhAnh3: _img(json['Hình ảnh 3']),

      ghiChu: _s(json['Ghi chú']),

      giaVon1: _d(json['Giá vốn 1']),
      giaVon2: _d(json['Giá vốn 2']),
      vatVietY: _d(json['VAT Việt Ý']),
      vatPhuThanh: _d(json['VAT Phú Thành']),

      ghiChuVat: _s(json['Ghi chu VAT']),
      tenVietYVat: _s(json['Tên Việt Ý VAT']),
      tenPhuThanhVat: _s(json['Tên Phú Thành VAT']),
      coCqVietY: _s(json['CoCq Việt Ý']),
      coCqPhuThanh: _s(json['CoCq Phú Thành']),

      khoChinh: _d(json['Kho chính']),
      kho397: _d(json['Kho 397']),
      khoKheDay: _d(json['Kho Khe Dây']),
      khoKhoangSan: _d(json['Kho Khoáng Sản']),
      khoLangKhanh: _d(json['Kho Làng Khánh']),

      soLuongDuKien: _s(json['Số lượng dự kiến']),
      maSoHoaDon: _s(json['Mã số hóa đơn']),
      viTri: _s(json['Vị trí']),

      tongSoLuongBanRa: _d(json['Tổng số lượng bán ra']),
      soLuongBanRaGanNhat: _d(json['Số lượng bán ra gần nhất']),
      thoiGianBanRaGanNhat: _s(json['Thời gian bán ra gần nhất']),

      hkdHoangVanDung: _d(json['HKD Hoàng Văn Dũng']),
      hkdLeVanThien: _d(json['HKD Lê Văn Thiện']),
    );
  }

  // ================= HELPERS =================

  static String _s(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    return s == ' ' ? '' : s;
  }

  static String? _img(dynamic v) {
    final s = _s(v);
    return s.isEmpty ? null : s;
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim().replaceAll(',', '');
    if (s.isEmpty || s == '-') return null;
    return double.tryParse(s);
  }

  factory Business.empty() => Business.fromJson({});

  Business copyWith({
    String? maVatTu,
    String? maKeeton,
    String? maCongNghiep,
    String? danhDiem,
    String? boDanhDiemTuongDuong,
    String? tenHangHoa,
    String? thongSoKyThuat,
    String? hangXe,
    String? dongXe,
    String? cumXe,
    String? hangSanXuat,
    String? nuocSanXuat,
    String? nhaCungCapHopDong,
    String? nhaCungCapThucTe,
    String? mucDich,
    String? mangKinhDoanh,
    String? donViTinh,
    String? hinhAnh1,
    String? hinhAnh2,
    String? hinhAnh3,
    String? ghiChu,
    double? giaVon1,
    double? giaVon2,
    double? vatVietY,
    double? vatPhuThanh,
    String? ghiChuVat,
    String? tenVietYVat,
    String? tenPhuThanhVat,
    String? coCqVietY,
    String? coCqPhuThanh,
    double? khoChinh,
    double? kho397,
    double? khoKheDay,
    double? khoKhoangSan,
    double? khoLangKhanh,
    String? soLuongDuKien,
    String? maSoHoaDon,
    String? viTri,
    double? tongSoLuongBanRa,
    double? soLuongBanRaGanNhat,
    String? thoiGianBanRaGanNhat,
    double? hkdHoangVanDung,
    double? hkdLeVanThien,
  }) {
    return Business(
      maVatTu: maVatTu ?? this.maVatTu,
      maKeeton: maKeeton ?? this.maKeeton,
      maCongNghiep: maCongNghiep ?? this.maCongNghiep,
      danhDiem: danhDiem ?? this.danhDiem,
      boDanhDiemTuongDuong: boDanhDiemTuongDuong ?? this.boDanhDiemTuongDuong,
      tenHangHoa: tenHangHoa ?? this.tenHangHoa,
      thongSoKyThuat: thongSoKyThuat ?? this.thongSoKyThuat,
      hangXe: hangXe ?? this.hangXe,
      dongXe: dongXe ?? this.dongXe,
      cumXe: cumXe ?? this.cumXe,
      hangSanXuat: hangSanXuat ?? this.hangSanXuat,
      nuocSanXuat: nuocSanXuat ?? this.nuocSanXuat,
      nhaCungCapHopDong: nhaCungCapHopDong ?? this.nhaCungCapHopDong,
      nhaCungCapThucTe: nhaCungCapThucTe ?? this.nhaCungCapThucTe,
      mucDich: mucDich ?? this.mucDich,
      mangKinhDoanh: mangKinhDoanh ?? this.mangKinhDoanh,
      donViTinh: donViTinh ?? this.donViTinh,
      hinhAnh1: hinhAnh1 ?? this.hinhAnh1,
      hinhAnh2: hinhAnh2 ?? this.hinhAnh2,
      hinhAnh3: hinhAnh3 ?? this.hinhAnh3,
      ghiChu: ghiChu ?? this.ghiChu,
      giaVon1: giaVon1 ?? this.giaVon1,
      giaVon2: giaVon2 ?? this.giaVon2,
      vatVietY: vatVietY ?? this.vatVietY,
      vatPhuThanh: vatPhuThanh ?? this.vatPhuThanh,
      ghiChuVat: ghiChuVat ?? this.ghiChuVat,
      tenVietYVat: tenVietYVat ?? this.tenVietYVat,
      tenPhuThanhVat: tenPhuThanhVat ?? this.tenPhuThanhVat,
      coCqVietY: coCqVietY ?? this.coCqVietY,
      coCqPhuThanh: coCqPhuThanh ?? this.coCqPhuThanh,
      khoChinh: khoChinh ?? this.khoChinh,
      kho397: kho397 ?? this.kho397,
      khoKheDay: khoKheDay ?? this.khoKheDay,
      khoKhoangSan: khoKhoangSan ?? this.khoKhoangSan,
      khoLangKhanh: khoLangKhanh ?? this.khoLangKhanh,
      soLuongDuKien: soLuongDuKien ?? this.soLuongDuKien,
      maSoHoaDon: maSoHoaDon ?? this.maSoHoaDon,
      viTri: viTri ?? this.viTri,
      tongSoLuongBanRa: tongSoLuongBanRa ?? this.tongSoLuongBanRa,
      soLuongBanRaGanNhat: soLuongBanRaGanNhat ?? this.soLuongBanRaGanNhat,
      thoiGianBanRaGanNhat: thoiGianBanRaGanNhat ?? this.thoiGianBanRaGanNhat,
      hkdHoangVanDung: hkdHoangVanDung ?? this.hkdHoangVanDung,
      hkdLeVanThien: hkdLeVanThien ?? this.hkdLeVanThien,
    );
  }
}
