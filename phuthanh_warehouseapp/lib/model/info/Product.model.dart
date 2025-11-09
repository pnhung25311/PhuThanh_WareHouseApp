class Product {
  final String productAID;
  final String productID;
  final String idKeeton;
  final String idIndustrial;
  final String idPartNo;
  final String idReplacedPartNo;
  final String nameProduct;
  // final double qtyExpected;
  // final String idBill;
  final String parameter;
  final String vehicleDetail;
  final int vehicleTypeID;
  final String? vehicleTypeName;
  final int manufacturerID;
  final String? manufacturerName;
  final int countryID;
  final String? countryName;
  final int supplierID;
  final String? supplierName;
  final int supplierActualID;
  final String? supplierActualName;
  final int unitID;
  final String? unitName;
  final String? img1;
  final String? img2;
  final String? img3;
  final String? remark;
  final DateTime? lastTime;

  const Product({
    required this.productAID,
    required this.productID,
    required this.idKeeton,
    required this.idIndustrial,
    required this.idPartNo,
    required this.idReplacedPartNo,
    required this.nameProduct,
    // required this.qtyExpected,
    // required this.idBill,
    required this.parameter,
    required this.vehicleDetail,
    required this.vehicleTypeID,
    required this.manufacturerID,
    required this.countryID,
    required this.supplierID,
    required this.supplierActualID,
    required this.unitID,
    this.vehicleTypeName,
    this.manufacturerName,
    this.countryName,
    this.supplierName,
    this.supplierActualName,
    this.unitName,
    this.img1,
    this.img2,
    this.img3,
    this.remark,
    this.lastTime,
  });

  /// ✅ Tạo một Product rỗng (dùng khi khởi tạo mặc định)
  factory Product.empty() {
    return const Product(
      productAID: '',
      productID: '',
      idKeeton: '',
      idIndustrial: '',
      idPartNo: '',
      idReplacedPartNo: '',
      nameProduct: '',
      // qtyExpected: 0,
      // idBill: '',
      parameter: '',
      vehicleDetail: '',
      vehicleTypeID: 0,
      manufacturerID: 0,
      countryID: 0,
      supplierID: 0,
      supplierActualID: 0,
      unitID: 0,
      vehicleTypeName: '',
      manufacturerName: '',
      countryName: '',
      supplierName: '',
      supplierActualName: '',
      unitName: '',
      img1: null,
      img2: null,
      img3: null,
      remark: null,
      lastTime: null,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productAID: json['ProductAID'] ?? '',
      productID: json['ProductID'] ?? '',
      idKeeton: json['ID_Keeton'] ?? '',
      idIndustrial: json['ID_Industrial'] ?? '',
      idPartNo: json['ID_PartNo'] ?? '',
      idReplacedPartNo: json['ID_ReplacedPartNo'] ?? '',
      nameProduct: json['NameProduct'] ?? '',
      // qtyExpected: (json['Qty_Expected'] ?? 0).toDouble(),
      // idBill: json['ID_Bill'] ?? '',
      parameter: json['Parameter'] ?? '',
      vehicleDetail: json['VehicleDetail'] ?? '',
      vehicleTypeID: json['VehicleTypeID'] ?? 0,
      manufacturerID: json['ManufacturerID'] ?? 0,
      countryID: json['CountryID'] ?? 0,
      supplierID: json['SupplierID'] ?? 0,
      supplierActualID: json['SupplierActualID'] ?? 0,
      unitID: json['UnitID'] ?? 0,
      unitName: json['UnitName'] ?? '',
      countryName: json['CountryName'] ?? '',
      manufacturerName: json['ManufacturerName'] ?? '',
      vehicleTypeName: json['VehicleTypeName'] ?? '',
      supplierName: json['SupplierName'] ?? '',
      supplierActualName: json['SupplierActualName'] ?? '',
      img1: json['Img1'],
      img2: json['Img2'],
      img3: json['Img3'],
      remark: json['Remark'],
      lastTime: json['LastTime'] != null
          ? DateTime.parse(json['LastTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductAID': productAID,
      'ProductID': productID,
      'ID_Keeton': idKeeton,
      'ID_Industrial': idIndustrial,
      'ID_PartNo': idPartNo,
      'ID_ReplacedPartNo': idReplacedPartNo,
      'NameProduct': nameProduct,
      // 'Qty_Expected': qtyExpected,
      // 'ID_Bill': idBill,
      'Parameter': parameter,
      'VehicleDetail': vehicleDetail,
      'VehicleTypeID': vehicleTypeID,
      'ManufacturerID': manufacturerID,
      'CountryID': countryID,
      'SupplierID': supplierID,
      'SupplierActualID': supplierActualID,
      'UnitID': unitID,
      // 'ManufacturerName': manufacturerName,
      // 'CountryName': countryName,
      // 'VehicleTypeName': vehicleTypeName,
      // 'SupplierActualName': supplierActualName,
      // 'SupplierName': supplierName,
      // 'UnitName': unitName,
      'Img1': img1,
      'Img2': img2,
      'Img3': img3,
      'Remark': remark,
      'LastTime': lastTime?.toIso8601String(),
    };
  }

  Product copyWith({
    String? productAID,
    String? productID,
    String? idKeeton,
    String? idIndustrial,
    String? idPartNo,
    String? idReplacedPartNo,
    String? nameProduct,
    // double? qtyExpected,
    // String? idBill,
    String? parameter,
    String? vehicleDetail,
    int? vehicleTypeID,
    int? manufacturerID,
    int? countryID,
    int? supplierID,
    int? supplierActualID,
    int? unitID,
    String? manufacturerName,
    String? vehicleTypeName,
    String? countryName,
    String? supplierActualName,
    String? supplierName,
    String? unitName,
    String? img1,
    String? img2,
    String? img3,
    String? remark,
    DateTime? lastTime,
  }) {
    return Product(
      productAID: productAID ?? this.productAID,
      productID: productID ?? this.productID,
      idKeeton: idKeeton ?? this.idKeeton,
      idIndustrial: idIndustrial ?? this.idIndustrial,
      idPartNo: idPartNo ?? this.idPartNo,
      idReplacedPartNo: idReplacedPartNo ?? this.idReplacedPartNo,
      nameProduct: nameProduct ?? this.nameProduct,
      // qtyExpected: qtyExpected ?? this.qtyExpected,
      // idBill: idBill ?? this.idBill,
      parameter: parameter ?? this.parameter,
      vehicleDetail: vehicleDetail ?? this.vehicleDetail,
      vehicleTypeID: vehicleTypeID ?? this.vehicleTypeID,
      manufacturerID: manufacturerID ?? this.manufacturerID,
      countryID: countryID ?? this.countryID,
      supplierID: supplierID ?? this.supplierID,
      supplierActualID: supplierActualID ?? this.supplierActualID,
      unitID: unitID ?? this.unitID,
      supplierActualName: supplierActualName ?? this.supplierActualName,
      supplierName: supplierName ?? this.supplierName,
      countryName: countryName ?? this.countryName,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      vehicleTypeName: vehicleTypeName ?? this.vehicleTypeName,
      unitName: unitName ?? this.unitName,
      img1: img1 ?? this.img1,
      img2: img2 ?? this.img2,
      img3: img3 ?? this.img3,
      remark: remark ?? this.remark,
      lastTime: lastTime ?? this.lastTime,
    );
  }
}
