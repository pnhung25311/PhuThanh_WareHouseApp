import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/ScanBarcodeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = true;

  List<WareHouse> _allWarehouses = [];
  List<Product> _allProducts = [];

  List<WareHouse> _filteredWarehouses = [];
  List<Product> _filteredProducts = [];

  bool isSearching = false;
  ProductLongClick productLongClick = ProductLongClick();
  InfoService infoService = InfoService();
  Warehouseservice warehouseservice = Warehouseservice();
  WarehouseLongClick warehouseLongClick = WarehouseLongClick();
  NavigationHelper navigationHelper = NavigationHelper();

  // String _statusHome = "Product";

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _startSearch() async {
    setState(() => isSearching = true);
  }

  void _stopSearch() async {
    setState(() {
      isSearching = false;
      searchController.clear();

      final item = AppState.instance.get("itemDrawer");
      if (item.wareHouseCategory == 0) {
        _filteredProducts = _allProducts;
      } else {
        _filteredWarehouses = _allWarehouses;
      }
    });
    // await _loadData();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      // _statusHome = AppState.instance.get("StatusHome") ?? "Product";
      await _loadData();
    } catch (e) {
      debugPrint("Lỗi khi load dữ liệu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // final table = AppState.instance.get("StatusHome") ?? "Product";
    // final DrawerItem item = AppState.instance.get("itemDrawer");

    final DrawerItem item = AppState.instance.get("itemDrawer");

    String table = item.wareHouseTable.toString();
    try {
      if (item.wareHouseCategory == 0) {
        AppState.instance.set("ListProduct", null);
        final cached = AppState.instance.get("ListProduct");
        if (cached != null) {
          _allProducts = cached;
        } else {
          final data = await infoService.LoadProduct();
          if (data["statusCode"] == 403 ||
              data["statusCode"] == 401 ||
              data["statusCode"] == 0) {
            navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
          }
          _allProducts = data["body"];
        }
        _filteredProducts = _allProducts;
      } else {
        AppState.instance.set("DataWareHouse", null);
        final cached = AppState.instance.get("DataWareHouse");
        if (cached != null) {
          _allWarehouses = cached;
        } else {
          final data = await warehouseservice.LoadDtata(table);
          // AppState.instance.set("DataWareHouse", data);
          if (data["statusCode"] == 403 ||
              data["statusCode"] == 401 ||
              data["statusCode"] == 0) {
            navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
          }
          _allWarehouses = data["body"];
        }
        _filteredWarehouses = _allWarehouses;
      }
    } catch (e) {
      debugPrint("Lỗi load: $e");
    }

    setState(() => _isLoading = false);
  }

  void _onSearchChanged(String value) {
    final keyword = value.toLowerCase().trim();
    final DrawerItem item = AppState.instance.get("itemDrawer");

    if (item.wareHouseCategory == 0) {
      _filteredProducts = _allProducts.where((item) {
        return (item.nameProduct).toLowerCase().contains(keyword) ||
            (item.productID).toLowerCase().contains(keyword) ||
            (item.idPartNo).toLowerCase().contains(keyword);
      }).toList();
    } else {
      _filteredWarehouses = _allWarehouses.where((item) {
        return (item.productID ?? "").toLowerCase().contains(keyword) ||
            (item.idPartNo ?? "").toLowerCase().contains(keyword) ||
            (item.idReplacedPartNo ?? "").toLowerCase().contains(keyword) ||
            (item.manufacturerName ?? "").toLowerCase().contains(keyword) ||
            (item.countryName ?? "").toLowerCase().contains(keyword) ||
            (item.unitName ?? "").toLowerCase().contains(keyword) ||
            (item.parameter ?? "").toLowerCase().contains(keyword) ||
            (item.nameProduct ?? "").toLowerCase().contains(keyword);
      }).toList();
    }

    setState(() {});
  }

  /// Khi đổi kho / tab từ Drawer
  void _onDrawerReload() async {
    searchController.clear();

    setState(() {});

    await _loadData();
  }

  void _onItemTapped() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen(isUpdate: false)),
    );

    if (result != null && result is String) {
      searchController.text = result;
      _onSearchChanged(result);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState() {
    final DrawerItem item = AppState.instance.get("itemDrawer");

    if (searchController.text.isNotEmpty) {
      return const Center(child: Text("Không tìm thấy kết quả."));
    }
    return item.wareHouseCategory == 0
        ? const Center(child: Text("Không có sản phẩm."))
        : const Center(child: Text("Không có dữ liệu kho hàng."));
  }

  Widget _buildProductList() {
    final items = _filteredProducts;
    if (_isLoading) return _buildLoading();

    if (items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        searchController.clear();
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
  }

  Widget _buildWarehouseList(bool role) {
    final items = _filteredWarehouses;
    if (_isLoading) return _buildLoading();

    if (items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        searchController.clear();
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
  }

  /// ✅ Widget loading overlay
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

  @override
  Widget build(BuildContext context) {
    final DrawerItem item = AppState.instance.get("itemDrawer");
    final roles = AppState.instance.get("role");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSearching
              ? Padding(
                  key: const ValueKey('searchBar'),
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 25,
                  ),

                  child: CustomTextFieldIcon(
                    label: '',
                    controller: searchController,
                    hintText: "Tìm sản phẩm...",
                    suffixIcon: Icons.qr_code_scanner,
                    onSuffixIconPressed: _onItemTapped,
                    height: 36,
                    fontSize: 13,
                    borderRadius: 8,
                    backgroundColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                )
              : Text(item.nameWareHouse.toString()),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: isSearching ? _stopSearch : _startSearch,
          ),
        ],
      ),
      drawer: CustomDrawer(onWarehouseSelected: _onDrawerReload),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: item.wareHouseCategory == 0
            ? _buildProductList()
            : _buildWarehouseList(roles),
      ),
    );
  }
}
