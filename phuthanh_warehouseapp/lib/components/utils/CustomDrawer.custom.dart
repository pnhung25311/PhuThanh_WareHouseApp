import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback? onWarehouseSelected; // 👈 callback reload
  const CustomDrawer({super.key, this.onWarehouseSelected});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _loadSelectedWarehouse();
  }

  Future<void> _loadSelectedWarehouse() async {
    String? wh = await MySharedPreferences.getDataString("statusWH");
    setState(() {
      _selectedWarehouse = wh;
    });
  }

  String convertWarehouseName(String name) {
    return name.replaceFirst('WareHouse', 'Kho ');
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await MySharedPreferences.clearAll();
      Navigator.pop(context); // đóng drawer
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
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

          // Danh sách kho
          FutureBuilder<List<String>>(
            future: Warehouseservice.getItemhWareHouse(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
                      await MySharedPreferences.setDataString(
                        "statusWH",
                        original,
                      );

                      setState(() {
                        _selectedWarehouse = original;
                      });

                      Navigator.pop(context);

                      // 🔹 Hiển thị thông báo
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

          // 🔹 Đăng xuất có dialog xác nhận
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
