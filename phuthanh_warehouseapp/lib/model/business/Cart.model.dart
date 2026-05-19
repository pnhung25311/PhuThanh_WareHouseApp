import 'package:intl/intl.dart';

class Cart {
  final int cartAID;
  final String? cartID;

  final int? accountID;
  final String? creator; // Account.FullName

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

  final int? productAIDVAT;
  final String? productIDVAT;

  final double? cogs;
  final String? locationID;

  final double? qty;
  final double? price;
  final double? total;
  final double? priceVAT;

  final int? paymentID;
  final String? namePayment;

  final int? billID;
  final String? billName;

  final int? sourceID;
  final String? nameSource;

  final int? deliveryID;
  final String? nameDelivery;

  final int? employeeID;
  final String? proponent; // Employee.NameEmployee

  final int? statusID;
  final String? nameStatus;

  final int? statusVAT;
  final String? nameStatusVAT;

  final String? contractID; // ⭐ FIX: string

  final String? remark;
  final DateTime? deliveryTime;
  final int? businessID;
  final String? businessName;

  final int? typeCartID;
  final String? typeCartName;
  final DateTime? lastTime;
  final DateTime? reportDate;

  Cart({
    required this.cartAID,
    this.cartID,
    this.accountID,
    this.creator,
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
    this.productAIDVAT,
    this.productIDVAT,
    this.cogs,
    this.locationID,
    this.qty,
    this.price,
    this.total,
    this.priceVAT,
    this.paymentID,
    this.namePayment,
    this.billID,
    this.billName,
    this.sourceID,
    this.nameSource,
    this.deliveryID,
    this.nameDelivery,
    this.employeeID,
    this.proponent,
    this.statusID,
    this.nameStatus,
    this.statusVAT,
    this.nameStatusVAT,
    this.contractID,
    this.remark,
    this.deliveryTime,
    this.businessID,
    this.businessName,
    this.typeCartID,
    this.typeCartName,
    this.lastTime,
    this.reportDate,
  });

  Cart copyWith({
    int? cartAID,
    String? cartID,
    int? accountID,
    String? creator,
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
    int? productAIDVAT,
    String? productIDVAT,
    double? cogs,
    String? locationID,
    double? qty,
    double? price,
    double? total,
    double? priceVAT,
    int? paymentID,
    String? namePayment,
    int? billID,
    String? billName,
    int? sourceID,
    String? nameSource,
    int? deliveryID,
    String? nameDelivery,
    int? employeeID,
    String? proponent,
    int? statusID,
    String? nameStatus,
    int? statusVAT,
    String? nameStatusVAT,
    String? contractID,
    String? remark,
    DateTime? deliveryTime,
    int? businessID,
    String? businessName,
    int? typeCartID,
    String? typeCartName,
    DateTime? lastTime,
    DateTime? reportDate,
  }) {
    return Cart(
      cartAID: cartAID ?? this.cartAID,
      cartID: cartID ?? this.cartID,
      accountID: accountID ?? this.accountID,
      creator: creator ?? this.creator,
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
      productAIDVAT: productAIDVAT ?? this.productAIDVAT,
      productIDVAT: productIDVAT ?? this.productIDVAT,
      cogs: cogs ?? this.cogs,
      locationID: locationID ?? this.locationID,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      total: total ?? this.total,
      priceVAT: priceVAT ?? this.priceVAT,
      paymentID: paymentID ?? this.paymentID,
      namePayment: namePayment ?? this.namePayment,
      billID: billID ?? this.billID,
      billName: billName ?? this.billName,
      sourceID: sourceID ?? this.sourceID,
      nameSource: nameSource ?? this.nameSource,
      deliveryID: deliveryID ?? this.deliveryID,
      nameDelivery: nameDelivery ?? this.nameDelivery,
      employeeID: employeeID ?? this.employeeID,
      proponent: proponent ?? this.proponent,
      statusID: statusID ?? this.statusID,
      nameStatus: nameStatus ?? this.nameStatus,
      statusVAT: statusVAT ?? this.statusVAT,
      nameStatusVAT: nameStatusVAT ?? this.nameStatusVAT,
      contractID: contractID ?? this.contractID,
      remark: remark ?? this.remark,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      businessID: businessID ?? this.businessID,
      businessName: businessName ?? this.businessName,
      typeCartID: typeCartID ?? this.typeCartID,
      typeCartName: typeCartName ?? this.typeCartName,
      lastTime: lastTime ?? this.lastTime,
      reportDate: reportDate ?? this.reportDate,
    );
  }

