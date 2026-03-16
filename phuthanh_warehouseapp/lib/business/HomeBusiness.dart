import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/screen/BusinessScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomBottomNavigator.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';

class HomeBusinessScreen extends StatefulWidget {
  const HomeBusinessScreen({super.key});

  @override
  State<HomeBusinessScreen> createState() => _HomeBusinessScreenState();
}

class _HomeBusinessScreenState extends State<HomeBusinessScreen> {
  int _selectedIndex = 0;
  NavigationHelper navigationHelper = NavigationHelper();
  @override
  void initState() {
    super.initState();
    print("HomeScreen loaded");
  }

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
        BusinessScreen(),
        SizedBox(), // Scan không phải tab
        // SearchScreen(),
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        // BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
      // scanIndex: 1,
      // onScanTap: () {
      //   navigationHelper.push(context, ScanScreen(isUpdate: true));
      // },
    );
  }
}
