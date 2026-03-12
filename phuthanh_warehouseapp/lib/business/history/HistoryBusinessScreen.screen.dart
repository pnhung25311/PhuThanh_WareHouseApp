import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomBusinessLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomHistoryBusinessItem.custom.dart';
import 'package:phuthanh_warehouseapp/business/service/BusinessService.service.dart';
import 'package:phuthanh_warehouseapp/model/business/History.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Business.model.dart';
// import 'package:phuthanh_warehouseapp/warehouse/Screen/WareHouse/ScanBarcodeScreen.screen.dart'; // import màn scan

class HistoryBusinessScreen extends StatefulWidget {
  final Business item;
  final isExIm;
  const HistoryBusinessScreen({super.key, required this.item, this.isExIm});

  @override
  State<HistoryBusinessScreen> createState() => _HistoryBusinessScreenState();
}

class _HistoryBusinessScreenState extends State<HistoryBusinessScreen> {
  List<HistoryBusiness> _allProducts = [];
  List<HistoryBusiness> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  BusinessLongClick businessLongClick = BusinessLongClick();
  Businessservice businessservice = Businessservice();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // _loadProducts();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data;
      if (widget.isExIm) {
        data = await businessservice.getHistoryExport(
          widget.item.barcode.toString().trim(),
        );
      } else {
        data = await businessservice.getHistoryImport(
          widget.item.barcode.toString().trim(),
        );
      }

      setState(() {
        _allProducts = data["body"];
        _filteredProducts = _allProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allProducts = [];
        _isLoading = false;
      });
      print("Lỗi tải dữ liệu: $e");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          return product.maVt.toLowerCase().contains(query) ||
              (product.tenKh?.toLowerCase().contains(query) ?? false) ||
              (product.tenKho?.toLowerCase().contains(query) ?? false) ||
              (product.maKh?.toLowerCase().contains(query) ?? false) ||
              (product.maKho?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  Future<void> _onScanResult() async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => const ScanBarcodeScreen(isUpdate: false)),
    // );

    // if (result != null && result is String && mounted) {
    //   _searchController.text = result;
    //   // _onSearchChanged() tự chạy nhờ listener
    // }
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Đang tải dữ liệu...", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
      return const Center(
        child: Text(
          "Không tìm thấy sản phẩm nào",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return const Center(
      child: Text(
        "Chưa có sản phẩm",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearching
              ? Padding(
                  key: const ValueKey('search'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Tìm Barcode, Tên...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () => _searchController.clear(),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.blue,
                            ),
                            onPressed: _onScanResult,
                            tooltip: 'Quét mã vạch',
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                )
              : Text(
                  'Lịch sử ' +
                      (widget.isExIm == true ? "bán hàng " : "nhập hàng ") +
                      widget.item.barcode.toString().trim(),
                  style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 58, 240, 3)),
                ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadHistory(),
              child: _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final history = _filteredProducts[index];
                        return HistoryBusinessItem(
                          item: history,
                          // onLongPress: () => {
                          //   businessLongClick.show(context, product),
                          // },
                        );
                      },
                    ),
            ),
    );
  }
}
