class Guarantee {
  final int? guaranteeAID; // GuaranteeAID (thường là PK)
  final String? guaranteeID; // GuaranteeID (có thể là mã bảo hành dạng chuỗi)
  final int?
  productBroken; // ProductBroken (FK -> ProductAID của sản phẩm hỏng)
  final String? productIDBroken; // ProductIDBroken
  final String? idPartNoBroken; // ID_PartNoBroken
  final String? nameProductBroken; // NameProductBroken
  final String? countryNameBroken; // CountryNameBroken
  final String? unitNameBroken; // UnitNameBroken

  final DateTime? timeStart; // TimeStart
  final DateTime? timeBroken; // TimeBroken
  final double? timeUsage; // TimeUsage (thường là số tháng/giờ đã dùng)
  final String? reasonBroken; // ReasonBroken
  final int?
  productGuarantee; // ProductGuarantee (FK -> sản phẩm thay thế/bảo hành)

  final String? productIDGuarantee; // ProductIDGuarantee
  final String? idPartNoGuarantee; // ID_PartNoGuarantee
  final String? nameProductGuarantee; // NameProductGuarantee
  final String? unitNameGuarantee; // UnitNameGuarantee
  final String? countryNameGuarantee; // CountryNameGuarantee
  final DateTime? timeGuarantee; // TimeGuarantee (ngày bảo hành)

  final int? supplierGuarantee; // SupplierGuarantee (FK -> SupplierID)
  final String? partner; // Name của Supplier/Đối tác
  final String? img1; // Đường dẫn ảnh 1
  final String? img2; // Đường dẫn ảnh 2
  final String? img3; // Đường dẫn ảnh 3
  final String? remark; // Ghi chú
  final String? lastUser; // Người cập nhật cuối
  final DateTime? lastTime; // Thời gian cập nhật cuối

  Guarantee({
    this.guaranteeAID,
    this.guaranteeID,
    this.productBroken,
    this.productIDBroken,
    this.idPartNoBroken,
    this.nameProductBroken,
    this.countryNameBroken,
    this.unitNameBroken,
    this.timeStart,
    this.timeBroken,
    this.timeUsage,
    this.reasonBroken,
    this.productGuarantee,
    this.productIDGuarantee,
    this.idPartNoGuarantee,
    this.nameProductGuarantee,
    this.unitNameGuarantee,
    this.countryNameGuarantee,
    this.timeGuarantee,
    this.partner,
    this.img1,
    this.img2,
    this.img3,
    this.remark,
    this.lastUser,
    this.lastTime,
    this.supplierGuarantee,
  });

  factory Guarantee.fromJson(Map<String, dynamic> json) {
    return Guarantee(
      guaranteeAID: _parseInt(json['GuaranteeAID']),
      guaranteeID: json['GuaranteeID']?.toString(),
      productBroken: _parseInt(json['ProductBroken']),
      productIDBroken: json['ProductIDBroken']?.toString(),

      // Các trường PartNo: luôn là String (xử lý int → String)
      idPartNoBroken: _parseString(json['ID_PartNoBroken']),
      nameProductBroken: json['NameProductBroken']?.toString(),
      countryNameBroken: json['CountryNameBroken']?.toString(),
      unitNameBroken: json['UnitNameBroken']?.toString(),

      timeStart: _parseDate(json['TimeStart']),
      timeBroken: _parseDate(json['TimeBroken']),

      // timeUsage: chấp nhận int, double, string
      timeUsage: _parseDouble(json['TimeUsage']),

      reasonBroken: json['ReasonBroken']?.toString(),
      productGuarantee: _parseInt(json['ProductGuarantee']),

      productIDGuarantee: json['ProductIDGuarantee']?.toString(),
      idPartNoGuarantee: _parseString(json['ID_PartNoGuarantee']),
      nameProductGuarantee: json['NameProductGuarantee']?.toString(),
      unitNameGuarantee: json['UnitNameGuarantee']?.toString(),
      countryNameGuarantee: json['CountryNameGuarantee']?.toString(),
      timeGuarantee: _parseDate(json['TimeGuarantee']),

      partner: json['Partner']?.toString(),
      img1: json['Img1']?.toString(),
      img2: json['Img2']?.toString(),
      img3: json['Img3']?.toString(),
      remark: json['Remark']?.toString(),
      lastUser: json['LastUser']?.toString(),
      lastTime: _parseDate(json['LastTime']),
      supplierGuarantee: _parseInt(json['SupplierGuarantee']),
    );
  }

