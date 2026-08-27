class Payment {
  final int PaymentID;
  final String Name;

  Payment({required this.PaymentID, required this.Name});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      PaymentID: (json['PaymentID'] as num?)?.toInt() ?? 0,
      Name: json['Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'PaymentID': PaymentID, 'Name': Name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment && other.PaymentID == PaymentID);

  @override
  int get hashCode => PaymentID.hashCode;
}
