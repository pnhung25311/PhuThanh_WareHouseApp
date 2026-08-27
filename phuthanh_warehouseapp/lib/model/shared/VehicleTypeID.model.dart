class VehicleType {
  final int VehicleTypeID;
  final String VehicleTypeName;

  VehicleType({required this.VehicleTypeID, required this.VehicleTypeName});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      VehicleTypeID: (json['VehicleTypeID'] as num?)?.toInt() ?? 0,
      VehicleTypeName: json['VehicleTypeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'UnitID': VehicleTypeID, 'Name': VehicleTypeName};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VehicleType && other.VehicleTypeID == VehicleTypeID);

  @override
  int get hashCode => VehicleTypeID.hashCode;
}
