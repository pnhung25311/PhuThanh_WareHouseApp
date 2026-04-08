class Bill {
  final int BillID;
  final String Name;

  Bill({required this.BillID, required this.Name});

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      BillID: (json['BillID'] as num?)?.toInt() ?? 0,
      Name: json['Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'BillID': BillID, 'Name': Name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bill && other.BillID == BillID);

  @override
  int get hashCode => BillID.hashCode;
}
