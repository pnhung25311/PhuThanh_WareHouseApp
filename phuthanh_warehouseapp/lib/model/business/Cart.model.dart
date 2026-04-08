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

  final int? manufacturerID;
  final String? manufacturerName;

  final int? countryID;
  final String? countryName;

  final int? unitID;
  final String? unitName;

  final double? qty;
  final double? price;
  final double? total;
  final double? priceVAT;
  final double? priceNET;

  final int? paymentID;
  final String? namePayment;

  final int? billID;
  final String? billName;

  final int? sourceID;
  final String? nameSource;

  final int? deliveryID;
  final String? nameDelivery;

  final int? employeeID;
  final String? nameEmployee;

  final int? statusID;
  final String? nameStatus;

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
    this.manufacturerID,
    this.manufacturerName,
    this.countryID,
    this.countryName,
    this.unitID,
    this.unitName,
    this.qty,
    this.price,
    this.total,
    this.priceVAT,
    this.priceNET,
    this.paymentID,
    this.namePayment,
    this.billID,
    this.billName,
    this.sourceID,
    this.nameSource,
    this.deliveryID,
    this.nameDelivery,
    this.employeeID,
    this.nameEmployee,
    this.statusID,
    this.nameStatus,
    this.remark,
    this.deliveryTime,
    this.lastTime,
  });

  // ================= FROM JSON =================

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

      manufacturerID: _toInt(json['ManufacturerID']),
      manufacturerName: json['ManufacturerName']?.toString(),

      countryID: _toInt(json['CountryID']),
      countryName: json['CountryName']?.toString(),

      unitID: _toInt(json['UnitID']),
      unitName: json['UnitName']?.toString(),

      qty: _toDouble(json['Qty']),
      price: _toDouble(json['Price']),
      total: _toDouble(json['Total']),
      priceVAT: _toDouble(json['PriceVAT']),
      priceNET: _toDouble(json['PriceNET']),

      paymentID: _toInt(json['PaymentID']),
      namePayment: json['NamePayment']?.toString(),

      billID: _toInt(json['BillID']),
      billName: json['NameBill']?.toString(),

      sourceID: _toInt(json['SourceID']),
      nameSource: json['NameSource']?.toString(),

      deliveryID: _toInt(json['DeliveryID']),
      nameDelivery: json['NameDelivery']?.toString(),

      employeeID: _toInt(json['EmployeeID']),
      nameEmployee: json['NameEmployee']?.toString(),

      statusID: _toInt(json['StatusID']),
      nameStatus: json['NameStatus']?.toString(),

      remark: json['Remark']?.toString(),
      deliveryTime: _toDate(json['DeliveryTime']),
      lastTime: _toDate(json['LastTime']),
    );
  }

  // ================= TO JSON =================
  /// dùng cho INSERT / UPDATE
  Map<String, dynamic> toJson() {
    final f = DateFormat('yyyy-MM-dd HH:mm:ss');

    return {
      'CartID': cartID,
      'AccountID': accountID,
      'ProductAID': productAID,
      'Qty': qty,
      'Price': price,
      'Total': total,
      'PriceVAT': priceVAT,
      'PriceNET': priceNET,
      'PaymentID': paymentID,
      'BillID': billID,
      'SourceID': sourceID,
      'DeliveryID': deliveryID,
      'EmployeeID': employeeID,
      'Status': statusID,
      'Remark': remark,
      'DeliveryTime': deliveryTime != null ? f.format(deliveryTime!) : null,
      'LastTime': f.format(DateTime.now()),
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

      manufacturerID: 0,
      manufacturerName: '',

      countryID: 0,
      countryName: '',

      unitID: 0,
      unitName: '',

      qty: 0,
      price: 0,
      total: 0,
      priceVAT: 0,
      priceNET: 0,

      paymentID: 0,
      namePayment: '',

      billID: 0,
      billName: '',

      sourceID: 0,
      nameSource: '',

      deliveryID: 0,
      nameDelivery: '',

      employeeID: 0,
      nameEmployee: '',

      statusID: 0,
      nameStatus: '',

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

    int? manufacturerID,
    String? manufacturerName,

    int? countryID,
    String? countryName,

    int? unitID,
    String? unitName,

    double? qty,
    double? price,
    double? total,
    double? priceVAT,
    double? priceNET,

    int? paymentID,
    String? namePayment,

    int? billID,
    String? billName,

    int? sourceID,
    String? nameSource,

    int? deliveryID,
    String? nameDelivery,

    int? employeeID,
    String? nameEmployee,

    int? statusID,
    String? nameStatus,

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

      manufacturerID: manufacturerID ?? this.manufacturerID,
      manufacturerName: manufacturerName ?? this.manufacturerName,

      countryID: countryID ?? this.countryID,
      countryName: countryName ?? this.countryName,

      unitID: unitID ?? this.unitID,
      unitName: unitName ?? this.unitName,

      qty: qty ?? this.qty,
      price: price ?? this.price,
      total: total ?? this.total,
      priceVAT: priceVAT ?? this.priceVAT,
      priceNET: priceNET ?? this.priceNET,

      paymentID: paymentID ?? this.paymentID,
      namePayment: namePayment ?? this.namePayment,

      billID: billID ?? this.billID,
      billName: billName ?? this.billName,

      sourceID: sourceID ?? this.sourceID,
      nameSource: nameSource ?? this.nameSource,

      deliveryID: deliveryID ?? this.deliveryID,
      nameDelivery: nameDelivery ?? this.nameDelivery,

      employeeID: employeeID ?? this.employeeID,
      nameEmployee: nameEmployee ?? this.nameEmployee,

      statusID: statusID ?? this.statusID,
      nameStatus: nameStatus ?? this.nameStatus,

      remark: remark ?? this.remark,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      lastTime: lastTime ?? this.lastTime,
    );
  }
  // ================= HELPER =================

  static int _toInt(dynamic v) =>
      v == null ? 0 : int.tryParse(v.toString()) ?? 0;

  static double _toDouble(dynamic v) =>
      v == null ? 0 : double.tryParse(v.toString()) ?? 0;

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }
}
