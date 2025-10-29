class Supplier {
  final int SupplierID;
  final String Name;
  final int Category;

  Supplier({
    required this.SupplierID,
    required this.Name,
    required this.Category,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
    SupplierID: json['SupplierID'],
    Name: json['Name'],
    Category: json['Category'],
  );

  // ✅ Thêm phần này
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier && SupplierID == other.SupplierID;

  @override
  int get hashCode => SupplierID.hashCode;
}
