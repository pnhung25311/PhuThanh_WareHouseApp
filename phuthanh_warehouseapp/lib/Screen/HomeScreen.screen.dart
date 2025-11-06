import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WareHouseSearchScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WareHouseScreenHome.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomBottomNavigator.custom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomBottomNavigator(
      screens: const [
        WareHouseScreen(),
        Loginscreen(),      // sửa tên class đúng
        SearchScreen(),     // class SearchScreen đã đúng
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
      selectedColor: Colors.blueAccent,
      unselectedColor: Colors.grey,
    );
  }
}
