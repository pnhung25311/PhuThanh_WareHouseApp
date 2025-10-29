import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/ScanBarcodeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDrawer.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/WarehouseItem.custom.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<WareHouse> _allWarehouses = [];
  List<WareHouse> _filteredWarehouses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Khi nhập text, lọc realtime
    searchController.addListener(() {
      final query = searchController.text.toLowerCase();
      setState(() {
        _filteredWarehouses = _allWarehouses.where((item) {
          final name = item.nameProduct.toLowerCase();
          final bill = item.idBill.toLowerCase();
          final prdID = item.productID.toLowerCase();
          return name.contains(query) ||
              bill.contains(query) ||
              prdID.contains(query);
        }).toList();
      });
    });
  }

  Future<void> _loadData() async {
    final table = await MySharedPreferences.getDataString("statusWH");
    final safeTable = table ?? "WareHouseA";
    final data = await Warehouseservice.LoadDtata(safeTable);

    setState(() {
      _allWarehouses = data;
      _filteredWarehouses = data;
      _isLoading = false;
    });
  }

  void _onItemTapped() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanScreen(isUpdate: false)),
    );

    if (result != null && result is String) {
      setState(() {
        searchController.text = result;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
          ), // 👈 khoảng cách 8px bên dưới
          child: CustomTextFieldIcon(
            label: "",
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
          ),
        ),
      ),

      drawer: CustomDrawer(onWarehouseSelected: _loadData),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredWarehouses.isEmpty
          ? const Center(child: Text("Không tìm thấy sản phẩm."))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ListView.builder(
                  itemCount: _filteredWarehouses.length,
                  itemBuilder: (context, index) {
                    final item = _filteredWarehouses[index];
                    return WarehouseItem(
                      item: item,
                      onLongPress: () {
                        WarehouseLongClick.show(context, item);
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }
}
