import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductItem.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';

class ProductHome extends StatefulWidget {
  const ProductHome({super.key});

  @override
  State<ProductHome> createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  List<Product> _warehouses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await InfoService.LoadProduct();
      setState(() {
        _warehouses = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _warehouses = [];
        _isLoading = false;
      });
      print("Lỗi tải dữ liệu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách sản phẩm"),
        backgroundColor: Colors.blue,
      ),
      drawer: CustomDrawer(onWarehouseSelected: _loadData),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await để lấy kết quả trả về từ màn hình thêm sản phẩm
          final result = await NavigationHelper.push(
            context,
            WarehouseDetailScreen(item: WareHouse.empty(), isCreate: true),
          );

          // nếu thêm thành công, reload danh sách
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _warehouses.isEmpty
          ? const Center(child: Text("Không có dữ liệu sản phẩm."))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _warehouses.length,
                itemBuilder: (context, index) {
                  final item = _warehouses[index];
                  return ProductItem(item: item);
                },
              ),
            ),
    );
  }
}
