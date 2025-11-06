class History {
  final String historyAID;
  final String dataWareHouseAID;
  final double qty;
  final int employeeId;
  final int partner;
  final String remark;
  final String time;
  final String lastUser;
  final String lastTime;

  History({
    required this.historyAID,
    required this.dataWareHouseAID,
    required this.qty,
    required this.employeeId,
    required this.partner,
    required this.remark,
    required this.time,
    required this.lastUser,
    required this.lastTime,
  });

  /// ✅ Constructor để tạo object rỗng (empty)
  factory History.empty() {
    return History(
      historyAID: "",
      dataWareHouseAID: "",
      qty: 0.0,
      employeeId: 0,
      partner: 0,
      remark: "",
      time: "",
      lastUser: "",
      lastTime: "",
    );
  }

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      historyAID: json['HistoryAID'] ?? '',
      dataWareHouseAID: json['DataWareHouseAID'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      employeeId: json['ID_Employee'] ?? 0,
      partner: json['Partner'] ?? 0,
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
      'Partner': partner,
      'Remark': remark,
      'Time': time,
      'LastUser': lastUser,
      'LastTime': lastTime,
    };
  }
}
