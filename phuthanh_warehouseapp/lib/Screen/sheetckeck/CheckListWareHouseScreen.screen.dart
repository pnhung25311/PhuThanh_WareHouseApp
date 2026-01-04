import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/sheetckeck/DialogSheet.dialog.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomSheetItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Sheet.model.dart';
import 'package:phuthanh_warehouseapp/service/SheetService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class CheckListWareHouseScreen extends StatefulWidget {
  final VoidCallback? onItemTap;

  const CheckListWareHouseScreen({super.key, this.onItemTap});

  @override
  State<CheckListWareHouseScreen> createState() =>
      _CheckListWareHouseScreenState();
}

class _CheckListWareHouseScreenState extends State<CheckListWareHouseScreen> {
  final TextEditingController searchController = TextEditingController();

  bool isSearching = false;
  bool isSelectionMode = false;
  bool _isLoading = true;

  List<Sheet> _sheetList = [];
  List<Sheet> _filteredSheets = [];
  Set<int> selectedIndexes = {};
  int? selectedIndex;
  SheetService sheetService = SheetService();
  Formatdatehelper formatdatehelper = Formatdatehelper();
    NavigationHelper navigationHelper = NavigationHelper();


  final DrawerItem drawerItem = AppState.instance.get("itemDrawer");

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    await _loadData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadData() async {
    final DrawerItem item = AppState.instance.get("itemDrawer");
    final data = await sheetService.LoadDtataSheet(
      item.wareHouseSheetDataBase.toString(),
    );

    setState(() {
      _sheetList = data;
      _filteredSheets = data;
      selectedIndexes.clear();
      selectedIndex = null;
      isSelectionMode = false;
    });
  }

  List<Sheet> _getSelectedSheets() {
    final items = isSearching ? _filteredSheets : _sheetList;
    return selectedIndexes.map((i) => items[i]).toList();
  }

  /// Toggle chọn nhiều item (selection mode)
  void _toggleSelect(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
        if (selectedIndexes.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedIndexes.add(index);
        isSelectionMode = true;
      }
    });
  }

  Widget _buildSheetList() {
    final items = isSearching ? _filteredSheets : _sheetList;

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) return const Center(child: Text("Không có dữ liệu"));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final sheet = items[index];

        /// Item được chọn qua tap 1 item
        final isTappedSelected = selectedIndex == index;

        /// Item được chọn qua selection mode
        final isMultiSelected = selectedIndexes.contains(index);

        return CustomSheetItem(
          item: sheet,
          showCheckbox: isSelectionMode,
          isSelected: isMultiSelected,
          onTap: () {
            if (isSelectionMode) {
              _toggleSelect(index);
            } else {
              setState(() {
                selectedIndex = isTappedSelected ? null : index;
              });

              // 🔥 SET DATA TRƯỚC
              AppState.instance.set("SheetAID", sheet.sheetAID);
              AppState.instance.set("SheetID", sheet.sheetID);
              AppState.instance.set("Sheet", sheet);

              // 🔥 SAU ĐÓ MỚI CHUYỂN TAB
              widget.onItemTap?.call();
            }
          },
          onLongPress: () => _toggleSelect(index),
          onChecked: (_) => _toggleSelect(index),
        );
      },
    );
  }

  void _startSearch() => setState(() => isSearching = true);

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      _filteredSheets = _sheetList;
    });
  }

  void _onSearchChanged(String value) {
    final keyword = value.toLowerCase().trim();

    setState(() {
      _filteredSheets = _sheetList.where((e) {
        final sheetId = e.sheetID.toLowerCase();
        final sheetLastUser = e.lastUser??"".toLowerCase();
        final remark = (e.remark ?? "").toLowerCase();

        final dateText = e.lastTime != null
            ? formatdatehelper.formatDMY(e.lastTime!).toLowerCase()
            : "";

        return sheetId.contains(keyword) ||
            remark.contains(keyword) ||
            sheetLastUser.contains(keyword) ||
            dateText.contains(keyword);
      }).toList();
    });
  }

  Future<void> _updateSelectedSheets() async {
    final selectedSheets = _getSelectedSheets();

    // Lấy ra danh sách sheetAID
    final List<int> sheetAIDs = selectedSheets
        .map((sheet) => sheet.sheetAID)
        .whereType<int>() // tránh null
        .toList();
    print(sheetAIDs);

    // Data cần update
    final Map<String, dynamic> data = {"status": 1};
    // Body JSON hoàn chỉnh
    final Map<String, dynamic> body = {"ids": sheetAIDs, "data": data};
    final jsonSheetAIDs = jsonEncode(body);

    await sheetService.UpdateSheet(
      drawerItem.wareHouseSheetDataBase.toString(),
      jsonSheetAIDs,
    );

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: isSearching
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
                  onSuffixIconPressed: () {},
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
            : Text("Kiểm ${drawerItem.nameWareHouse}"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: isSearching ? _stopSearch : _startSearch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(isSelectionMode ? Icons.check : Icons.add),
        onPressed: isSelectionMode
            ? _updateSelectedSheets
            : () async {
                final result = await navigationHelper.push(
                  context,
                  DialogSheet(),
                );

                if (result == true) {
                  await _loadData();
                }
              },
      ),
      body: RefreshIndicator(onRefresh: _loadData, child: _buildSheetList()),
    );
  }
}
