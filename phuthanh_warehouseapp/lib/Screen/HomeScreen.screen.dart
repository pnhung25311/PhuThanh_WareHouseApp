import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/ScanBarcodeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WareHouseSearchScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WareHouseScreenHome.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomBottomNavigator.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  NavigationHelper navigationHelper = NavigationHelper();

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavigator(
      currentIndex: _selectedIndex,
      onTabChanged: _onTabChanged,
      screens: const [
        WareHouseScreen(),
        SizedBox(), // Scan không phải tab
        SearchScreen(),
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
      scanIndex: 1,
      onScanTap: () {
        navigationHelper.push(context, ScanScreen(isUpdate: true));
      },
    );
  }
}
