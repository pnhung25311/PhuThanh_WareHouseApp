import 'package:phuthanh_warehouseapp/helper/SearchTextHelper.helper.dart';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/ChangeSystemDialog.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newbusiness/Product.model.dart';
import 'package:phuthanh_warehouseapp/newbusiness/screen/ProductDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newbusiness/service/ProductSyncService.service.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Màn hình chính "Hệ thống kinh doanh mới" — tải file đồng bộ sản phẩm
/// (`GET /api/file/download-product-sync`, có thể vài chục nghìn dòng) và
/// hiển thị dạng danh sách tìm kiếm được, bấm vào xem chi tiết đầy đủ.
/// Dùng `ListView.builder` (lazy) thay vì render hết cùng lúc để tránh treo
/// UI/OOM với danh sách lớn — cùng cách đã áp dụng cho tồn kho ở kho mới.
class ProductSyncScreen extends StatefulWidget {
  const ProductSyncScreen({super.key});

  @override
  State<ProductSyncScreen> createState() => _ProductSyncScreenState();
}

class _ProductSyncScreenState extends State<ProductSyncScreen> {
  final ProductSyncService _service = ProductSyncService();
  final TextEditingController _searchController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  final FunctionConvertHelper _convertHelper = FunctionConvertHelper();

  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _items = [];
  bool? _isInternalNetwork;

  @override
  void initState() {
    super.initState();
    _load();
    _checkNetwork();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkNetwork() async {
    try {
      final result = await _apiClient.isInternalNetwork();
      if (mounted) setState(() => _isInternalNetwork = result);
    } catch (_) {
      if (mounted) setState(() => _isInternalNetwork = false);
    }
  }

  String _resolveImageUrl(String url) => _convertHelper.resolveNetworkUrl(url, _isInternalNetwork == true);

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.downloadAndParse();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result["isSuccess"] == true) {
        _items = result["body"] as List<Product>;
      } else {
        _errorMessage = 'Không tải được dữ liệu sản phẩm (mã lỗi: ${result["statusCode"]})';
      }
    });
  }

  List<Product> get _visibleItems {
    final query = SearchTextHelper.normalize(_searchController.text);
    if (query.isEmpty) return _items;
    return _items.where((p) => p.searchText.contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Hệ thống kinh doanh mới'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: 'Đổi hệ thống',
            icon: const Icon(kChangeSystemIcon, color: kChangeSystemColor),
            onPressed: () => showChangeSystemDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _kPrimaryColor,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _kPrimaryColor),
                  SizedBox(height: 12),
                  Text('Đang tải và xử lý dữ liệu sản phẩm...'),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 8),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _load, child: const Text('Thử lại')),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final visibleItems = _visibleItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Tổng ${visibleItems.length} sản phẩm',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: visibleItems.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Text(
                          'Không tìm thấy sản phẩm phù hợp',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: visibleItems.length,
                  itemBuilder: (context, index) {
                    final item = visibleItems[index];
                    return _ProductListItem(
                      product: item,
                      thumbnailUrl: item.images.isNotEmpty ? _resolveImageUrl(item.images.first) : null,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailScreen(product: item)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: _searchController,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Tìm theo mã hoặc tên sản phẩm...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade500),
                    onPressed: () => _searchController.clear(),
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final Product product;
  final String? thumbnailUrl;
  final VoidCallback onTap;

  const _ProductListItem({required this.product, required this.thumbnailUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: thumbnailUrl == null
                      ? Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400),
                        )
                      : Image.network(
                          thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.maVt,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.displayName.isNotEmpty ? product.displayName : '(Chưa có tên)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    if (product.hangXe.isNotEmpty || product.dongXe.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [product.hangXe, product.dongXe].where((s) => s.isNotEmpty).join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
