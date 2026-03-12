import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/info/Business.model.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Business item;

  const BusinessDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final images = [
      item.hinhAnh1,
      item.hinhAnh2,
      item.hinhAnh3,
    ].whereType<String>().where((url) => url.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.tenHangHoa.trim().isNotEmpty
              ? item.tenHangHoa
              : 'Chi tiết sản phẩm',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã copy: ${item.barcode}')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            if (images.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    images.first,
                    height: 220,
                    width: MediaQuery.of(context).size.width * 0.9,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      width: MediaQuery.of(context).size.width * 0.9,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              if (images.length > 1) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text(
                    'Hình ảnh khác',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length - 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final url = images[index + 1];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          width: 140,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 140,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ] else ...[
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 120,
                  color: Colors.grey.shade400,
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Không có hình ảnh',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Thông tin chính
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow('Barcode', item.barcode, isBold: true),
                      _buildRow('Tên hàng hóa', item.tenHangHoa, maxLines: 2),
                      _buildRow('Danh điểm', item.danhDiem),
                      _buildRow(
                        'Bộ danh điểm tương đương',
                        item.boDanhDiemTuongDuong,
                        maxLines: 2,
                      ),
                      _buildRow('Mã Keeton', item.maKeeton),
                      _buildRow('Mã Công Nghiệp', item.maCongNghiep),
                      _buildRow(
                        'Thông số kỹ thuật',
                        item.thongSoKyThuat,
                        maxLines: 3,
                      ),
                      _buildRow('Hãng xe', item.hangXe),
                      _buildRow('Dòng xe', item.dongXe),
                      _buildRow('Cụm xe', item.cumXe),
                      _buildRow('Hãng sản xuất', item.hangSanXuat),
                      _buildRow('Nước sản xuất', item.nuocSanXuat),
                      _buildRow('Đơn vị tính', item.donViTinh),
                      _buildRow('Nhà cung cấp thực tế', item.nhaCungCapThucTe),
                      _buildRow(
                        'Nhà cung cấp hợp đồng',
                        item.nhaCungCapHopDong,
                      ),
                      _buildRow('Vị trí', item.viTri),
                      _buildRow('Ghi chú', item.ghiChu, maxLines: 3),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tồn kho
            if (_hasMeaningfulStock()) _buildStockCard(),

            const SizedBox(height: 16),

            // Giá & Thông tin khác
            if (_hasMeaningfulPriceOrOther()) _buildPriceAndOtherCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.green.shade50,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tồn kho',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 46, 125, 50),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStockChip('Kho chính', item.khoChinh),
                  _buildStockChip('Kho 397', item.kho397),
                  _buildStockChip('Khe Dây', item.khoKheDay),
                  _buildStockChip('Khoáng Sản', item.khoKhoangSan),
                  _buildStockChip('Làng Khánh', item.khoLangKhanh),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceAndOtherCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.amber.shade50,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giá & Thông tin khác',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 246, 107, 1),
                ),
              ),
              const SizedBox(height: 12),

              // Giá vốn & VAT
              _buildPriceRow('Giá vốn 1', item.formattedGiaVon1),
              if (item.giaVon2 != null && item.giaVon2! > 0)
                _buildPriceRow('Giá vốn 2', _formatNumber(item.giaVon2!)),
              _buildRow('VAT Việt Ý', _formatVat(item.vatVietY)),
              _buildRow('VAT Phú Thành', _formatVat(item.vatPhuThanh)),
              _buildRow('Ghi chú VAT', item.ghiChuVat),

              // const SizedBox(height: 12),
              // const Divider(height: 1, color: Colors.grey.shade300),
              // const SizedBox(height: 12),

              // Thông tin khác
              _buildRow('CoCq Việt Ý', item.coCqVietY),
              _buildRow('CoCq Phú Thành', item.coCqPhuThanh),
              _buildRow('Tổng số lượng bán ra', item.formattedTongSoLuongBanRa),
              _buildRow(
                'SL bán gần nhất',
                _formatNumberOrDash(item.soLuongBanRaGanNhat),
              ),
              _buildRow('Thời gian bán gần nhất', item.thoiGianBanRaGanNhat),
              _buildRow('Số lượng dự kiến', item.soLuongDuKien),
              _buildRow('Mã số hóa đơn', item.maSoHoaDon),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Logic kiểm tra có dữ liệu ý nghĩa

  bool _hasMeaningfulStock() {
    return [
      item.khoChinh,
      item.kho397,
      item.khoKheDay,
      item.khoKhoangSan,
      item.khoLangKhanh,
    ].any((qty) => qty != null && qty > 0);
  }

  bool _hasMeaningfulPriceOrOther() {
    final hasPrice = item.giaVon1 != null || item.giaVon2 != null;
    final hasVat = item.vatVietY != null || item.vatPhuThanh != null;
    final hasOther = [
      item.ghiChuVat,
      item.coCqVietY,
      item.coCqPhuThanh,
      item.nhaCungCapThucTe,
      item.nhaCungCapHopDong,
      item.soLuongDuKien,
      item.maSoHoaDon,
      item.thoiGianBanRaGanNhat,
    ].any((v) => v.trim().isNotEmpty);

    final hasSales =
        item.tongSoLuongBanRa != null || item.soLuongBanRaGanNhat != null;

    return hasPrice || hasVat || hasOther || hasSales;
  }

  // ────────────────────────────────────────────────
  // Helper format & build

  String _formatVat(double? value) {
    if (value == null || value <= 0) return '—';
    return value.toStringAsFixed(2);
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatNumberOrDash(double? value) {
    if (value == null || value <= 0) return '—';
    return _formatNumber(value);
  }

  Widget _buildHeaderRow(String label, String value, {bool isBold = false}) {
    final display = value.trim().isEmpty ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              display,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? Colors.blueGrey.shade900 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String? value, {int maxLines = 1}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == '—') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Tooltip(
              message: trimmed,
              child: Text(
                trimmed,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed == '-' ||
        trimmed == '0' ||
        trimmed == '0.00') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          Text(
            trimmed,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 111, 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockChip(String label, double? qty) {
    if (qty == null || qty <= 0) return const SizedBox.shrink();

    final color = qty > 0 ? Colors.green : Colors.orange;

    return Chip(
      label: Text(
        '$label: ${_formatNumber(qty)}',
        style: TextStyle(color: color.shade800),
      ),
      backgroundColor: color.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
