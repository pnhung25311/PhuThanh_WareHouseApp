class DrawerItem {
  int? wareHouseID;
  String? nameWareHouse;
  String? wareHouseTable;
  String? wareHouseHistory;
  int? wareHouseCategory; // int
  String? wareHouseDataBase;
  String? wareHouseDataBaseHistory;
  String? wareHouseRequest;
  String? wareHouseRequestDataBase;
  String? wareHouseUpdateHistoryDataBase;
  String? wareHouseUpdateHistory;
  String? wareHouseSheetDataBase;
  String? wareHouseCheckDataBase;
  String? wareHouseDataCheck;
  int? wareHouseSupplierID;

  DrawerItem({
    this.wareHouseID,
    this.nameWareHouse,
    this.wareHouseTable,
    this.wareHouseHistory,
    this.wareHouseCategory,
    this.wareHouseDataBase,
    this.wareHouseDataBaseHistory,
    this.wareHouseRequest,
    this.wareHouseRequestDataBase,
    this.wareHouseUpdateHistoryDataBase,
    this.wareHouseUpdateHistory,
    this.wareHouseSheetDataBase,
    this.wareHouseCheckDataBase,
    this.wareHouseDataCheck,
    this.wareHouseSupplierID,
  });

  factory DrawerItem.fromJson(Map<String, dynamic> json) {
    return DrawerItem(
      wareHouseID: json['WareHouseID'] is int
          ? json['WareHouseID']
          : int.tryParse(json['WareHouseID'].toString()),
      nameWareHouse: json['NameWareHouse'],
      wareHouseTable: json['WareHouseTable'],
      wareHouseHistory: json['WareHouseHistory'],
      wareHouseCategory: json['WareHouseCategory'] is int
          ? json['WareHouseCategory']
          : int.tryParse(json['WareHouseCategory'].toString()),
      wareHouseDataBase: json['WareHouseDataBase'],
      wareHouseDataBaseHistory: json['WareHouseDataBaseHistory'],
      wareHouseRequest: json['WareHouseRequest'],
      wareHouseRequestDataBase: json['WareHouseRequestDataBase'],
      wareHouseUpdateHistoryDataBase: json['WareHouseUpdateHistoryDataBase'],
      wareHouseUpdateHistory: json['WareHouseUpdateHistory'],
      wareHouseSheetDataBase: json['WareHouseSheetDataBase'],
      wareHouseCheckDataBase: json['WareHouseCheckDataBase'],
      wareHouseDataCheck: json['WareHouseDataCheck'],
      wareHouseSupplierID: json['WareHouseSupplierID'] is int
          ? json['WareHouseSupplierID']
          : int.tryParse(json['WareHouseSupplierID'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'WareHouseID': wareHouseID,
      'NameWareHouse': nameWareHouse,
      'WareHouseTable': wareHouseTable,
      'WareHouseHistory': wareHouseHistory,
      'WareHouseCategory': wareHouseCategory,
      'WareHouseDataBase': wareHouseDataBase,
      'WareHouseDataBaseHistory': wareHouseDataBaseHistory,
      'WareHouseRequest': wareHouseRequest,
      'WareHouseRequestDataBase': wareHouseRequestDataBase,
      'WareHouseUpdateHistoryDataBase': wareHouseUpdateHistoryDataBase,
      'WareHouseUpdateHistory': wareHouseUpdateHistory,
      'WareHouseSheetDataBase': wareHouseSheetDataBase,
      'WareHouseCheckDataBase': wareHouseCheckDataBase,
      'WareHouseSupplierID': wareHouseSupplierID,
    };
  }
}
