class Account {
  final int AccountID;
  final String UserName;
  final String PassWord;
  final String FullName;
  final String Role;
  final String Status;
  String Avatar;
  Account({
    required this.AccountID,
    required this.UserName,
    required this.PassWord,
    required this.FullName,
    required this.Role,
    required this.Status,
    required this.Avatar,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      AccountID: (json['AccountID'] as num?)?.toInt() ?? 0,
      PassWord: json['PassWord'] ?? '',
      UserName: json['UserName'] ?? '',
      Role: json['Role'] ?? '',
      FullName: json['FullName'] ?? '',
      Status: json['Status'] ?? '',
      Avatar: json['Avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccountID': AccountID,
      'PassWord': PassWord,
      'UserName': UserName,
      'FullName': FullName,
      'Role': Role,
      'Status': Status,
      'Avatar': Avatar,
    };
  }

  Account copyWith({
    String? Avatar,
    String? UserName,
    String? PassWord,
    String? FullName,
    String? Role,
    String? Status,
  }) {
    return Account(
      AccountID: AccountID,
      UserName: UserName ?? this.UserName,
      PassWord: PassWord ?? this.PassWord,
      FullName: FullName ?? this.FullName,
      Role: Role ?? this.Role,
      Status: Status ?? this.Status,
      Avatar: Avatar ?? this.Avatar,
    );
  }
}
