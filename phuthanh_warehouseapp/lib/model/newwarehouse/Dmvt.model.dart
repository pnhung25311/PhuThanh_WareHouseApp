class Dmvt {
  final int aid;
  final String maVt;
  final String tenVt;
  final String dvt;
  final String danhDiemg;
  final String danhDiemdd;
  final String danhDiemc;
  final String? danhDiemk;
  final String? cumChitiet;
  final String thongSo;
  final String hangSx;
  final String? tenHang;
  final String ncSx;
  final String? tenNuoc;
  final String ncc;
  final String? tenKh;
  final String hangXe;
  final String? tenHangxe;
  final String dongXe;
  final String hsCode;
  final String? maCongnghiep;
  final String? mangKd;
  final String? segmentName;
  final String ghiChu;
  final String? img1;
  final String? img2;
  final String? img3;

  Dmvt({
    required this.aid,
    required this.maVt,
    required this.tenVt,
    required this.dvt,
    required this.danhDiemg,
    required this.danhDiemdd,
    required this.danhDiemc,
    this.danhDiemk,
    this.cumChitiet,
    required this.thongSo,
    required this.hangSx,
    this.tenHang,
    required this.ncSx,
    this.tenNuoc,
    required this.ncc,
    this.tenKh,
    required this.hangXe,
    this.tenHangxe,
    required this.dongXe,
    required this.hsCode,
    this.maCongnghiep,
    this.mangKd,
    this.segmentName,
    required this.ghiChu,
    this.img1,
    this.img2,
    this.img3,
  });

  /// Mọi trường văn bản của vật tư, dùng cho tìm kiếm (xem [SearchTextHelper]).
  List<String?> get searchFields => [
    maVt,
    tenVt,
    dvt,
    danhDiemg,
    danhDiemdd,
    danhDiemc,
    danhDiemk,
    cumChitiet,
    thongSo,
    hangSx,
    tenHang,
    ncSx,
    tenNuoc,
    ncc,
    tenKh,
    hangXe,
    tenHangxe,
    dongXe,
    hsCode,
    maCongnghiep,
    mangKd,
    segmentName,
    ghiChu,
  ];

  factory Dmvt.fromJson(Map<String, dynamic> json) {
    return Dmvt(
      // Server đổi từ `aid` sang `productAid` — giữ cả 2 để tương thích ngược.
      aid:
          (json['productAid'] as num?)?.toInt() ??
          (json['aid'] as num?)?.toInt() ??
          0,
      maVt: (json['maVt'] ?? '').toString().trim(),
      tenVt: json['tenVt'] ?? '',
      dvt: json['dvt'] ?? '',
      danhDiemg: json['danhDiemg'] ?? '',
      danhDiemdd: json['danhDiemdd'] ?? '',
      danhDiemc: json['danhDiemc'] ?? '',
      danhDiemk: json['danhDiemk'],
      cumChitiet: json['cumChitiet'],
      thongSo: json['thongSo'] ?? '',
      hangSx: json['hangSx'] ?? '',
      tenHang: json['tenHang'],
      ncSx: json['ncSx'] ?? '',
      tenNuoc: json['tenNuoc'],
      ncc: json['ncc'] ?? '',
      tenKh: json['tenKh'],
      hangXe: json['hangXe'] ?? '',
      tenHangxe: json['tenHangxe'],
      dongXe: json['dongXe'] ?? '',
      hsCode: json['hsCode'] ?? '',
      maCongnghiep: json['maCongnghiep'],
      mangKd: json['mangKd'],
      segmentName: json['segmentName'],
      ghiChu: json['ghiChu'] ?? '',
      img1: json['img1'],
      img2: json['img2'],
      img3: json['img3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productAid': aid,
      'maVt': maVt,
      'tenVt': tenVt,
      'dvt': dvt,
      'danhDiemg': danhDiemg,
      'danhDiemdd': danhDiemdd,
      'danhDiemc': danhDiemc,
      'danhDiemk': danhDiemk,
      'cumChitiet': cumChitiet,
      'thongSo': thongSo,
      'hangSx': hangSx,
      'tenHang': tenHang,
      'ncSx': ncSx,
      'tenNuoc': tenNuoc,
      'ncc': ncc,
      'tenKh': tenKh,
      'hangXe': hangXe,
      'tenHangxe': tenHangxe,
      'dongXe': dongXe,
      'hsCode': hsCode,
      'maCongnghiep': maCongnghiep,
      'mangKd': mangKd,
      'segmentName': segmentName,
      'ghiChu': ghiChu,
      'img1': img1,
      'img2': img2,
      'img3': img3,
    };
  }
}
