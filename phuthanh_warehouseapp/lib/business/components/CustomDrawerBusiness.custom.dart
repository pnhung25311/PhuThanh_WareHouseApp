import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/screen/auth/UserProfile.screen.dart';
import 'package:phuthanh_warehouseapp/business/HomeBusiness.dart';
// import 'package:phuthanh_warehouseapp/business/cart/CartScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/history/HistoryBusinessScreenALL.screen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/HomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class CustomDrawerBusiness extends StatefulWidget {
  final VoidCallback? onWarehouseSelected;

  const CustomDrawerBusiness({super.key, this.onWarehouseSelected});

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

  void _changeSystem() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chọn hệ thống"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// HỆ THỐNG KHO
              ListTile(
                leading: const Icon(Icons.warehouse, color: Colors.blue),
                title: const Text("Hệ thống kho"),
                onTap: () {
                  navigationHelper.pop(context);

                  navigationHelper.pushAndRemoveUntil(
                    context,
                    const HomeScreen(),
                  );
                },
              ),

              /// HỆ THỐNG KINH DOANH
              ListTile(
                leading: const Icon(Icons.point_of_sale, color: Colors.green),
                title: const Text("Hệ thống kinh doanh"),
                onTap: () {
                  navigationHelper.pop(context);
                  navigationHelper.pushAndRemoveUntil(
                    context,
                    const HomeBusinessScreen(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          /// HEADER
          FutureBuilder<Map<String, dynamic>?>(
            future: mySharedPreferences.getDataObject('account'),
            builder: (context, snapshot) {
              String fullname = "User";
              // String avatarUrl = '';
              Account? account;

              if (snapshot.hasData && snapshot.data != null) {
                account = Account.fromJson(snapshot.data!);
                fullname = account.FullName;
                // avatarUrl = account.Avatar;
              }
              final NameSys = AppState.instance.get("selectedSystemName");

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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (account != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        UserProfileScreen(account: account!),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  (account?.Avatar.isNotEmpty ?? false)
                                  ? NetworkImage(account!.Avatar)
                                  : null,
                              child: (account?.Avatar.isEmpty ?? true)
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                      size: 35,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),

                          Text(
                            NameSys.toString() + '!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Text(
                        'Xin chào, $fullname!',
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
                ListTile(
                  leading: const Icon(
                    Icons.list_alt_outlined,
                    color: Colors.blue,
                  ),
                  title: const Text('Danh sách sản phẩm'),
                  onTap: () {
                    navigationHelper.push(context, HomeBusinessScreen());
                  },
                ),

                /// LỊCH SỬ BÁN
                ListTile(
                  leading: const Icon(Icons.point_of_sale, color: Colors.blue),
                  title: const Text('Lịch sử bán hàng'),
                  onTap: () {
                    navigationHelper.push(
                      context,
                      HistoryBusinessScreenALL(isExIm: true),
                    );
                  },
                ),

                /// LỊCH SỬ NHẬP
                ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.green),
                  title: const Text('Lịch sử nhập hàng'),
                  onTap: () {
                    navigationHelper.push(
                      context,
                      HistoryBusinessScreenALL(isExIm: false),
                    );
                  },
                ),

                /// GIỎ HÀNG
                // ListTile(
                //   leading: const Icon(Icons.shopping_cart, color: Colors.green),
                //   title: const Text('Giỏ hàng'),
                //   onTap: () {
                //     navigationHelper.push(context, CartListScreen(isBusiness: true,));
                //   },
                // ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.change_circle, color: Colors.green),
            title: const Text(
              'Đổi hệ thống',
              style: TextStyle(color: Colors.green),
            ),
            onTap: _changeSystem,
          ),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: _onLogout,
          ),
        ],
      ),
    );
  }
}
