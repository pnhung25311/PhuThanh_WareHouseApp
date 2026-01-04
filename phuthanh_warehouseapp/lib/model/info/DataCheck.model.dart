class DataCheck {
  final int? checkAID;
  final int? sheetAID;
  final int? productAID;

  final String? productID;
  final String? idPartNo;
  final String? nameProduct;
  final String? nameCountry;
  final String? nameSupplier;
  final String? nameUnit;

  final double? qtyWareHouse;
  final double? qtyCheck;
  final double? qtyDifferent;

  final String? lastUser;
  final String? remark;
  final DateTime? lastTime;

  DataCheck({
    this.checkAID,
    this.sheetAID,
    this.productAID,
    this.productID,
    this.idPartNo,
    this.nameProduct,
    this.nameCountry,
    this.nameSupplier,
    this.nameUnit,
    this.qtyWareHouse,
    this.qtyCheck,
    this.qtyDifferent,
    this.lastUser,
    this.remark,
    this.lastTime,
  });

  factory DataCheck.fromJson(Map<String, dynamic> json) {
    return DataCheck(
      checkAID: json['CheckAID'],
      sheetAID: json['SheetAID'],
      productAID: json['ProductAID'],

      productID: json['ProductID'],
      idPartNo: json['ID_PartNo'],
      nameProduct: json['NameProduct'],
      nameCountry: json['NameCountry'],
      nameSupplier: json['NameSupplier'],
      nameUnit: json['NameUnit'],

      qtyWareHouse: json['QtyWareHouse']?.toDouble(),
      qtyCheck: json['QtyCheck']?.toDouble(),
      qtyDifferent: json['QtyDifferent']?.toDouble(),

      lastUser: json['LastUser'],
      remark: json['Remark'],
      lastTime: json['LastTime'] != null
          ? DateTime.parse(json['LastTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CheckAID': checkAID,
      'SheetAID': sheetAID,
      'ProductAID': productAID,
      'QtyWareHouse': qtyWareHouse,
      'QtyCheck': qtyCheck,
      'QtyDifferent': qtyDifferent,
      'LastUser': lastUser,
      'Remark': remark,
      'LastTime': lastTime?.toIso8601String(),
    };
  }
}
