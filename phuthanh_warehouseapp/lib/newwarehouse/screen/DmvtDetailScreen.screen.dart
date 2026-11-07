import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/MaterialFormScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DmvtService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/FullScreenImageViewer.widget.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

class DmvtDetailScreen extends StatefulWidget {
  final Dmvt item;

  const DmvtDetailScreen({super.key, required this.item});

  @override
  State<DmvtDetailScreen> createState() => _DmvtDetailScreenState();
}

class _DmvtDetailScreenState extends State<DmvtDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  final FunctionConvertHelper _convertHelper = FunctionConvertHelper();
  bool? _isInternalNetwork;

  Dmvt get item => widget.item;

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

  String _resolveUrl(String url) {
    return _convertHelper.resolveNetworkUrl(url, _isInternalNetwork == true);
  }

  static String _combine(String code, String? name) {
    if (name == null || name.trim().isEmpty) return code;
    return '$code (${name.trim()})';
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature: chức năng đang phát triển')),
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialFormScreen(initial: item),
      ),
    );
    if (updated == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa vật tư "${item.tenVt}" không?\nHành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Xóa',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await DmvtService().deleteMaterial(item.aid);

    if (!context.mounted) return;

    if (result["isSuccess"] == true) {
      Navigator.pop(context, true);
    } else {
      final statusCode = result["statusCode"];
      final message = statusCode == 409
          ? 'Không thể xóa: vật tư đang được sử dụng trong tồn kho/giao dịch.'
          : (result["message"]?.toString() ??
                'Xóa thất bại (mã lỗi: $statusCode)');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THÔNG TIN VẬT TƯ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sửa',
            onPressed: () => _handleEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Xóa',
            onPressed: () => _handleDelete(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showComingSoon(context, 'Chia sẻ'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _DmvtImageCarousel(
            images: [item.img1, item.img2, item.img3]
                .whereType<String>()
                .where((url) => url.trim().isNotEmpty)
                .map(_resolveUrl)
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              item.tenVt.isNotEmpty ? item.tenVt : '(Chưa có tên)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 24),

          _SectionTitle('THÔNG TIN CƠ BẢN'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledValueBlock(
                    label: 'Mã vật tư',
                    value: item.maVt,
                  ),
                ),
                Expanded(
                  child: _LabeledValueBlock(
                    label: 'Đơn vị tính (DVT)',
                    value: item.dvt,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _FieldRow(label: 'Danh điểm g', value: item.danhDiemg),
          _FieldRow(label: 'Danh điểm dd', value: item.danhDiemdd),
          _FieldRow(label: 'Danh điểm c', value: item.danhDiemc),
          _FieldRow(label: 'Danh điểm k', value: item.danhDiemk ?? ''),
          _FieldRow(label: 'Cụm chi tiết', value: item.cumChitiet ?? ''),

          const Divider(height: 24),
          _SectionTitle('THÔNG TIN KỸ THUẬT & SẢN XUẤT'),
          _FieldRow(label: 'Thông số kỹ thuật', value: item.thongSo),
          _FieldRow(
            label: 'Hãng sản xuất',
            value: _combine(item.hangSx, item.tenHang),
          ),
          _FieldRow(
            label: 'Nước sản xuất',
            value: _combine(item.ncSx, item.tenNuoc),
          ),
          _FieldRow(
            label: 'Nhà cung cấp',
            value: _combine(item.ncc, item.tenKh),
          ),

          const Divider(height: 24),
          _SectionTitle('ỨNG DỤNG XE'),
          _FieldRow(
            label: 'Hãng xe',
            value: _combine(item.hangXe, item.tenHangxe),
          ),
          _FieldRow(label: 'Dòng xe', value: item.dongXe),
          _FieldRow(label: 'HS Code', value: item.hsCode),
          _FieldRow(label: 'Ghi chú', value: item.ghiChu),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () =>
                      _showComingSoon(context, 'Thêm vào giỏ hàng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'THÊM VÀO GIỎ HÀNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => _showComingSoon(context, 'Yêu cầu báo giá'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _kPrimaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'YÊU CẦU BÁO GIÁ',
                    style: TextStyle(
                      color: _kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ảnh sản phẩm từ `img1/img2/img3` — vuốt ngang giữa các ảnh, bấm để xem
/// toàn màn hình có pinch/double-tap zoom. Khi vật tư chưa có ảnh nào, hiện
/// khung placeholder.
class _DmvtImageCarousel extends StatefulWidget {
  final List<String> images;

  const _DmvtImageCarousel({required this.images});

  @override
  State<_DmvtImageCarousel> createState() => _DmvtImageCarouselState();
}

class _DmvtImageCarouselState extends State<_DmvtImageCarousel> {
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
        builder: (_) => FullScreenImageViewer(
          urls: widget.images,
          initialIndex: initialIndex,
        ),
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
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
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
                        child: Icon(
                          Icons.broken_image,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
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
                    color: index == _currentIndex
                        ? _kPrimaryColor
                        : Colors.grey.shade300,
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

class _LabeledValueBlock extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledValueBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
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
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
