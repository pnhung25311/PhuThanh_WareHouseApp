/// 1 dòng lịch sử nhập/xuất kho — khớp đúng response `GET /api/lich-su-kho/{kho}`
/// (đọc từ view `vwHistoryDmvt*`, đã join sẵn tên vật tư/nhân viên/NCC).
class LichSuKho {
  final int historyAid;
  final int? dataWareHouseAid;
  final int? productAid;
  final String maVt;
  final String tenVt;
  final double? qty;
  final int? employeeId;
  final String? nameEmployee;
  final String? ncc;
  final String? tenKh;
  final String? remark;
  final String? time;

  /// Số lô — chỉ có ở 5 kho dmvt, dmvt-lk, dmvt-kd, dmvt-397, dmvt-ks.
  final String? noLot;

  LichSuKho({
    required this.historyAid,
    this.dataWareHouseAid,
    this.productAid,
    required this.maVt,
    required this.tenVt,
    this.qty,
    this.employeeId,
    this.nameEmployee,
    this.ncc,
    this.tenKh,
    this.remark,
    this.time,
    this.noLot,
  });

  factory LichSuKho.fromJson(Map<String, dynamic> json) {
    return LichSuKho(
      historyAid: (json['historyAid'] as num?)?.toInt() ?? 0,
      dataWareHouseAid: (json['dataWareHouseAid'] as num?)?.toInt(),
      productAid: (json['productAid'] as num?)?.toInt(),
      maVt: (json['maVt'] ?? '').toString().trim(),
      tenVt: (json['tenVt'] ?? '').toString(),
      qty: (json['qty'] as num?)?.toDouble(),
      employeeId: (json['employeeId'] as num?)?.toInt(),
      nameEmployee: json['nameEmployee']?.toString(),
      ncc: json['ncc']?.toString(),
      tenKh: json['tenKh']?.toString(),
      remark: json['remark']?.toString(),
      time: json['time']?.toString(),
      noLot: json['noLot']?.toString(),
    );
  }
}
