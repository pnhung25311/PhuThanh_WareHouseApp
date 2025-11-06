class WarehouseTable {
  final int wareHouseID;
  final String nameWareHouse;
  final String wareHouseTable;
  final int wareHouseCategory;

  WarehouseTable({
    required this.wareHouseID,
    required this.nameWareHouse,
    required this.wareHouseTable,
    required this.wareHouseCategory,
  });

  factory WarehouseTable.fromJson(Map<String, dynamic> json) {
    return WarehouseTable(
      wareHouseID: json['WareHouseID'],
      nameWareHouse: json['NameWareHouse'],
      wareHouseTable: json['WareHouseTable'],
      wareHouseCategory: json['WareHouseCategory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'WareHouseID': wareHouseID,
      'NameWareHouse': nameWareHouse,
      'WareHouseTable': wareHouseTable,
      'WareHouseCategory': wareHouseCategory,
    };
  }

  @override
  String toString() {
    return 'WarehouseTable(wareHouseID: $wareHouseID, nameWareHouse: $nameWareHouse, wareHouseTable: $wareHouseTable, wareHouseCategory: $wareHouseCategory)';
  }
}
