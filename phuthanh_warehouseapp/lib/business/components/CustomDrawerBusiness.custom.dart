import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/history/HistoryBusinessScreenALL.screen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';

class CustomDrawerBusiness extends StatefulWidget {
  final VoidCallback? onWarehouseSelected;

  const CustomDrawerBusiness({
    super.key,
    this.onWarehouseSelected,
  });

  @override
  State<CustomDrawerBusiness> createState() => _CustomDrawerBusinessState();
}

class _CustomDrawerBusinessState extends State<CustomDrawerBusiness> {

  NavigationHelper navigationHelper = NavigationHelper();
  MySharedPreferences mySharedPreferences = MySharedPreferences();

  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await mySharedPreferences.clearAll();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Loginscreen()),
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          /// HEADER
          FutureBuilder<String?>(
            future: mySharedPreferences.getDataString('username'),
            builder: (context, snapshot) {
              final username = snapshot.data ?? 'User';

              return DrawerHeader(
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(Icons.person, color: Colors.blue, size: 35),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Xin chào, $username!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// ===== MENU =====
          Expanded(
            child: ListView(
              children: [

                /// LỊCH SỬ BÁN
                ListTile(
                  leading: const Icon(Icons.point_of_sale, color: Colors.blue),
                  title: const Text('Lịch sử bán hàng'),
                  onTap: () {
                    navigationHelper.push(context, HistoryBusinessScreenALL(isExIm: true,));
                  },
                ),

                /// LỊCH SỬ NHẬP
                ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.green),
                  title: const Text('Lịch sử nhập hàng'),
                  onTap: () {
                    navigationHelper.push(context, HistoryBusinessScreenALL(isExIm: false,));
                  },
                ),

                const Divider(),

                /// LOGOUT
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}