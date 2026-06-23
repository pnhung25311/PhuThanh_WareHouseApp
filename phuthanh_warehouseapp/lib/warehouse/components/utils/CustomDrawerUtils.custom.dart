import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/UserProfile.screen.dart';
import 'package:phuthanh_warehouseapp/business/HomeBusiness.dart';
import 'package:phuthanh_warehouseapp/business/history/HistoryBusinessScreenALL.screen.dart';
import 'package:phuthanh_warehouseapp/file/screen/TreeviewPage.screen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/HomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class CustomDrawerUtils extends StatefulWidget {
  final VoidCallback? onWarehouseSelected;

  const CustomDrawerUtils({super.key, this.onWarehouseSelected});

  @override
  State<CustomDrawerUtils> createState() => _CustomDrawerUtilsState();
}

class _CustomDrawerUtilsState extends State<CustomDrawerUtils> {
  // Kho lưu trữ danh sách kho (Dành cho Hệ thống kho)
  List<DrawerItem> _warehouseItems = [];
  int? _selectedWarehouseId;
  bool _loadingWarehouse = false;
  String? _warehouseError;

  // Các Helper dùng chung
  final Warehouseservice _warehouseService = Warehouseservice();
  final NavigationHelper _navigationHelper = NavigationHelper();
  final MySharedPreferences _mySharedPreferences = MySharedPreferences();

  // Định danh hệ thống hiện tại lấy từ AppState để render giao diện phù hợp
  String _currentSystem = "";

  @override
  void initState() {
    super.initState();
    _detectCurrentSystem();
  }

  /// Kiểm tra xem app đang đứng ở hệ thống nào dựa vào cấu hình trong AppState
  void _detectCurrentSystem() {
    final nameSys = AppState.instance.get("selectedSystem")?.toString() ?? "";
    setState(() {
      _currentSystem = nameSys.toLowerCase();
    });

    // Nếu đang ở hệ thống kho thì mới bắt đầu call API lấy danh sách kho hàng
    if (_currentSystem.contains("system1")) {
      _fetchWarehouses();
    }
  }

  /// Lấy danh sách kho hàng từ service
  Future<void> _fetchWarehouses() async {
    setState(() {
      _loadingWarehouse = true;
      _warehouseError = null;
    });

    try {
      final list = await _warehouseService.getItemhWareHouse();
      AppState.instance.set("listItemDrawer", list);

      setState(() {
        _warehouseItems = list;

        if (list.isNotEmpty) {
          final savedItem = AppState.instance.get("itemDrawer");
          if (savedItem != null) {
            _selectedWarehouseId = savedItem.wareHouseID;
          } else {
            _selectedWarehouseId = list.first.wareHouseID;
            AppState.instance.set("itemDrawer", list.first);
          }
        }
        _loadingWarehouse = false;
      });
    } catch (e) {
      setState(() {
        _warehouseError = e.toString();
        _loadingWarehouse = false;
      });
    }
  }

