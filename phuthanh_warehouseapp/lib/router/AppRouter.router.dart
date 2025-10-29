import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/HomeScreen.screen.dart';
// import 'package:phuthanh_warehouseapp/Screen/WareHouse/WareHouseScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/test.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const Loginscreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/test':
        return MaterialPageRoute(
          builder: (_) => const AddAppendixScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
