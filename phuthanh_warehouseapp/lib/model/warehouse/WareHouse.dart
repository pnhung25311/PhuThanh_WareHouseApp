class WareHouse {
  final int? dataWareHouseAID;
  final int? productAID;
  final String? productID;
  final String? idKeeton;
  final String? idIndustrial;
  final String? idPartNo;
  final String? idReplacedPartNo;
  final String? nameProduct;
  final double? qtyExpected;
  final String? idBill;
  final String? parameter;
  final String? vehicleDetail;
  final String? vehicleCluster;
  final String? vehicleTypeID;
  final double? qty;
  final int? manufacturerID;
  final int? countryID;
  final int? supplierID;
  final int? supplierActualID;
  final int? unitID;
  final String? manufacturerName;
  final String? vehicleTypeName;
  final String? countryName;
  final String? supplierActualName;
  final String? supplierName;
  final String? unitName;
  final String? locationID;
  final String? img1;
  final String? img2;
  final String? img3;
  final String? remarkOfProduct;
  final DateTime? lastTime;
  final String? remarkOfDataWarehouse;
  final String? lastUser;

  const WareHouse({
    this.dataWareHouseAID,
    required this.productAID,
    this.productID,
    this.idKeeton,
    this.idIndustrial,
    this.idPartNo,
    this.idReplacedPartNo,
    this.nameProduct,
    this.qtyExpected,
    this.idBill,
    this.parameter,
    this.vehicleDetail,
    this.vehicleCluster,
    this.vehicleTypeID,
    this.qty,
    this.manufacturerID,
    this.countryID,
    this.supplierID,
    this.supplierActualID,
    this.unitID,
    this.locationID,
    this.vehicleTypeName,
    this.manufacturerName,
    this.countryName,
    this.supplierName,
    this.supplierActualName,
    this.unitName,
    this.img1,
    this.img2,
    this.img3,
    this.remarkOfProduct,
    this.lastTime,
    this.remarkOfDataWarehouse,
    this.lastUser,
  });

  /// ---- JSON serialization ----
  factory WareHouse.fromJson(Map<String, dynamic> json) {
    return WareHouse(
      dataWareHouseAID:
          int.tryParse(json['DataWareHouseAID']?.toString() ?? '') ?? 0,
      productAID: int.tryParse(json['ProductAID']?.toString() ?? '') ?? 0,
      productID: json['ProductID'] ?? '',
      idKeeton: json['ID_Keeton'] ?? '',
      idIndustrial: json['ID_Industrial'] ?? '',
      idPartNo: json['ID_PartNo'] ?? '',
      idReplacedPartNo: json['ID_ReplacedPartNo'] ?? '',
      nameProduct: json['NameProduct'] ?? '',
      qtyExpected: json['Qty_Expected'] != null
          ? double.tryParse(json['Qty_Expected'].toString())
          : 0,
      qty: json['Qty'] != null ? double.tryParse(json['Qty'].toString()) : 0,
      idBill: json['ID_Bill'] ?? '',
      parameter: json['Parameter'] ?? '',
      vehicleDetail: json['VehicleDetail'] ?? '',
      vehicleCluster: json['VehicleCluster'] ?? '',
      vehicleTypeID: json['VehicleTypeID'] ?? '',
      manufacturerID: (json['ManufacturerID'] as num?)?.toInt() ?? 0,
      countryID: (json['CountryID'] as num?)?.toInt() ?? 0,
      supplierID: (json['SupplierID'] as num?)?.toInt() ?? 0,
      supplierActualID: (json['SupplierActualID'] as num?)?.toInt() ?? 0,
      unitID: (json['UnitID'] as num?)?.toInt() ?? 0,
      locationID: json['LocationID']?.toString() ?? "",
      // locationID:
      //     (json['LocationID'] == null ||
      //         json['LocationID'].toString().toLowerCase() == 'null')
      //     ? ''
      //     : json['LocationID'].toString(),
      unitName: json['UnitName'] ?? '',
      countryName: json['CountryName'] ?? '',
      manufacturerName: json['ManufacturerName'] ?? '',
      vehicleTypeName: json['VehicleTypeName'] ?? '',
      supplierName: json['SupplierName'] ?? '',
      supplierActualName: json['SupplierActualName'] ?? '',
      img1: json['Img1'] ?? '',
      img2: json['Img2'] ?? '',
      img3: json['Img3'] ?? '',
      remarkOfProduct: json['RemarkOfProduct'] ?? '',
      lastTime: json['LastTime'] != null
          ? DateTime.tryParse(json['LastTime'])
          : null,
      remarkOfDataWarehouse: json['RemarkOfDataWarehouse'] ?? '',
      lastUser: json['lastUser'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'DataWareHouseAID': dataWareHouseAID,
      'ProductAID': productAID,
      'ProductID': productID,
      'ID_Keeton': idKeeton,
      'ID_Industrial': idIndustrial,
      'ID_PartNo': idPartNo,
      'ID_ReplacedPartNo': idReplacedPartNo,
      'NameProduct': nameProduct,
      'Qty_Expected': qtyExpected,
      'ID_Bill': idBill,
      'Parameter': parameter,
      'VehicleDetail': vehicleDetail,
      'VehicleCluster': vehicleCluster,
      'VehicleTypeID': vehicleTypeID,
      'Qty': qty,
      'ManufacturerID': manufacturerID,
      'CountryID': countryID,
      'SupplierID': supplierID,
      'SupplierActualID': supplierActualID,
      'UnitID': unitID,
      'LocationID': locationID,
      // 'ManufacturerName': manufacturerName,
      // 'CountryName': countryName,
      // 'VehicleTypeName': vehicleTypeName,
      // 'SupplierActualName': supplierActualName,
      // 'SupplierName': supplierName,
      // 'UnitName': unitName,
      'Img1': img1,
      'Img2': img2,
      'Img3': img3,
      'RemarkOfProduct': remarkOfProduct,
      'LastTime': lastTime?.toIso8601String(),
      'RemarkOfDataWarehouse': remarkOfDataWarehouse,
      'lastUser': lastUser,
    };
  }

  /// ---- copyWith (để update object dễ dàng) ----
  WareHouse copyWith({
    int? dataWareHouseAID,
    int? productAID,
    String? productID,
    String? idKeeton,
    String? idIndustrial,
    String? idPartNo,
    String? idReplacedPartNo,
    String? nameProduct,
    double? qtyExpected,
    String? idBill,
    String? parameter,
    String? vehicleDetail,
    String? vehicleCluster,
    String? vehicleTypeID,
    double? qty,
    int? manufacturerID,
    int? countryID,
    int? supplierID,
    int? supplierActualID,
    int? unitID,
    String? locationID,
    String? manufacturerName,
    String? vehicleTypeName,
    String? countryName,
    String? supplierActualName,
    String? supplierName,
    String? unitName,
    String? img1,
    String? img2,
    String? img3,
    String? remarkOfProduct,
    DateTime? lastTime,
    String? remarkOfDataWarehouse,
    String? lastUser,
  }) {
    return WareHouse(
      dataWareHouseAID: dataWareHouseAID ?? this.dataWareHouseAID,
      productAID: (productAID as num?)?.toInt() ?? this.productAID,
      productID: productID ?? this.productID,
      idKeeton: idKeeton ?? this.idKeeton,
      idIndustrial: idIndustrial ?? this.idIndustrial,
      idPartNo: idPartNo ?? this.idPartNo,
      idReplacedPartNo: idReplacedPartNo ?? this.idReplacedPartNo,
      nameProduct: nameProduct ?? this.nameProduct,
      qtyExpected: qtyExpected?.toDouble() ?? this.qtyExpected,
      idBill: idBill ?? this.idBill,
      parameter: parameter ?? this.parameter,
      vehicleDetail: vehicleDetail ?? this.vehicleDetail,
      vehicleCluster: vehicleCluster ?? this.vehicleCluster,
      vehicleTypeID: vehicleTypeID ?? this.vehicleTypeID,
      qty: qty?.toDouble() ?? this.qty,
      manufacturerID: (manufacturerID as num?)?.toInt() ?? this.manufacturerID,
      countryID: (countryID as num?)?.toInt() ?? this.countryID,
      supplierID: (supplierID as num?)?.toInt() ?? this.supplierID,
      supplierActualID:
          (supplierActualID as num?)?.toInt() ?? this.supplierActualID,
      unitID: (unitID as num?)?.toInt() ?? this.unitID,
      locationID: locationID ?? this.locationID,
      supplierActualName: supplierActualName ?? this.supplierActualName,
      supplierName: supplierName ?? this.supplierName,
      countryName: countryName ?? this.countryName,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      vehicleTypeName: vehicleTypeName ?? this.vehicleTypeName,
      unitName: unitName ?? this.unitName,
      img1: img1 ?? this.img1,
      img2: img2 ?? this.img2,
      img3: img3 ?? this.img3,
      remarkOfProduct: remarkOfProduct ?? this.remarkOfProduct,
      lastTime: lastTime ?? this.lastTime,
      remarkOfDataWarehouse:
          remarkOfDataWarehouse ?? this.remarkOfDataWarehouse,
      lastUser: lastUser ?? this.lastUser,
    );
  }

  /// ---- equals & hashCode (so sánh 2 object) ----
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WareHouse &&
          runtimeType == other.runtimeType &&
          dataWareHouseAID == other.dataWareHouseAID &&
          productAID == other.productAID;

  @override
  int get hashCode => dataWareHouseAID.hashCode ^ productAID.hashCode;

  /// ---- toString (in ra log dễ đọc) ----
  @override
  String toString() {
    return 'WareHouse(product: $nameProduct, qty: $qty, lastTime: $lastTime)';
  }

  /// ---- Tính toán hoặc xử lý phụ ----
  bool get isLowStock => (qty ?? 0) < (qtyExpected ?? 0);

  String get formattedLastTime => lastTime != null
      ? '${lastTime!.day}/${lastTime!.month}/${lastTime!.year}'
      : 'N/A';

  /// ✅ Constructor rỗng
  factory WareHouse.empty() {
    return const WareHouse(
      dataWareHouseAID: 0,
      productAID: 0,
      productID: '',
      idKeeton: '',
      idIndustrial: '',
      idPartNo: '',
      idReplacedPartNo: '',
      nameProduct: '',
      qtyExpected: 0,
      idBill: '',
      parameter: '',
      vehicleDetail: '',
      vehicleCluster: '',
      vehicleTypeID: '',
      qty: 0,
      manufacturerID: null, // hoặc 0
      countryID: null, // hoặc 0
      supplierID: null, // hoặc 0
      supplierActualID: null, // hoặc 0
      unitID: null, // hoặc 0
      locationID: null, // hoặc 0
      vehicleTypeName: '',
      manufacturerName: '',
      countryName: '',
      supplierName: '',
      supplierActualName: '',
      unitName: '',
      img1: '',
      img2: '',
      img3: '',
      remarkOfProduct: '',
      lastTime: null,
      remarkOfDataWarehouse: '',
      lastUser: '',
    );
  }
}
