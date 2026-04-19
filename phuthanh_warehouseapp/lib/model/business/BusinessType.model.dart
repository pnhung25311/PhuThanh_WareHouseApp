class BusinessType {
  final int BusinessTypeID;
  final String Name;

  BusinessType({required this.BusinessTypeID, required this.Name});

  factory BusinessType.fromJson(Map<String, dynamic> json) {
    return BusinessType(
      BusinessTypeID: (json['BusinessID'] as num?)?.toInt() ?? 0,
      Name: json['Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'BusinessID': BusinessTypeID, 'Name': Name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessType && other.BusinessTypeID == BusinessTypeID);

  @override
  int get hashCode => BusinessTypeID.hashCode;
}