  /// Xử lý khi chọn kho hàng
  void _onTapWarehouse(DrawerItem item) {
    setState(() {
      _selectedWarehouseId = item.wareHouseID;
    });

    AppState.instance.set("itemDrawer", item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang ở ${item.nameWareHouse}'),
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onWarehouseSelected?.call();
    _navigationHelper.pop(context);
  }

  /// Hộp thoại đăng xuất công nghệ cao
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
              await _mySharedPreferences.clearAll();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Loginscreen()),
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  /// Hộp thoại đổi nhanh giữa 3 hệ thống (Kho, Kinh doanh, Tệp tin)
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
                  AppState.instance.set("selectedSystem", "system1");
                  _navigationHelper.pop(context);
                  _navigationHelper.pushAndRemoveUntil(context, const HomeScreen());
                },
              ),

              /// HỆ THỐNG KINH DOANH
              ListTile(
                leading: const Icon(Icons.point_of_sale, color: Colors.green),
                title: const Text("Hệ thống kinh doanh"),
                onTap: () {
                  AppState.instance.set("selectedSystem", "system2");
                  _navigationHelper.pop(context);
                  _navigationHelper.pushAndRemoveUntil(context, const HomeBusinessScreen());
                },
              ),

              /// QUẢN LÝ TỆP TIN
              ListTile(
                leading: const Icon(Icons.insert_drive_file, color: Colors.orange),
                title: const Text("Quản lý tệp tin"),
                onTap: () {
                  AppState.instance.set("selectedSystem", "system3");
                  _navigationHelper.pop(context);
                  _navigationHelper.pushAndRemoveUntil(context, const TreeViewPage());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Hàm xây dựng phần nội dung Menu động dựa vào hệ thống hiện tại
  Widget _buildDynamicMenu() {
    // TH1: HỆ THỐNG KHO (Hiển thị danh sách các kho hàng)
    if (_currentSystem.contains("system1")) {
      if (_loadingWarehouse) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_warehouseError != null) {
        return Center(child: Text('Lỗi: $_warehouseError'));
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _warehouseItems.length,
        itemBuilder: (context, index) {
          final item = _warehouseItems[index];
          final isSelected = item.wareHouseID == _selectedWarehouseId;

          return ListTile(
            leading: Icon(
              Icons.warehouse,
              color: isSelected ? Colors.blue : Colors.black54,
            ),
            title: Text(
              item.nameWareHouse ?? '',
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
            tileColor: isSelected ? Colors.blue.withOpacity(0.12) : null,
            onTap: () => _onTapWarehouse(item),
          );
        },
      );
    }

    // TH2: HỆ THỐNG KINH DOANH
    if (_currentSystem.contains("system2")) {
      return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt_outlined, color: Colors.blue),
            title: const Text('Danh sách sản phẩm'),
            onTap: () {
              _navigationHelper.push(context, HomeBusinessScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale, color: Colors.blue),
            title: const Text('Lịch sử bán hàng'),
            onTap: () {
              _navigationHelper.push(context, HistoryBusinessScreenALL(isExIm: true));
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Colors.green),
            title: const Text('Lịch sử nhập hàng'),
            onTap: () {
              _navigationHelper.push(context, HistoryBusinessScreenALL(isExIm: false));
            },
          ),
        ],
      );
    }

    // TH3: HỆ THỐNG QUẢN LÝ TỆP TIN
    // if (_currentSystem.contains("system3")) {
    //   return ListView(
    //     shrinkWrap: true,
    //     physics: const NeverScrollableScrollPhysics(),
    //     children: [
    //       ListTile(
    //         leading: const Icon(Icons.folder_shared, color: Colors.orange),
    //         title: const Text('Cấu trúc thư mục'),
    //         onTap: () {
    //           _navigationHelper.push(context, const TreeViewPage());
    //         },
    //       ),
    //     ],
    //   );
    // }

    // Mặc định hoặc hệ thống chưa xác định
    return const Center(child: Text('Không tìm thấy chức năng hệ thống'));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          /// ===== HEADER (Dùng chung cho cả 3 hệ thống) =====
          FutureBuilder<Map<String, dynamic>?>(
            future: _mySharedPreferences.getDataObject('account'),
            builder: (context, snapshot) {
              String fullname = "User";
              Account? account;

              if (snapshot.hasData && snapshot.data != null) {
                account = Account.fromJson(snapshot.data!);
                fullname = account.FullName;
              }
              final nameSys = AppState.instance.get("selectedSystemName");

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
                                    builder: (_) => UserProfileScreen(account: account!),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: (account?.Avatar.isNotEmpty ?? false)
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
                          Expanded(
                            child: Text(
                              '${nameSys ?? "Hệ thống"}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// ===== DYNAMIC MENU CONTENT =====
          Expanded(
            child: SingleChildScrollView(
              child: _buildDynamicMenu(),
            ),
          ),

          const Divider(),

          /// ===== BOTTOM FIXED MENUS =====
          ListTile(
            leading: const Icon(Icons.change_circle, color: Colors.green),
            title: const Text(
              'Đổi hệ thống',
              style: TextStyle(color: Colors.green),
            ),
            onTap: _changeSystem,
          ),
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