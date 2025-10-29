class Manufacturer {
  final int ManufacturerID;
  final String Name;

  Manufacturer({required this.ManufacturerID, required this.Name});

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      ManufacturerID: (json['ManufacturerID'] as num?)?.toInt() ?? 0,
      Name: json['Name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Manufacturer && other.ManufacturerID == ManufacturerID);

  @override
  int get hashCode => ManufacturerID.hashCode;
}
