import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';

class LoginResponse {
  final Account account;
  final String token;

  LoginResponse({
    required this.account,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      account: Account.fromJson(json['Account']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Account': account.toJson(),
      'token': token,
    };
  }
}
