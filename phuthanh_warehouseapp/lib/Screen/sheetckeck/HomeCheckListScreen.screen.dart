import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/datacheck/HomeDataCheckScreen.screen.dart';
// import 'package:phuthanh_warehouseapp/Screen/datacheck/ScanBarcodeCheckDataScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/sheetckeck/CheckListWareHouseScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/sheetckeck/ScanDataCheckScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomBottomNavigatorSheetCheck.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';

class HomeCheckListScreen extends StatefulWidget {
  final int initialTab;
  const HomeCheckListScreen({super.key, this.initialTab = 0});

  @override
  State<HomeCheckListScreen> createState() => _HomeCheckListScreenState();
}

class _HomeCheckListScreenState extends State<HomeCheckListScreen> {
  int _selectedIndex = 0;
  int _detailsReloadToken = 0;
  NavigationHelper navigationHelper = NavigationHelper();

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToDetails() {
    setState(() {
      _detailsReloadToken++;
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavigatorSheetCheck(
      currentIndex: _selectedIndex,
      onTabChanged: _onTabChanged,
      screens: [
        CheckListWareHouseScreen(onItemTap: _goToDetails),
        SizedBox(), // Scan không phải tab
        DataCheckProductScreen(key: ValueKey(_detailsReloadToken)),
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Sheet'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.find_in_page),
          label: 'Details',
        ),
      ],
      // initialIndex: widget.initialTab,
      scanIndex: 1,
      onScanTap: () async {
        final result = await navigationHelper.push(
          context,
          const ScanDataCheckScreen(),
        );

        if (result == true) {
          setState(() {
            _detailsReloadToken++; // 🔥 reload Details
            _selectedIndex = 2; // 🔥 switch sang tab Details
          });
        }
      },
    );
  }
}