  // Helpers (đặt ngay trong class Guarantee hoặc file riêng)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim();
    return value.toString().trim(); // int, double, bool,... đều toString()
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    String? str;
    if (value is String) {
      str = value;
    } else {
      str = value.toString();
    }
    return DateTime.tryParse(str);
  }

  Map<String, dynamic> toJson() {
    return {
      'GuaranteeID': guaranteeID,
      'ProductBroken': productBroken,
      'TimeStart': timeStart?.toIso8601String(),
      'TimeBroken': timeBroken?.toIso8601String(),
      'TimeUsage': timeUsage,
      'ReasonBroken': reasonBroken,
      'ProductGuarantee': productGuarantee,
      'TimeGuarantee': timeGuarantee?.toIso8601String(),
      'Img1': img1,
      'Img2': img2,
      'Img3': img3,
      'Remark': remark,
      'LastUser': lastUser,
      'LastTime': lastTime?.toIso8601String(),
      'SupplierGuarantee': supplierGuarantee,
    };
  }

  // CopyWith method (rất hữu ích khi dùng với state management)
  Guarantee copyWith({
    int? guaranteeAID,
    String? guaranteeID,
    int? productBroken,
    String? productIDBroken,
    String? idPartNoBroken,
    String? nameProductBroken,
    String? countryNameBroken,
    String? unitNameBroken,
    DateTime? timeStart,
    DateTime? timeBroken,
    int? timeUsage,
    String? reasonBroken,
    int? productGuarantee,
    String? productIDGuarantee,
    String? idPartNoGuarantee,
    String? nameProductGuarantee,
    String? unitNameGuarantee,
    String? countryNameGuarantee,
    DateTime? timeGuarantee,
    String? partner,
    String? img1,
    String? img2,
    String? img3,
    String? remark,
    String? lastUser,
    DateTime? lastTime,
    int? supplierGuarantee,
  }) {
    return Guarantee(
      guaranteeAID: guaranteeAID ?? this.guaranteeAID,
      guaranteeID: guaranteeID ?? this.guaranteeID,
      productBroken: productBroken ?? this.productBroken,
      productIDBroken: productIDBroken ?? this.productIDBroken,
      idPartNoBroken: idPartNoBroken ?? this.idPartNoBroken,
      nameProductBroken: nameProductBroken ?? this.nameProductBroken,
      countryNameBroken: countryNameBroken ?? this.countryNameBroken,
      unitNameBroken: unitNameBroken ?? this.unitNameBroken,
      timeStart: timeStart ?? this.timeStart,
      timeBroken: timeBroken ?? this.timeBroken,
      timeUsage: timeUsage?.toDouble() ?? this.timeUsage,
      reasonBroken: reasonBroken ?? this.reasonBroken,
      productGuarantee: productGuarantee ?? this.productGuarantee,
      productIDGuarantee: productIDGuarantee ?? this.productIDGuarantee,
      idPartNoGuarantee: idPartNoGuarantee ?? this.idPartNoGuarantee,
      nameProductGuarantee: nameProductGuarantee ?? this.nameProductGuarantee,
      unitNameGuarantee: unitNameGuarantee ?? this.unitNameGuarantee,
      countryNameGuarantee: countryNameGuarantee ?? this.countryNameGuarantee,
      timeGuarantee: timeGuarantee ?? this.timeGuarantee,
      partner: partner ?? this.partner,
      img1: img1 ?? this.img1,
      img2: img2 ?? this.img2,
      img3: img3 ?? this.img3,
      remark: remark ?? this.remark,
      lastUser: lastUser ?? this.lastUser,
      lastTime: lastTime ?? this.lastTime,
      supplierGuarantee: supplierGuarantee ?? this.supplierGuarantee,
    );
  }
// Thêm factory empty
  factory Guarantee.empty() {
    return Guarantee(
      // Tất cả để null → phù hợp với hầu hết các trường hợp form Dart/Flutter
      guaranteeAID: null,
      guaranteeID: null,
      productBroken: null,
      productIDBroken: null,
      idPartNoBroken: null,
      nameProductBroken: null,
      countryNameBroken: null,
      unitNameBroken: null,
      timeStart: null,
      timeBroken: null,
      timeUsage: null,
      reasonBroken: null,
      productGuarantee: null,
      productIDGuarantee: null,
      idPartNoGuarantee: null,
      nameProductGuarantee: null,
      unitNameGuarantee: null,
      countryNameGuarantee: null,
      timeGuarantee: null,
      supplierGuarantee: null,
      partner: null,
      img1: null,
      img2: null,
      img3: null,
      remark: null,
      lastUser: null,
      lastTime: null,
    );
  }
}
