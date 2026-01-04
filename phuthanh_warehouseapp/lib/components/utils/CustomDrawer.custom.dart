import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawerLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback? onWarehouseSelected;

  const CustomDrawer({super.key, this.onWarehouseSelected});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<DrawerItem> _drawerItems = [];
  int? _selectedWarehouseId;
  bool _loading = true;
  String? _error;
  Warehouseservice warehouseservice = Warehouseservice();
  NavigationHelper navigationHelper = NavigationHelper();
  MySharedPreferences mySharedPreferences = MySharedPreferences();
  DrawerLongClick drawerLongClick = DrawerLongClick();

  @override
  void initState() {
    super.initState();
    _fetchWarehouses();
  }

  Future<void> _fetchWarehouses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await warehouseservice.getItemhWareHouse();

      setState(() {
        _drawerItems = list;

        if (list.isNotEmpty) {
          final savedItem = AppState.instance.get("itemDrawer");

          if (savedItem != null) {
            _selectedWarehouseId = savedItem.wareHouseID;
          } else {
            _selectedWarehouseId = list.first.wareHouseID;
            AppState.instance.set("itemDrawer", list.first);
          }
        }

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

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
    navigationHelper.pop(context);
  }

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
          /// ===== HEADER =====
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

          /// ===== LIST WAREHOUSE =====
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Lỗi: $_error'))
                : ListView.builder(
                    itemCount: _drawerItems.length,
                    itemBuilder: (context, index) {
                      final item = _drawerItems[index];
                      final isSelected =
                          item.wareHouseID == _selectedWarehouseId;

                      return ListTile(
                        leading: Icon(
                          Icons.warehouse,
                          color: isSelected ? Colors.blue : Colors.black54,
                        ),
                        title: Text(
                          item.nameWareHouse ?? '',
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        tileColor: isSelected
                            ? Colors.blue.withOpacity(0.12)
                            : null,
                        onTap: () => _onTapWarehouse(item),
                        onLongPress: isSelected
                            ? () {
                                // Navigator.pop(context, true);
                                drawerLongClick.show(
                                  context,
                                  "showhideWareHouse",
                                );
                                // widget.onWarehouseSelected?.call();
                              }
                            : null, // nếu không chọn thì không cho long press,
                      );
                    },
                  ),
          ),

          const Divider(),

          /// ===== LOGOUT =====
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
