import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/cart/CartScreen.screen.dart';
// import 'package:phuthanh_warehouseapp/core/config/notification_manager.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/WareHouse/ScanBarcodeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/WareHouse/WareHouseSearchScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/WareHouse/WareHouseScreenHome.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/guarantee/GuaranteeHomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomBottomNavigator.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  NavigationHelper navigationHelper = NavigationHelper();
  // final NotificationManager _notificationManager = NotificationManager();
  @override
  void initState() {
    super.initState();
    print("HomeScreen loaded");
    // _notificationManager.init(context);
  }

  @override
  void dispose() {
    // _notificationManager.dispose();
    super.dispose();
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
        WareHouseScreen(),
        SearchScreen(),
        SizedBox(), // Scan không phải tab
        GuaranteetHome(),
        CartListScreen(isBusiness: false),
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Bảo hành'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Giỏ hàng',
        ),
      ],
      scanIndex: 2,
      onScanTap: () {
        navigationHelper.push(context, ScanScreen(isUpdate: true));
      },
    );
  }
}
