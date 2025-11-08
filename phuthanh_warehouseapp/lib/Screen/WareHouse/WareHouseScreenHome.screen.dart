import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class WareHouseScreen extends StatefulWidget {
  const WareHouseScreen({super.key});

  @override
  State<WareHouseScreen> createState() => _WareHouseScreenState();
}

class _WareHouseScreenState extends State<WareHouseScreen> {
  List<WareHouse> _warehouses = [];
  List<Product> _products = [];
  String _statusHome = "Product";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      _statusHome = AppState.instance.get("StatusHome") ?? "Product";
      await _loadData();
    } catch (e) {
      print("Lỗi khi load dữ liệu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final table = AppState.instance.get("StatusHome") ?? "Product";
    try {
      if (table == "Product") {
        AppState.instance.set("ListProductLimit", null);
        final products = AppState.instance.get("ListProductLimit");
        if (products != null) {
          _products = products;
        } else {
          final data = await Warehouseservice.LoadDtataLimitProduct(
            table,
            "200",
          );
          AppState.instance.set("ListProductLimit", data);
          _products = data;
        }
      } else {
        AppState.instance.set("DataWareHouseLimit", null);
        final dataWareHouse = AppState.instance.get("DataWareHouseLimit");
        if (dataWareHouse != null) {
          _warehouses = dataWareHouse;
        } else {
          final data = await Warehouseservice.LoadDtataLimit("vw$table", "200");
          AppState.instance.set("DataWareHouseLimit", data);
          _warehouses = data;
        }
      }
    } catch (e) {
      print("Lỗi load: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ Reload khi click Drawer
  void _onDrawerReload() async {
    setState(() {
      _statusHome = AppState.instance.get("StatusHome") ?? "Product";
    });
    await _loadData();
  }

  /// ✅ Widget loading
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            "Đang tải dữ liệu...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// ✅ List sản phẩm
  Widget _buildProductList() {
    if (_isLoading) return _buildLoading();
    if (_products.isEmpty) {
      return const Center(child: Text("Không có sản phẩm."));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _products.length,
        itemBuilder: (context, index) => ProductItem(
          item: _products[index],
          onTap: () {},
          onLongPress: () {
            ProductLongClick.show(context, _products[index]);
          },
        ),
      ),
    );
  }

  /// ✅ List kho
  Widget _buildWarehouseList() {
    if (_isLoading) return _buildLoading();
    if (_warehouses.isEmpty) {
      return const Center(child: Text("Không có dữ liệu kho hàng."));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _warehouses.length,
        itemBuilder: (context, index) => WarehouseItem(
          item: _warehouses[index],
          onLongPress: () {
            WarehouseLongClick.show(context, _warehouses[index]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _statusHome == "Product"
              ? "Danh sách sản phẩm"
              : "Danh sách kho hàng ${_statusHome.replaceFirst('DataWareHouse', '')}",
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: CustomDrawer(onWarehouseSelected: _onDrawerReload),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _statusHome == "Product"
            ? _buildProductList()
            : _buildWarehouseList(),
      ),
      floatingActionButton: _statusHome == "Product"
          ? FloatingActionButton(
              onPressed: () async {
                await NavigationHelper.push(
                  context,
                  ProductDetailScreen(item: Product.empty(), isCreate: true),
                );
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
