class ViewHistory {
  final String historyAID;
  final String dataWareHouseAID;
  final double qty;
  final int employeeId;
  final String nameEmployee;
  final int partner;
  final String nameSupplier;
  final String remark;
  final String time;
  final String lastUser;
  final String lastTime;

  ViewHistory({
    required this.historyAID,
    required this.dataWareHouseAID,
    required this.qty,
    required this.employeeId,
    required this.nameEmployee,
    required this.partner,
    required this.nameSupplier,
    required this.remark,
    required this.time,
    required this.lastUser,
    required this.lastTime,
  });

  /// ✅ Constructor để tạo object rỗng (empty)
  factory ViewHistory.empty() {
    return ViewHistory(
      historyAID: "",
      dataWareHouseAID: "",
      qty: 0.0,
      employeeId: 0,
      nameEmployee: "",
      partner: 0,
      nameSupplier: "",
      remark: "",
      time: "",
      lastUser: "",
      lastTime: "",
    );
  }

  factory ViewHistory.fromJson(Map<String, dynamic> json) {
    return ViewHistory(
      historyAID: json['HistoryAID'] ?? '',
      dataWareHouseAID: json['DataWareHouseAID'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      employeeId: json['ID_Employee'] ?? 0,
      nameEmployee: json['NameEmployee'] ?? "",
      partner: json['Partner'] ?? 0,
      nameSupplier: json['NameSupplier'] ?? "",
      remark: json['Remark'] ?? '',
      time: json['Time'] ?? '',
      lastUser: json['LastUser'] ?? '',
      lastTime: json['LastTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'HistoryAID': historyAID,
      'DataWareHouseAID': dataWareHouseAID,
      'Qty': qty,
      'ID_Employee': employeeId,
      'NameEmployee': nameEmployee,
      'Partner': partner,
      'NameSupplier': nameSupplier,
      'Remark': remark,
      'Time': time,
      'LastUser': lastUser,
      'LastTime': lastTime,
    };
  }
}
