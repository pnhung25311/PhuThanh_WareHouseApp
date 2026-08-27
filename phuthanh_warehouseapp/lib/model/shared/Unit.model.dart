class Unit {
  final int UnitID;
  final String Name;

  Unit({required this.UnitID, required this.Name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      UnitID: (json['UnitID'] as num?)?.toInt() ?? 0,
      Name: json['Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'UnitID': UnitID, 'Name': Name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Unit && other.UnitID == UnitID);

  @override
  int get hashCode => UnitID.hashCode;
}
