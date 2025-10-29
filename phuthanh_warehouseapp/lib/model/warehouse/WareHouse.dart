class WareHouse {
  final String productID;
  final String? idKeeton;
  final String idIndustrial;
  final String? idPartNo;
  final String? idReplacedPartNo;
  final String nameProduct;
  final double qty;
  final double qtyExpected;
  final String idBill;
  final String parameter;
  final int manufacturerID;
  final int countryID;
  final int supplierID;
  final int unitID;
  final String locationID;
  final String img1;
  final String img2;
  final String img3;
  final String remark;
  final String? fullName;
  final String lastModifiedTime;

  WareHouse({
    required this.productID,
    required this.idKeeton,
    required this.idIndustrial,
    required this.idPartNo,
    required this.idReplacedPartNo,
    required this.nameProduct,
    required this.qty,
    required this.qtyExpected,
    required this.idBill,
    required this.parameter,
    required this.manufacturerID,
    required this.countryID,
    required this.supplierID,
    required this.unitID,
    required this.locationID,
    required this.img1,
    required this.img2,
    required this.img3,
    required this.remark,
    required this.fullName,
    required this.lastModifiedTime,
  });

  factory WareHouse.fromJson(Map<String, dynamic> json) {
    return WareHouse(
      productID: json["ProductID"] ?? "",
      idKeeton: json["ID_Keeton"],
      idIndustrial: json["ID_Industrial"] ?? "",
      idPartNo: json["ID_PartNo"],
      idReplacedPartNo: json["ID_ReplacedPartNo"],
      nameProduct: json["NameProduct"] ?? "",
      qty: (json["Qty"] ?? 0).toDouble(),
      qtyExpected: (json["Qty_Expected"] ?? 0).toDouble(),
      idBill: json["ID_Bill"] ?? "",
      parameter: json["Parameter"] ?? "",
      manufacturerID: json["ManufacturerID"] ?? 0,
      countryID: json["CountryID"] ?? 0,
      supplierID: json["SupplierID"] ?? 0,
      unitID: json["UnitID"] ?? 0,
      locationID: json["LocationID"] ?? 0,
      img1: json["Img1"] ?? "",
      img2: json["Img2"] ?? "",
      img3: json["Img3"] ?? "",
      remark: json["Remark"] ?? "",
      fullName: (json["FullName"] ?? "").toString(),
      lastModifiedTime: json["LastModifiedTime"] ?? "",
    );
  }

  factory WareHouse.empty() {
    return WareHouse(
      productID: "",
      idKeeton: null,
      idIndustrial: "",
      idPartNo: null,
      idReplacedPartNo: null,
      nameProduct: "",
      qty: 0.0,
      qtyExpected: 0.0,
      idBill: "",
      parameter: "",
      manufacturerID: 0,
      countryID: 0,
      supplierID: 0,
      unitID: 0,
      locationID: "",
      img1: "",
      img2: "",
      img3: "",
      remark: "",
      fullName: "",
      lastModifiedTime: "",
    );
  }

  /// 🔹 Convert Object → JSON
  Map<String, dynamic> toJson() {
    return {
      "ProductID": productID,
      "ID_Keeton": idKeeton,
      "ID_Industrial": idIndustrial,
      "ID_PartNo": idPartNo,
      "ID_ReplacedPartNo": idReplacedPartNo,
      "NameProduct": nameProduct,
      "Qty": qty,
      "Qty_Expected": qtyExpected,
      "ID_Bill": idBill,
      "Parameter": parameter,
      "ManufacturerID": manufacturerID,
      "CountryID": countryID,
      "SupplierID": supplierID,
      "UnitID": unitID,
      "LocationID": locationID,
      "Img1": img1,
      "Img2": img2,
      "Img3": img3,
      "Remark": remark,
      "fullName": fullName ?? "",
      "LastModifiedTime": lastModifiedTime,
    };
  }

  // ...existing code...
  // thêm method copyWith bên trong class WareHouse
  WareHouse copyWith({
    String? productID,
    String? idKeeton,
    String? idIndustrial,
    String? idPartNo,
    String? idReplacedPartNo,
    String? nameProduct,
    double? qty,
    double? qtyExpected,
    String? idBill,
    String? parameter,
    int? manufacturerID,
    int? countryID,
    int? supplierID,
    int? unitID,
    String? locationID,
    String? img1,
    String? img2,
    String? img3,
    String? remark,
    String? fullName,
    String? lastModifiedTime,
  }) {
    return WareHouse(
      productID: productID ?? this.productID,
      idKeeton: idKeeton ?? this.idKeeton,
      idIndustrial: idIndustrial ?? this.idIndustrial,
      idPartNo: idPartNo ?? this.idPartNo,
      idReplacedPartNo: idReplacedPartNo ?? this.idReplacedPartNo,
      nameProduct: nameProduct ?? this.nameProduct,
      qty: qty ?? this.qty,
      qtyExpected: qtyExpected ?? this.qtyExpected,
      idBill: idBill ?? this.idBill,
      parameter: parameter ?? this.parameter,
      manufacturerID: manufacturerID ?? this.manufacturerID,
      countryID: countryID ?? this.countryID,
      supplierID: supplierID ?? this.supplierID,
      unitID: unitID ?? this.unitID,
      locationID: locationID ?? this.locationID,
      img1: img1 ?? this.img1,
      img2: img2 ?? this.img2,
      img3: img3 ?? this.img3,
      remark: remark ?? this.remark,
      fullName: fullName ?? this.fullName,
      lastModifiedTime: lastModifiedTime ?? this.lastModifiedTime,
    );
  }
 // ...existing code...
}

