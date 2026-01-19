import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/sheetckeck/HomeCheckListScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
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
  ProductLongClick productLongClick = ProductLongClick();
  // String _statusHome = "Product";
  bool _isLoading = true;
  // DrawerItem? _selectedDrawerItem;
  Warehouseservice warehouseservice = Warehouseservice();
  NavigationHelper navigationHelper = NavigationHelper();
  WarehouseLongClick warehouseLongClick = WarehouseLongClick();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      await _loadData();
    } catch (e) {
      print("Lỗi khi load dữ liệu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final DrawerItem item = AppState.instance.get("itemDrawer");
    String table = item.wareHouseTable.toString();
    print(table);

    try {
      if (item.wareHouseCategory == 0) {
        final data = await warehouseservice.LoadDtataLimitProduct("200");
        if (data["statusCode"] == 403 ||
            data["statusCode"] == 401 ||
            data["statusCode"] == 0) {
          navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
        }
        setState(() {
          _products.clear();
          _products.addAll(data["body"]);
        });
      } else {
        final data = await warehouseservice.LoadDtataLimit(table, "200");
        if (data["statusCode"] == 403 ||
            data["statusCode"] == 401 ||
            data["statusCode"] == 0) {
          navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
        }
        setState(() {
          _warehouses.clear();
          _warehouses.addAll(data["body"]);
        });
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
      // _statusHome = AppState.instance.get("StatusHome") ?? "Product";
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
    final items = _products;
    return RefreshIndicator(
      onRefresh: () async {
        // searchController.clear();
        await _loadData();
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ProductItem(
          item: items[index],
          onLongPress: () => productLongClick.show(context, items[index]),
        ),
      ),
    );
    // return ProductListView(products: _products, onRefresh: _loadData);
  }

  /// ✅ List kho
  Widget _buildWarehouseList(bool role) {
    if (_isLoading) return _buildLoading();
    if (_warehouses.isEmpty) {
      return const Center(child: Text("Không có dữ liệu kho hàng."));
    }
    final items = _warehouses;
    return RefreshIndicator(
      onRefresh: () async {
        // searchController.clear();
        await _loadData();
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => WarehouseItem(
          item: items[index],
          onLongPress: () =>
              warehouseLongClick.show(context, items[index], role),
        ),
      ),
    );

    // return WarehouseListView(warehouses: _warehouses, onRefresh: _loadData);
  }

  @override
  Widget build(BuildContext context) {
    final DrawerItem item = AppState.instance.get("itemDrawer");
    final roles = AppState.instance.get("role");

    return Scaffold(
      appBar: AppBar(
        title: Text(item.nameWareHouse ?? ''),
        backgroundColor: Colors.blue,
        actions: [
          if (item.wareHouseCategory != 0)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                iconSize: 40,
                icon: const Icon(Icons.checklist),
                onPressed: () {
                  navigationHelper.push(
                    context,
                    HomeCheckListScreen(initialTab: 0),
                  );
                },
              ),
            ),
        ],
      ),
      drawer: CustomDrawer(onWarehouseSelected: _onDrawerReload),
      body: item.wareHouseCategory == 0
          ? _buildProductList()
          : _buildWarehouseList(roles),
      floatingActionButton: item.wareHouseCategory == 0
          ? roles == true
                ? FloatingActionButton(
                    onPressed: () async {
                      await navigationHelper.push(
                        context,
                        ProductDetailScreen(
                          item: Product.empty(),
                          isCreate: true,
                        ),
                      );
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.add),
                  )
                : null
          : null,
    );
  }
}
