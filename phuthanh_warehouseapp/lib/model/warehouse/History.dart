class History {
  final int? id;
  final String? productID;
  final double qty;
  final int? idEmployee;
  final String? fullName;
  final int? partner;
  final String? remark;
  final String? time;
  final String? timeUpdate;

  History({
    this.id,
    this.productID,
    required this.qty,
    this.idEmployee,
    this.fullName,
    this.partner,
    this.remark,
    this.time,
    this.timeUpdate,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['ID'] as int?,
      productID: json['ProductID']?.toString(),
      qty: (json['Qty'] ?? 0).toDouble(),
      idEmployee: json['ID_Employee'] as int?,
      partner: json['Partner'] as int?,
      remark: json['Remark']?.toString(),
      time: json['Time']?.toString(),
      timeUpdate: json['Time_Update']?.toString(),
      fullName: json['FullName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ProductID': productID,
      'Qty': qty,
      'ID_Employee': idEmployee,
      'Partner': partner,
      'Remark': remark,
      'Time': time,
      'Time_Update': timeUpdate,
      'FullName': fullName,
    };
  }

  factory History.empty() {
    return History(
      id: null,
      productID: null,
      qty: 0,
      idEmployee: null,
      partner: null,
      remark: '',
      time: '',
      timeUpdate: '',
      fullName: '',
    );
  }
}
