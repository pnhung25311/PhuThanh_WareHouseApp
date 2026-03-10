class Employee {
  final int EmployeeID;
  final String NameEmployee;

  Employee({
    required this.EmployeeID,
    required this.NameEmployee,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      EmployeeID: (json['EmployeeID'] as num?)?.toInt() ?? 0,
      NameEmployee: json['NameEmployee'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmployeeID': EmployeeID,
      'NameEmployee': NameEmployee,
    };
  }

  @override
bool operator ==(Object other) =>
    identical(this, other) ||
    (other is Employee && other.EmployeeID == EmployeeID);

@override
int get hashCode => EmployeeID.hashCode;

}