  factory Cart.empty() {
    return Cart(
      cartAID: 0,
      cartID: '',
      accountID: 0,
      creator: '',
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
      productAIDVAT: 0,
      productIDVAT: '',
      cogs: 0,
      locationID: '',
      qty: 0,
      price: 0,
      total: 0,
      priceVAT: 0,
      paymentID: 0,
      namePayment: '',
      billID: 0,
      billName: '',
      sourceID: 0,
      nameSource: '',
      deliveryID: 0,
      nameDelivery: '',
      employeeID: 0,
      proponent: '',
      statusID: 0,
      nameStatus: '',
      statusVAT: 0,
      nameStatusVAT: '',
      contractID: '',
      remark: '',
      deliveryTime: null,
      businessID: 0,
      businessName: '',
      typeCartID: 0,
      typeCartName: '',
      lastTime: null,
      reportDate: null,
    );
  }
  // ================= FROM JSON =================
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartAID: _toInt(json['CartAID']),
      cartID: json['CartID']?.toString(),

      accountID: _toInt(json['AccountID']),
      creator: json['Creator']?.toString(),

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

      productAIDVAT: _toInt(json['ProductAIDVAT']),
      productIDVAT: json['ProductIDVAT']?.toString(),

      qty: _toDouble(json['Qty']),
      price: _toDouble(json['Price']),
      total: _toDouble(json['Total']),
      cogs: _toDouble(json['Cogs']),
      priceVAT: _toDouble(json['PriceVAT']),

      paymentID: _toInt(json['PaymentID']),
      namePayment: json['NamePayment']?.toString(),

      billID: _toInt(json['BillID']),
      billName: json['NameBill']?.toString(),

      sourceID: _toInt(json['SourceID']),
      nameSource: json['NameSource']?.toString(),

      deliveryID: _toInt(json['DeliveryID']),
      nameDelivery: json['NameDelivery']?.toString(),

      employeeID: _toInt(json['EmployeeID']),
      proponent: json['Proponent']?.toString(),

      statusID: _toInt(json['StatusID']),
      nameStatus: json['NameStatus']?.toString(),

      statusVAT: _toInt(json['StatusVAT']),
      nameStatusVAT: json['NameStatusVAT']?.toString(),

      contractID: json['ContractID']?.toString(),
      locationID: json['LocationID']?.toString(),

      remark: json['Remark']?.toString(),
      deliveryTime: _toDate(json['DeliveryTime']),
      businessID: _toInt(json['BusinessID']),
      businessName: json['BusinessName']?.toString(),

      typeCartID: _toInt(json['TypeCartID']),
      typeCartName: json['TypeCartName']?.toString(),
      lastTime: _toDate(json['LastTime']),
      reportDate: _toDate(json['ReportDate']),
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    final f = DateFormat('yyyy-MM-dd HH:mm:ss');

    return {
      'CartID': cartID,
      'AccountID': accountID,
      'ProductAID': productAID,
      'ProductAIDVAT': productAIDVAT,
      'NameProduct': nameProduct,
      'ID_PartNo': idPartNo,
      'ManufacturerID': manufacturerID,
      'CountryID': countryID,
      'UnitID': unitID,
      'Qty': qty,
      'PriceNET': price,
      'Total': total,
      'Cogs': cogs,
      'PriceVAT': priceVAT,
      'PaymentID': paymentID,
      'BillID': billID,
      'SourceID': sourceID,
      'DeliveryID': deliveryID,
      'EmployeeID': employeeID,
      'Status': statusID,
      'StatusVAT': statusVAT,
      'ContractID': contractID,
      'Remark': remark,
      'DeliveryTime': deliveryTime != null ? f.format(deliveryTime!) : null,
      'BusinessID': businessID,
      'TypeCartID': typeCartID,
      'LastTime': f.format(DateTime.now()),
      'ReportDate': reportDate != null ? f.format(reportDate!) : null,
    };
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
