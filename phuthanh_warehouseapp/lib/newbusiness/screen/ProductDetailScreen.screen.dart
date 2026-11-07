import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newbusiness/Product.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/FullScreenImageViewer.widget.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Chi tiết đầy đủ 1 sản phẩm từ file đồng bộ — hiển thị hết các cột có giá
/// trị, gom theo nhóm (thông tin chung / tồn kho / giá vốn / bán ra) vì file
/// gốc có rất nhiều cột (tồn theo từng kho, giá vốn theo từng chi nhánh...).
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  final FunctionConvertHelper _convertHelper = FunctionConvertHelper();
  bool? _isInternalNetwork;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    _checkNetwork();
  }

  Future<void> _checkNetwork() async {
    try {
      final result = await _apiClient.isInternalNetwork();
      if (mounted) setState(() => _isInternalNetwork = result);
    } catch (_) {
      if (mounted) setState(() => _isInternalNetwork = false);
    }
  }

  String _resolveUrl(String url) => _convertHelper.resolveNetworkUrl(url, _isInternalNetwork == true);

  @override
  Widget build(BuildContext context) {
    final images = product.images.map(_resolveUrl).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('CHI TIẾT SẢN PHẨM'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _ProductImageCarousel(images: images),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              product.maVt,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              product.displayName.isNotEmpty ? product.displayName : '(Chưa có tên)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 24),
          _SectionTitle('THÔNG TIN CHUNG'),
          for (final e in product.thongTinChung) _FieldRow(label: e.key, value: e.value),
          const Divider(height: 24),
          _SectionTitle('HÌNH ẢNH (ĐƯỜNG DẪN)'),
          for (final e in product.hinhAnh) _FieldRow(label: e.key, value: e.value),
          const Divider(height: 24),
          _SectionTitle('TỒN KHO'),
          for (final e in product.tonKhoTheoKho) _FieldRow(label: e.key, value: e.value),
          const Divider(height: 24),
          _SectionTitle('GIÁ VỐN'),
          for (final e in product.giaVon) _FieldRow(label: e.key, value: e.value),
          const Divider(height: 24),
          _SectionTitle('BÁN RA'),
          for (final e in product.banRa) _FieldRow(label: e.key, value: e.value),
        ],
      ),
    );
  }
}

class _ProductImageCarousel extends StatefulWidget {
  final List<String> images;

  const _ProductImageCarousel({required this.images});

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(urls: widget.images, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: AspectRatio(
          aspectRatio: 1.4,
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.image_outlined, size: 56, color: Colors.grey.shade400),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openViewer(index),
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(Icons.broken_image, size: 56, color: Colors.grey.shade400),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (widget.images.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex ? _kPrimaryColor : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isNotEmpty ? value : '—',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
