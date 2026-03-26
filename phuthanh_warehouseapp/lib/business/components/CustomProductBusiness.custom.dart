import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/cart/CartDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/product/ProductBusinessDetailsScreen.screen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/StockAllocatorHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Business.model.dart';

class ProductCard extends StatelessWidget {
  final Business item;
  final VoidCallback? onLongPress;

  const ProductCard({super.key, required this.item, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final barcode = item.barcode.trim();
    final name = item.tenHangHoa.trim();
    NavigationHelper nav = NavigationHelper();

    final images = [
      item.hinhAnh1,
      item.hinhAnh2,
      item.hinhAnh3,
    ].whereType<String>().where((url) => url.trim().isNotEmpty).toList();

    // final hasImages = images.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Dismissible(
            key: ValueKey(item.barcode), // phải unique
            direction: DismissDirection.horizontal, // chỉ swipe trái
            // nền khi kéo
            background: _buildLeftBackground(),
            secondaryBackground: _buildRightBackground(),

            // xác nhận (có thể bỏ nếu không cần)
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                Cart cart = Cart(
                  cartAID: 0,
                  productID: item.barcode.trim(),
                  idPartNo: item.danhDiem,
                  nameProduct: item.tenHangHoa,
                  manufacturerName: item.hangSanXuat,
                  countryName: item.nuocSanXuat,
                );
                nav.push(context, CartDetailScreen(item: cart, isCreate: true));
                return false;
              } else if (direction == DismissDirection.startToEnd) {
                Cart cart = Cart(
                  cartAID: 0,
                  productID: item.barcode.trim(),
                  idPartNo: item.danhDiem,
                  nameProduct: item.tenHangHoa,
                  manufacturerName: item.hangSanXuat,
                  countryName: item.nuocSanXuat,
                );
                nav.push(context, CartDetailScreen(item: cart, isCreate: true));
                return false;
              }
              return false;
            },

            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailScreen(item: item),
                  ),
                );
              },
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(16),
              child: Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barcode,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Product name
                          Text(
                            name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 12),

                          // Key specs - compact grid
                          _buildKeyInfoRow(context),

                          const SizedBox(height: 16),

                          // Price & VAT
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildPriceSection()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildVatSection()),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Stock chips
                          _buildStockChips(isNarrow: isNarrow),
                          const SizedBox(height: 8),

                          _buildStockVAT(isNarrow: isNarrow),

                          const SizedBox(height: 16),

                          // Co/Cq tags
                          Row(
                            children: [
                              if (item.coCqVietY.trim().isNotEmpty == true)
                                _buildTag('Co/Cq Việt Ý', item.coCqVietY),
                              const SizedBox(width: 8),
                              if (item.coCqPhuThanh.trim().isNotEmpty == true)
                                _buildTag('Co/Cq Phú Thành', item.coCqPhuThanh),
                            ],
                          ),

                          if (images.length > 1) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Hình ảnh khác',
                              style: textTheme.labelMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 86,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length - 1,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final url = images[index + 1];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      width: 120,
                                      height: 86,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholderImage(
                                            width: 120,
                                            height: 86,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholderImage({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
    );
  }

  Widget _buildKeyInfoRow(BuildContext context) {
    final infos = [
      _Info(Icons.label_outline, 'Danh điểm', item.danhDiem),
      _Info(Icons.code, 'Bộ ĐĐ', item.boDanhDiemTuongDuong),
      _Info(Icons.settings, 'Thông số', item.thongSoKyThuat),
      _Info(Icons.factory, 'Hãng SX', item.hangSanXuat),
      _Info(Icons.public, 'Nước SX', item.nuocSanXuat),
    ].where((e) => e.value?.trim().isNotEmpty == true).toList();

    if (infos.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: infos
          .map(
            (info) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(info.icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${info.label}: ${info.value}',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildPriceSection() {
    final p1 = item.giaVon1;
    final p2 = item.giaVon2;

    // if ((p1 ?? 0) <= 0 && (p2 ?? 0) <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giá vốn',
            style: TextStyle(
              color: Colors.amber.shade800,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (p1 != null && p1 > 0) ...[
            Text(
              'Giá vốn 1: ${_formatPrice(p1)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ] else ...[
            Text(
              'Giá vốn 1: 0₫',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],

          if (p2 != null && p2 > 0) ...[
            Text(
              'Giá vốn 2: ${_formatPrice(p2)}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ] else ...[
            Text(
              'Giá vốn 2: 0₫',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVatSection() {
    final vy = item.vatVietY ?? 0;
    final pt = item.vatPhuThanh ?? 0;
    // if ((vy) <= 0 && (pt) <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VAT',
            style: TextStyle(
              color: Colors.purple.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          // if (pt > 0)
          Text(
            'Phú Thành: ${pt.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 13.5),
          ),
          // if (vy > 0)
          Text(
            'Việt Ý: ${vy.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStockChips({required bool isNarrow}) {
    final stocks = [
      _Stock('Kho Chính', item.khoChinh, Colors.blue),
      _Stock('Kho 397', item.kho397, Colors.indigo),
      _Stock('Kho Khe Dây', item.khoKheDay, Colors.teal),
      _Stock('Kho Khoáng Sản', item.khoKhoangSan, Colors.cyan),
      _Stock('Kho Làng Khánh', item.khoLangKhanh, Colors.green),

      _Stock('HKD H.V Dũng', item.hkdHoangVanDung, Colors.orange),
      _Stock('HKD L.V Thiện', item.hkdLeVanThien, Colors.deepOrange),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stocks
          .where((s) => (s.qty ?? 0) > 0) // 👈 lọc chỉ lấy cái có tồn kho
          .map((s) {
            final qty = s.qty ?? 0;
            final color = s.color;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(
                '${s.label}: ${_formatQuantity(qty)}',
                style: TextStyle(
                  fontSize: 12.5,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          })
          .toList(),
    );
  }

  Widget _buildStockVAT({required bool isNarrow}) {
    final allocator = StockAllocator();

    int VATpt = item.vatPhuThanh?.toInt() ?? 0;
    int VATvy = item.vatVietY?.toInt() ?? 0;
    int khoC = item.khoChinh?.toInt() ?? 0;
    int khoLK = item.khoLangKhanh?.toInt() ?? 0;
    int khoKS = item.khoKhoangSan?.toInt() ?? 0;
    int khoKD = item.khoKheDay?.toInt() ?? 0;
    int kho397 = item.kho397?.toInt() ?? 0;

    int total = kho397 + khoKD + khoKS + khoC + khoLK;

    Map<String, int> input = {"VATpt": VATpt, "VATvy": VATvy};

    final result = allocator.allocate(input, total);

    /// 🔥 Chuẩn hóa data theo row
    final rows = [
      [
        _Stock(
          'VAT PT K1',
          (result['VATpt']?.co ?? 0).toDouble(),
          Colors.green,
        ),
        _Stock(
          'VAT VY K1',
          (result['VATvy']?.co ?? 0).toDouble(),
          Colors.green,
        ),
      ],
      [
        _Stock(
          'VAT PT K0',
          (result['VATpt']?.ko ?? 0).toDouble(),
          Colors.green,
        ),
        _Stock(
          'VAT VY K0',
          (result['VATvy']?.ko ?? 0).toDouble(),
          Colors.green,
        ),
      ],
    ];

    Widget buildItem(_Stock s) {
      final qty = s.qty ?? 0;
      final color = qty > 0 ? s.color : Colors.red;

      return Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          '${s.label}: ${_formatQuantity(qty)}',
          style: TextStyle(
            fontSize: 12.5,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: rows.map((row) {
        return Row(
          children: row
              .map((item) => Expanded(child: buildItem(item)))
              .toList(),
        );
      }).toList(),
    );
  }

  Widget _buildLeftBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_shopping_cart, color: Colors.white),
          SizedBox(width: 6),
          Text(
            "Thêm giỏ hàng",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // /// Swipe trái (EDIT)
  Widget _buildRightBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Thêm giỏ hàng",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 6),
          Icon(Icons.add_shopping_cart, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12.5, color: Colors.blueGrey),
      ),
    );
  }

  String _formatPrice(double value) {
    final str = value.toStringAsFixed(0);
    return '${str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ₫';
  }

  String _formatQuantity(double value) {
    if (value == value.floor()) {
      return value.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return value.toStringAsFixed(1);
  }
}

class _Info {
  final IconData icon;
  final String label;
  final String? value;

  _Info(this.icon, this.label, this.value);
}

class _Stock {
  final String label;
  final double? qty;
  final Color color;

  _Stock(this.label, this.qty, this.color);
}
