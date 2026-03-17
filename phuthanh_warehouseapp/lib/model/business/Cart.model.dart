class Cart {
  final int cartAID;
  final String? cartID;
  final int? accountID;
  final int? partner;
  final int? supplierID;
  final String? supplierName;
  final String? fullName;
  final String? status;
  final String? remark;
  final DateTime? orderTime;
  final DateTime? lastTime;

  Cart({
    required this.cartAID,
    this.cartID,
    this.accountID,
    this.partner,
    this.supplierID,
    this.supplierName,
    this.fullName,
    this.status,
    this.remark,
    this.orderTime,
    this.lastTime,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartAID: _toInt(json['CartAID']),
      cartID: json['CartID']?.toString(),
      accountID: _toInt(json['AccountID']),
      partner: _toInt(json['Partner']),
      supplierID: _toInt(json['SupplierID']),
      supplierName: json['SupplierName']?.toString(),
      fullName: json['FullName']?.toString(),
      status: json['Status']?.toString(),
      remark: json['Remark']?.toString(),
      orderTime: _toDate(json['OrderTime']),
      lastTime: _toDate(json['LastTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'CartAID': cartAID,
      'CartID': cartID,
      'AccountID': accountID,
      'Partner': partner,
      'Status': status,
      'Remark': remark,
      'OrderTime': orderTime,
      'LastTime': lastTime?.toIso8601String(),
    };
  }

  factory Cart.empty() {
    return Cart(
      cartAID: 0,
      cartID: '',
      accountID: 0,
      partner: 0,
      supplierID: 0,
      supplierName: '',
      fullName: '',
      status: '',
      remark: '',
      orderTime: null,
      lastTime: null,
    );
  }
  Cart copyWith({
    int? cartAID,
    String? cartID,
    int? accountID,
    int? partner,
    int? supplierID,
    String? supplierName,
    String? fullName,
    String? status,
    String? remark,
    DateTime? orderTime,
    DateTime? lastTime,
  }) {
    return Cart(
      cartAID: cartAID ?? this.cartAID,
      cartID: cartID ?? this.cartID,
      accountID: accountID ?? this.accountID,
      partner: partner ?? this.partner,
      supplierID: supplierID ?? this.supplierID,
      supplierName: supplierName ?? this.supplierName,
      fullName: fullName ?? this.fullName,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      orderTime: orderTime ?? this.orderTime,
      lastTime: lastTime ?? this.lastTime,
    );
  }

  // ================= HELPER =================

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
