class History {
  final int? historyAID;
  final int dataWareHouseAID;
  final double qty;
  final int employeeId;
  final int partner;
  final String remark;
  final String time;
  final String transferGroupID;
  final String lastUser;
  final String lastTime;

  History({
    this.historyAID,
    required this.dataWareHouseAID,
    required this.qty,
    required this.employeeId,
    required this.partner,
    required this.remark,
    required this.time,
    required this.transferGroupID,
    required this.lastUser,
    required this.lastTime,
  });

  /// ✅ Constructor để tạo object rỗng (empty)
  factory History.empty() {
    return History(
      historyAID: 0,
      dataWareHouseAID: 0,
      qty: 0.0,
      employeeId: 0,
      partner: 0,
      remark: "",
      time: "",
      transferGroupID: "",
      lastUser: "",
      lastTime: "",
    );
  }

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      historyAID: int.tryParse(json['HistoryAID']?.toString() ?? '') ?? 0,
      dataWareHouseAID: int.tryParse(json['DataWareHouseAID']?.toString() ?? '') ?? 0,
      qty: (json['Qty'] ?? 0).toDouble(),
      employeeId: json['ID_Employee'] ?? 0,
      partner: json['Partner'] ?? 0,
      remark: json['Remark'] ?? '',
      time: json['Time'] ?? '',
      transferGroupID: json['TransferGroupID'] ?? '',
      lastUser: json['LastUser'] ?? '',
      lastTime: json['LastTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'HistoryAID': historyAID,
      'DataWareHouseAID': dataWareHouseAID,
      'Qty': qty,
      'ID_Employee': employeeId,
      'Partner': partner,
      'Remark': remark,
      'Time': time,
      'TransferGroupID': transferGroupID,
      'LastUser': lastUser,
      'LastTime': lastTime,
    };
  }
}
