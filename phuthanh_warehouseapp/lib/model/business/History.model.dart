class HistoryBusiness {
  final String maVt;
  final double? slNhap;
  final double? gia;
  final double? tienNhap;
  final String? maKho;
  final String? tenKho;
  final String? maKh;
  final String? tenKh;
  final String? dienGiai;
  final DateTime? ngayCt;

  HistoryBusiness({
    required this.maVt,
    this.slNhap,
    this.gia,
    this.tienNhap,
    this.maKho,
    this.tenKho,
    this.maKh,
    this.tenKh,
    this.dienGiai,
    this.ngayCt,
  });

  factory HistoryBusiness.fromJson(Map<String, dynamic> json) {
    return HistoryBusiness(
      maVt: json['ma_vt']?.toString().trim() ?? '',
      slNhap: (json['sl_nhap'] ?? 0).toDouble(),
      gia: (json['gia'] ?? 0).toDouble(),
      tienNhap: (json['tien_nhap'] ?? 0).toDouble(),
      maKho: json['ma_kho']?.toString().trim() ?? '',
      tenKho: json['ten_kho'] ?? '',
      maKh: json['ma_kh']?.toString().trim() ?? '',
      tenKh: json['ten_kh'] ?? '',
      dienGiai: json['dien_giai'] ?? '',
      ngayCt: DateTime.parse(json['ngay_ct']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_vt': maVt,
      'sl_nhap': slNhap,
      'gia': gia,
      'tien_nhap': tienNhap,
      'ma_kho': maKho,
      'ten_kho': tenKho,
      'ma_kh': maKh,
      'ten_kh': tenKh,
      'dien_giai': dienGiai,
      'ngay_ct': ngayCt?.toIso8601String(),
    };
  }
}
