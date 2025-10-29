class Account {
  final int AccountID;
  final String UserName;
  final String PassWord;
  final String FullName;

  Account({
    required this.AccountID,
    required this.UserName,
    required this.PassWord,
    required this.FullName,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      AccountID: (json['AccountID'] as num?)?.toInt() ?? 0,
      PassWord: json['PassWord'] ?? '',
      UserName: json['UserName'] ?? '',
      FullName: json['FullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccountID': AccountID,
      'PassWord': PassWord,
      'UserName': UserName,
      'FullName': FullName,
    };
  }
}
