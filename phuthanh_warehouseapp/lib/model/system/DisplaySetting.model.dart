class DisplaySetting {
  final bool showIDKeeton;
  final bool showIndustrial;
  final bool showIDPartNo;
  final bool showIDReplacedPartNo;
  final bool showNameProduct;
  final bool showParameter;
  final bool showVehicleDetails;
  final bool showRemark;
  final bool showUnitName;
  final bool showVehicleTypeName;
  final bool showCountryName;
  final bool showManufacturerName;
  final bool showSupplierName;
  final bool showSupplierActualName;

  const DisplaySetting({
    this.showIDKeeton = true,
    this.showIndustrial = true,
    this.showIDPartNo = true,
    this.showIDReplacedPartNo = true,
    this.showNameProduct = true,
    this.showParameter = true,
    this.showVehicleDetails = true,
    this.showRemark = true,
    this.showUnitName = true,
    this.showVehicleTypeName = true,
    this.showCountryName = true,
    this.showManufacturerName = true,
    this.showSupplierName = true,
    this.showSupplierActualName = true,
  });

  /// from Map (settings)
  factory DisplaySetting.fromJson(Map<String, dynamic>? settings) {
    final s = settings ?? {};
    return DisplaySetting(
      showIDKeeton: s["showID_Keeton"] ?? true,
      showIndustrial: s["showIndustrial"] ?? true,
      showIDPartNo: s["showID_PartNo"] ?? true,
      showIDReplacedPartNo: s["showID_ReplacedPartNo"] ?? true,
      showNameProduct: s["showNameProduct"] ?? true,
      showParameter: s["showParameter"] ?? true,
      showVehicleDetails: s["showVehicleDetails"] ?? true,
      showRemark: s["showRemark"] ?? true,
      showUnitName: s["showUnitName"] ?? true,
      showVehicleTypeName: s["showVehicleTypeName"] ?? true,
      showCountryName: s["showCountryName"] ?? true,
      showManufacturerName: s["showManufacturerName"] ?? true,
      showSupplierName: s["showSupplierName"] ?? true,
      showSupplierActualName: s["showSupplierActualName"] ?? true,
    );
  }

  /// to Map (lưu setting)
  Map<String, dynamic> toJson() => {
        "showID_Keeton": showIDKeeton,
        "showIndustrial": showIndustrial,
        "showID_PartNo": showIDPartNo,
        "showID_ReplacedPartNo": showIDReplacedPartNo,
        "showNameProduct": showNameProduct,
        "showParameter": showParameter,
        "showVehicleDetails": showVehicleDetails,
        "showRemark": showRemark,
        "showUnitName": showUnitName,
        "showVehicleTypeName": showVehicleTypeName,
        "showCountryName": showCountryName,
        "showManufacturerName": showManufacturerName,
        "showSupplierName": showSupplierName,
        "showSupplierActualName": showSupplierActualName,
      };

  DisplaySetting copyWith({
    bool? showIDKeeton,
    bool? showIndustrial,
    bool? showIDPartNo,
    bool? showIDReplacedPartNo,
    bool? showNameProduct,
    bool? showParameter,
    bool? showVehicleDetails,
    bool? showRemark,
    bool? showUnitName,
    bool? showVehicleTypeName,
    bool? showCountryName,
    bool? showManufacturerName,
    bool? showSupplierName,
    bool? showSupplierActualName,
  }) {
    return DisplaySetting(
      showIDKeeton: showIDKeeton ?? this.showIDKeeton,
      showIndustrial: showIndustrial ?? this.showIndustrial,
      showIDPartNo: showIDPartNo ?? this.showIDPartNo,
      showIDReplacedPartNo:
          showIDReplacedPartNo ?? this.showIDReplacedPartNo,
      showNameProduct: showNameProduct ?? this.showNameProduct,
      showParameter: showParameter ?? this.showParameter,
      showVehicleDetails:
          showVehicleDetails ?? this.showVehicleDetails,
      showRemark: showRemark ?? this.showRemark,
      showUnitName: showUnitName ?? this.showUnitName,
      showVehicleTypeName:
          showVehicleTypeName ?? this.showVehicleTypeName,
      showCountryName: showCountryName ?? this.showCountryName,
      showManufacturerName:
          showManufacturerName ?? this.showManufacturerName,
      showSupplierName: showSupplierName ?? this.showSupplierName,
      showSupplierActualName:
          showSupplierActualName ?? this.showSupplierActualName,
    );
  }
}
