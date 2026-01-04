import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDataCheckItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/model/info/DataCheck.model.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/service/SheetService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class DataCheckProductScreen extends StatefulWidget {
  const DataCheckProductScreen({super.key});

  @override
  State<DataCheckProductScreen> createState() => _DataCheckProductScreenState();
}

class _DataCheckProductScreenState extends State<DataCheckProductScreen> {
  final TextEditingController searchController = TextEditingController();

  bool isSearching = false;
  bool isSelectionMode = false;
  bool isLoading = true;

  List<DataCheck> _dataList = [];
  List<DataCheck> _filteredList = [];
  Set<int> selectedIndexes = {};

  final DrawerItem drawerItem = AppState.instance.get("itemDrawer");

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => isLoading = true);
    await _loadData();
    setState(() => isLoading = false);
  }

  Future<void> _loadData() async {
    SheetService sv = new SheetService();
    final sheetAID = AppState.instance.get("SheetAID");
    final data = await sv.LoadDtataCheck(
      drawerItem.wareHouseDataCheck.toString(),
      jsonEncode({"SheetAID": sheetAID}),
    );

    setState(() {
      _dataList = data;
      _filteredList = data;
      selectedIndexes.clear();
      isSelectionMode = false;
    });
  }

  void _onLongPress(int index) {
    setState(() {
      isSelectionMode = true;
      selectedIndexes.add(index);
    });
  }

  void _toggleSelect(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
        if (selectedIndexes.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  Widget _buildList() {
    final items = isSearching ? _filteredList : _dataList;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, index) => CustomDataCheckItem(
        item: items[index],
        // showCheckbox: isSelectionMode,
        // isSelected: selectedIndexes.contains(index),
        onLongPress: () => _onLongPress(index),
        onTap: () {
          if (isSelectionMode) {
            _toggleSelect(index);
          }
        },
        // onChecked: (_) => _toggleSelect(index),
      ),
    );
  }

  void _startSearch() => setState(() => isSearching = true);

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      _filteredList = _dataList;
    });
  }

  void _onSearchChanged(String value) {
    final keyword = value.toLowerCase().trim();
    setState(() {
      _filteredList = _dataList.where((e) {
        return e.productID.toString().toLowerCase().contains(keyword) ||
            e.idPartNo.toString().toLowerCase().contains(keyword) ||
            e.nameProduct.toString().toLowerCase().contains(keyword) ||
            e.nameCountry.toString().toLowerCase().contains(keyword) ||
            e.nameCountry.toString().toLowerCase().contains(keyword) ||
            e.nameUnit.toString().toLowerCase().contains(keyword) ||
            (e.remark ?? '').toLowerCase().contains(keyword);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetAID = AppState.instance.get("SheetID");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: isSearching
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 6,
                  bottom: 25,
                ),
                child: CustomTextFieldIcon(
                  label: '',
                  controller: searchController,
                  hintText: "Tìm kiếm...",
                  height: 36,
                  fontSize: 13,
                  borderRadius: 8,
                  backgroundColor: Colors.white,
                  onChanged: _onSearchChanged,
                ),
              )
            : Text(sheetAID!=null ? "Kiểm phiếu ${sheetAID}" : "Không có phiếu"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: isSearching ? _stopSearch : _startSearch,
          ),
        ],
      ),
      // floatingActionButton: isSelectionMode
      //     ? FloatingActionButton(
      //         backgroundColor: Colors.blue,
      //         child: const Icon(Icons.check),
      //         onPressed: _updateSelected,
      //       )
      //     : FloatingActionButton(
      //         backgroundColor: Colors.blue,
      //         child: const Icon(Icons.add),
      //         onPressed: () {},
      //       ),
      body: RefreshIndicator(onRefresh: _loadData, child: _buildList()),
    );
  }
}
