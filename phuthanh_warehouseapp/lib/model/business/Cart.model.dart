import 'package:intl/intl.dart';

class Cart {
  final int cartAID;
  final String? cartID;
  final int? accountID;
  final String? fullName;

  final int? productAID;
  final String? productID;
  final String? idPartNo;
  final String? nameProduct;

  final double? qty;
  final int? partner;
  final String? supplierName;

  final int? manufacturerID;
  final String? manufacturerName;

  final int? countryID;
  final String? countryName;

  final bool? status;
  final String? remark;
  final DateTime? deliveryTime;
  final DateTime? lastTime;

  Cart({
    required this.cartAID,
    this.cartID,
    this.accountID,
    this.fullName,
    this.productAID,
    this.productID,
    this.idPartNo,
    this.nameProduct,
    this.qty,
    this.partner,
    this.supplierName,
    this.manufacturerID,
    this.manufacturerName,
    this.countryID,
    this.countryName,
    this.status,
    this.remark,
    this.deliveryTime,
    this.lastTime,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartAID: _toInt(json['CartAID']),
      cartID: json['CartID']?.toString(),
      accountID: _toInt(json['AccountID']),
      fullName: json['FullName']?.toString(),

      productAID: _toInt(json['ProductAID']),
      productID: json['ProductID']?.toString(),
      idPartNo: json['ID_PartNo']?.toString(),
      nameProduct: json['NameProduct']?.toString(),

      qty: _toDouble(json['Qty']),
      partner: _toInt(json['Partner']),
      supplierName: json['Name']?.toString(),
      manufacturerID: _toInt(json['ManufacturerID']),
      manufacturerName: json['ManufacturerName']?.toString(),
      countryID: _toInt(json['CountryID']),
      countryName: json['CountryName']?.toString(),

      status: _toBool(json['Status']),
      remark: json['Remark']?.toString(),
      deliveryTime: _toDate(json['DeliveryTime']),
      lastTime: _toDate(json['LastTime']),
    );
  }

  Map<String, dynamic> toJson() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return {
      'CartID': cartID,
      'AccountID': accountID,
      'ProductAID': productAID,
      'Qty': qty,
      'Partner': partner,
      'Status': status == true ? 1 : 0,
      'Remark': remark,
      'DeliveryTime': deliveryTime != null
          ? formatter.format(deliveryTime!)
          : null,
      'LastTime': lastTime != null ? formatter.format(lastTime!) : null,
    };
  }

  factory Cart.empty() {
    return Cart(
      cartAID: 0,
      cartID: '',
      accountID: 0,
      fullName: '',
      productAID: 0,
      productID: '',
      idPartNo: '',
      nameProduct: '',
      qty: 0,
      partner: 0,
      supplierName: '',
      manufacturerID: 0,
      manufacturerName: '',
      countryID: 0,
      countryName: '',
      status: false,
      remark: '',
      deliveryTime: null,
      lastTime: null,
    );
  }

  Cart copyWith({
    int? cartAID,
    String? cartID,
    int? accountID,
    String? fullName,
    int? productAID,
    String? productID,
    String? idPartNo,
    String? nameProduct,
    double? qty,
    int? partner,
    String? supplierName,
    int? manufacturerID,
    String? manufacturerName,
    int? countryID,
    String? countryName,
    bool? status,
    String? remark,
    DateTime? deliveryTime,
    DateTime? lastTime,
  }) {
    return Cart(
      cartAID: cartAID ?? this.cartAID,
      cartID: cartID ?? this.cartID,
      accountID: accountID ?? this.accountID,
      fullName: fullName ?? this.fullName,
      productAID: productAID ?? this.productAID,
      productID: productID ?? this.productID,
      idPartNo: idPartNo ?? this.idPartNo,
      nameProduct: nameProduct ?? this.nameProduct,
      qty: qty ?? this.qty,
      partner: partner ?? this.partner,
      supplierName: supplierName ?? this.supplierName,
      manufacturerID: manufacturerID ?? this.manufacturerID,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      countryID: partner ?? this.countryID,
      countryName: supplierName ?? this.countryName,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      lastTime: lastTime ?? this.lastTime,
    );
  }

  // ================= HELPER =================

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString() == '1';
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
