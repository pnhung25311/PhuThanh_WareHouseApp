import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/WarehouseItem.custom.dart'; // ✅ import mới
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';

class WareHouseScreen extends StatefulWidget {
  const WareHouseScreen({super.key});

  @override
  State<WareHouseScreen> createState() => _WareHouseScreenState();
}

class _WareHouseScreenState extends State<WareHouseScreen> {
  late Future<List<WareHouse>> _futureWarehouses;

  @override
  void initState() {
    super.initState();
    _futureWarehouses = Future.value([]);
    _loadData();
  }

  

  Future<void> _loadData() async {
    final table = await MySharedPreferences.getDataString("statusWH");
    final safeTable = table ?? "WareHouseA";
    setState(() {
      _futureWarehouses = Warehouseservice.LoadDtataLimit(safeTable, "200");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách kho hàng"),
        backgroundColor: Colors.blue,
      ),
      drawer: CustomDrawer(onWarehouseSelected: _loadData),

      // ✅ Thêm nút thêm mới ở góc phải dưới
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WarehouseDetailScreen(
                isCreate: true,
                item: WareHouse.empty(), // 🔹 item rỗng
                 // 🔹 chế độ thêm mới
              ),
            ),
          );
          if (result == true) {
            _loadData(); // ✅ Refresh lại danh sách
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: FutureBuilder<List<WareHouse>>(
        future: _futureWarehouses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Lỗi tải dữ liệu: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có dữ liệu kho hàng."));
          }

          final warehouses = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final item = warehouses[index];
                return WarehouseItem(
                  item: item,
                  isUpDate: false,
                  onLongPress: () {
                    WarehouseLongClick.show(context, item);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
