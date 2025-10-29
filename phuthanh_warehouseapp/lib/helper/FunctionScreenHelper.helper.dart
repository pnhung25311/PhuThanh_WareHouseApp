import 'package:flutter/material.dart';

class NavigationHelper {
  /// 👉 Chuyển sang màn hình mới (có thể quay lại màn hình cũ)
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// 👉 Chuyển sang màn hình mới và xóa màn hình hiện tại (không quay lại được)
  static Future<T?> pushReplacement<T>(BuildContext context, Widget screen) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// 👉 Chuyển sang màn hình mới và xóa toàn bộ stack (về mặc định)
  static Future<T?> pushAndRemoveUntil<T>(
      BuildContext context, Widget screen) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  /// 👉 Quay lại màn hình trước
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// 👉 Quay lại đến màn hình đầu tiên
  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// 👉 Kiểm tra có thể quay lại hay không
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// 👉 Chuyển sang màn hình mới bằng tên route (nếu bạn dùng routes trong MaterialApp)
  static Future<T?> pushNamed<T>(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// 👉 Thay thế màn hình hiện tại bằng route có tên
  static Future<T?> pushReplacementNamed<T>(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// 👉 Xóa toàn bộ stack và chuyển đến route có tên
  static Future<T?> pushNamedAndRemoveUntil<T>(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
