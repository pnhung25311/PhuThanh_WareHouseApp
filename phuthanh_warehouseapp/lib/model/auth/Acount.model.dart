class Account {
  final int AccountID;
  final String UserName;
  final String PassWord;
  final String FullName;
  final String Role;
  final String Status;
  Account({
    required this.AccountID,
    required this.UserName,
    required this.PassWord,
    required this.FullName,
    required this.Role,
    required this.Status,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      AccountID: (json['AccountID'] as num?)?.toInt() ?? 0,
      PassWord: json['PassWord'] ?? '',
      UserName: json['UserName'] ?? '',
      Role: json['Role'] ?? '',
      FullName: json['FullName'] ?? '',
      Status: json['Status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccountID': AccountID,
      'PassWord': PassWord,
      'UserName': UserName,
      'FullName': FullName,
      'Role': Role,
      'Status':Status
    };
  }
}
