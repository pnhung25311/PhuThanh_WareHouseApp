import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/ScanBarcodeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseLongClick.custom.dart';
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

  String _statusHome = "Product";

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
      debugPrint("Lỗi khi load dữ liệu: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final table = AppState.instance.get("StatusHome") ?? "Product";

    try {
      if (table == "Product") {
        final cached = AppState.instance.get("ListProduct");
        if (cached != null) {
          _allProducts = cached;
        } else {
          final data = await InfoService.LoadProduct();
          AppState.instance.set("ListProduct", data);
          _allProducts = data;
        }
        _filteredProducts = _allProducts;
      } else {
        final cached = AppState.instance.get("DataWareHouse");
        if (cached != null) {
          _allWarehouses = cached;
        } else {
          final data = await Warehouseservice.LoadDtata("vw$table");
          AppState.instance.set("DataWareHouse", data);
          _allWarehouses = data;
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

    if (_statusHome == "Product") {
      _filteredProducts = _allProducts.where((item) {
        return (item.nameProduct).toLowerCase().contains(keyword) ||
            (item.productID).toLowerCase().contains(keyword) ||
            (item.idPartNo).toLowerCase().contains(keyword);
      }).toList();
    } else {
      _filteredWarehouses = _allWarehouses.where((item) {
        return (item.productID ?? "").toLowerCase().contains(keyword) ||
            (item.nameProduct ?? "").toLowerCase().contains(keyword);
      }).toList();
    }

    setState(() {});
  }

  /// ✅ Khi đổi kho / tab từ Drawer
  void _onDrawerReload() async {
    searchController.clear();

    setState(() {
      _statusHome = AppState.instance.get("StatusHome") ?? "Product";
    });

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
    if (searchController.text.isNotEmpty) {
      return const Center(child: Text("Không tìm thấy kết quả."));
    }
    return _statusHome == "Product"
        ? const Center(child: Text("Không có sản phẩm."))
        : const Center(child: Text("Không có dữ liệu kho hàng."));
  }

  Widget _buildProductList() {
    final items = _filteredProducts;

    if (!_isLoading && items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        searchController.clear();
        await _loadData();
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ProductItem(
          item: items[index],
          onTap: () {},
          onLongPress: () => ProductLongClick.show(context, items[index]),
        ),
      ),
    );
  }

  Widget _buildWarehouseList() {
    final items = _filteredWarehouses;

    if (!_isLoading && items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        searchController.clear();
        await _loadData();
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => WarehouseItem(
          item: items[index],
          onLongPress: () => WarehouseLongClick.show(context, items[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
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
        ),
      ),
      drawer: CustomDrawer(onWarehouseSelected: _onDrawerReload),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _statusHome == "Product"
            ? _buildProductList()
            : _buildWarehouseList(),
      ),
      // Stack(
      //   children: [
      //     _statusHome == "Product"
      //         ? _buildProductList()
      //         : _buildWarehouseList(),
      //     if (_isLoading)
      //       Positioned.fill(
      //         child: Container(
      //           color: Colors.black.withOpacity(0.25),
      //           child: const Center(child: CircularProgressIndicator()),
      //         ),
      //       ),
      //   ],
      // ),
    );
  }
}
