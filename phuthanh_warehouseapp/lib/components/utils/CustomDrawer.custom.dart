import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDialogDisplaySettings.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback? onWarehouseSelected; // callback reload
  const CustomDrawer({super.key, this.onWarehouseSelected});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadSelectedWarehouse();
  }

  Future<void> _loadSelectedWarehouse() async {
    String? wh = AppState.instance.get("StatusHome") ?? "Product";
    setState(() {
      _selectedWarehouse = wh;
    });
  }

  String convertWarehouseName(String name) {
    // Chuyển WareHouse1 → Kho 1
    return name.replaceFirst('DataWareHouse', 'Kho ');
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => NavigationHelper.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await MySharedPreferences.clearAll();
      NavigationHelper.pop(context); // đóng drawer
      NavigationHelper.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header người dùng
          FutureBuilder<String?>(
            future: MySharedPreferences.getDataString('username'),
            builder: (context, snapshot) {
              String username = snapshot.data ?? 'User';
              return DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, color: Colors.blue, size: 35),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Xin chào, $username!',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),

          // Sản phẩm
          // Sản phẩm
          ListTile(
            leading: Icon(
              Icons.inventory,
              color: _selectedWarehouse == "Product"
                  ? Colors.blue
                  : Colors.grey,
            ),
            title: Text(
              'Danh sách sản phẩm',
              style: TextStyle(
                color: _selectedWarehouse == "Product"
                    ? Colors.blue
                    : Colors.black87,
                fontWeight: _selectedWarehouse == "Product"
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            tileColor: _selectedWarehouse == "Product"
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              AppState.instance.set("StatusHome", "Product");
              setState(() {
                _selectedWarehouse = "Product";
              });
              widget.onWarehouseSelected?.call();
            },
            onLongPress: () {
              Navigator.pop(context, true);
              showDialog(
                context: context,
                builder: (context) => const DisplaySettingsDialog(),
              );
              widget.onWarehouseSelected?.call();
              
            },
          ),

          const Divider(),

          // 🔹 Danh sách kho gọi API
          FutureBuilder<List<String>>(
            future: Warehouseservice.getItemhWareHouse(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Không có dữ liệu kho.'),
                );
              }

              final warehouses = snapshot.data!;
              final converted = warehouses
                  .map((e) => convertWarehouseName(e))
                  .toList();

              return Column(
                children: List.generate(warehouses.length, (index) {
                  final original = warehouses[index];
                  final display = converted[index];
                  final isSelected = original == _selectedWarehouse;

                  return ListTile(
                    leading: Icon(
                      Icons.warehouse,
                      color: isSelected ? Colors.blue : Colors.black54,
                    ),
                    title: Text(
                      display,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    tileColor: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () async {
                      AppState.instance.set("StatusHome", original);
                      AppState.instance.remove("DataWareHouse");
                      setState(() {
                        _selectedWarehouse = original;
                      });

                      NavigationHelper.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đang ở $display'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.blue,
                        ),
                      );

                      widget.onWarehouseSelected?.call();
                    },
                  );
                }),
              );
            },
          ),

          const Divider(),

          // Đăng xuất
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 236, 112, 103),
            ),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}
