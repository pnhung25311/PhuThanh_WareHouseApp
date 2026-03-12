import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomBusinessLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomProductBusiness.custom.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/info/Business.model.dart';
// import 'package:phuthanh_warehouseapp/warehouse/Screen/WareHouse/ScanBarcodeScreen.screen.dart'; // import màn scan

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Business> _allProducts = [];
  List<Business> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  BusinessLongClick businessLongClick = BusinessLongClick();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiClient();
      final response = await api.get('business/get-all');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Business> loaded = jsonData
            .map((e) => Business.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _allProducts = loaded;
          _filteredProducts = loaded;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Lỗi server: ${response.statusCode} - ${response.reasonPhrase ?? 'Unknown'}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể kết nối: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          return product.barcode.toLowerCase().contains(query) ||
              product.danhDiem.toLowerCase().contains(query) ||
              product.boDanhDiemTuongDuong.toLowerCase().contains(query) ||
              product.tenHangHoa.toLowerCase().contains(query);
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
                      hintText: 'Tìm Barcode, Danh điểm, Tên...',
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
              : const Text('Danh sách hàng hóa'),
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
              onRefresh: _loadProducts,
              child: _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          item: product,
                          onLongPress: () => {
                            businessLongClick.show(context, product),
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
