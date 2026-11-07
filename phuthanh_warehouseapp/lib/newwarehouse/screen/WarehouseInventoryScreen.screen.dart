import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/SearchTextHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Warehouse.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/WarehouseInventoryItem.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/MaterialHistoryScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/ScanInventoryScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/WarehouseTransferScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/WarehouseService.service.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Tồn kho của 1 kho — danh sách dạng card (giống "Danh mục vật tư"), không
/// dùng bảng nhiều cột vì đây là màn hình mobile.
class WarehouseInventoryScreen extends StatefulWidget {
  final Warehouse warehouse;

  const WarehouseInventoryScreen({super.key, required this.warehouse});

  @override
  State<WarehouseInventoryScreen> createState() =>
      _WarehouseInventoryScreenState();
}

class _WarehouseInventoryScreenState extends State<WarehouseInventoryScreen> {
  final WarehouseService _service = WarehouseService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<WarehouseInventoryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.getInventory(
      widget.warehouse.inventoryEndpoint,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result["isSuccess"] == true) {
        _items = result["body"] as List<WarehouseInventoryItem>;
      } else {
        _errorMessage =
            'Không tải được tồn kho (mã lỗi: ${result["statusCode"]})';
      }
    });
  }

  List<WarehouseInventoryItem> get _filteredItems {
    final query = _searchController.text;
    return _items
        .where((item) => SearchTextHelper.matches(item.searchFields, query))
        .toList();
  }

  /// Thêm 1 dòng nhập/xuất giờ thực hiện ngay trong màn lịch sử của từng vật
  /// tư (bấm vào card để mở), vì API `POST /api/lich-su-kho/{kho}` cần
  /// `dataWareHouseAid` của đúng dòng tồn kho đó. FAB ở màn này chỉ còn dùng
  /// cho chuyển kho.
  Future<void> _openTransfer() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WarehouseTransferScreen(sourceWarehouse: widget.warehouse),
      ),
    );
    if (changed == true) _loadInventory();
  }

  /// Server tự tính lại `Qty` tồn kho mỗi khi thêm/sửa/xóa lịch sử — cần tải
  /// lại tồn kho khi quay về để hiển thị đúng số mới nhất.
  Future<void> _openHistory(WarehouseInventoryItem item) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MaterialHistoryScreen(warehouse: widget.warehouse, item: item),
      ),
    );
    if (changed == true) _loadInventory();
  }

  Future<void> _openTransferFor(WarehouseInventoryItem item) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => WarehouseTransferScreen(
          sourceWarehouse: widget.warehouse,
          initialItem: item,
        ),
      ),
    );
    if (changed == true) _loadInventory();
  }

  void _showItemActionSheet(WarehouseInventoryItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  item.material.tenVt.isNotEmpty
                      ? item.material.tenVt
                      : item.material.maVt,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.swap_vert_rounded,
                  color: _kPrimaryColor,
                ),
                title: const Text('Nhập / Xuất'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openHistory(item);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.compare_arrows_rounded,
                  color: _kPrimaryColor,
                ),
                title: const Text('Điều chuyển'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openTransferFor(item);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: _kPrimaryColor,
                ),
                title: const Text('Sửa vị trí'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editLocation(item);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editLocation(WarehouseInventoryItem item) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          EditLocationSheet(warehouse: widget.warehouse, item: item),
    );
    if (saved == true) _loadInventory();
  }

  Future<void> _openScan() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ScanInventoryScreen(warehouse: widget.warehouse, items: _items),
      ),
    );
    if (changed == true) _loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('Tồn kho: ${widget.warehouse.tenKho}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Quét mã vật tư',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: _items.isEmpty ? null : _openScan,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _kPrimaryColor,
        onRefresh: _loadInventory,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kPrimaryColor,
        tooltip: 'Chuyển kho',
        onPressed: _openTransfer,
        child: const Icon(Icons.compare_arrows_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kPrimaryColor),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    }

    final filteredItems = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Tổng ${filteredItems.length} vật tư trong kho',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Text(
                          _items.isEmpty
                              ? 'Kho chưa có tồn kho nào'
                              : 'Không tìm thấy vật tư phù hợp',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _InventoryListItem(
                      item: item,
                      styleIndex: index,
                      onTap: () => _openHistory(item),
                      onLongPress: () => _showItemActionSheet(item),
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
            hintText: 'Tìm theo mã hoặc tên vật tư...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
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

class _ItemStyle {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _ItemStyle(this.icon, this.bgColor, this.iconColor);
}

class _InventoryListItem extends StatelessWidget {
  final WarehouseInventoryItem item;
  final int styleIndex;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _InventoryListItem({
    required this.item,
    required this.styleIndex,
    required this.onTap,
    required this.onLongPress,
  });

  static const List<_ItemStyle> _stylePalette = [
    _ItemStyle(Icons.adjust_rounded, Color(0xFFEDE9FE), Color(0xFF7C6FEF)),
    _ItemStyle(Icons.crop_square_rounded, Color(0xFFFFF3E0), Color(0xFFFFA726)),
    _ItemStyle(
      Icons.view_headline_rounded,
      Color(0xFFE0F2F1),
      Color(0xFF26A69A),
    ),
    _ItemStyle(Icons.hexagon_outlined, Color(0xFFFCE4EC), Color(0xFFEC407A)),
  ];

  static const Map<String, Color> _unitColors = {
    'Bộ': Color(0xFFFFA726),
    'Cái': Color(0xFF42A5F5),
  };

  String get _danhDiem {
    final m = item.material;
    if (m.danhDiemdd.trim().isNotEmpty) return m.danhDiemdd.trim();
    if (m.danhDiemg.trim().isNotEmpty) return m.danhDiemg.trim();
    return m.danhDiemc.trim();
  }

  String get _vehicleTag {
    final m = item.material;
    final hang = (m.tenHangxe?.trim().isNotEmpty ?? false)
        ? m.tenHangxe!.trim()
        : m.hangXe.trim();
    final dong = m.dongXe.trim();
    if (hang.isEmpty) return dong;
    if (dong.isEmpty) return hang;
    return '$hang $dong';
  }

  String get _manufacturerAndSupplierLine {
    final m = item.material;
    final hangSx = (m.tenHang?.trim().isNotEmpty ?? false)
        ? m.tenHang!.trim()
        : m.hangSx.trim();
    final nuoc = (m.tenNuoc?.trim().isNotEmpty ?? false)
        ? m.tenNuoc!.trim()
        : m.ncSx.trim();
    final ncc = (m.tenKh?.trim().isNotEmpty ?? false)
        ? m.tenKh!.trim()
        : m.ncc.trim();
    final manuLine = [hangSx, nuoc].where((s) => s.isNotEmpty).join(' - ');
    return [
      manuLine,
      if (ncc.isNotEmpty) 'NCC: $ncc',
    ].where((s) => s.isNotEmpty).join(' • ');
  }

  String _formatQty(double value) {
    if (value == value.floor()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final m = item.material;
    final style = _stylePalette[styleIndex % _stylePalette.length];
    final unitColor = _unitColors[m.dvt.trim()] ?? Colors.blueGrey;
    final vehicleTag = _vehicleTag;
    final danhDiem = _danhDiem;
    final manufacturerAndSupplierLine = _manufacturerAndSupplierLine;
    final location = item.location?.trim() ?? '';
    final remark = item.remark?.trim() ?? '';
    final qtyColor = item.qty > 0 ? _kPrimaryColor : Colors.redAccent;

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
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: style.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(style.icon, color: style.iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.maVt,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (m.dvt.trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: unitColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              m.dvt,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: unitColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.tenVt.isNotEmpty ? m.tenVt : '(Chưa có tên)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (manufacturerAndSupplierLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        manufacturerAndSupplierLine,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (vehicleTag.isNotEmpty ||
                        danhDiem.isNotEmpty ||
                        location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (vehicleTag.isNotEmpty)
                            _TagChip(
                              icon: Icons.directions_car_filled_rounded,
                              label: vehicleTag,
                            ),
                          if (danhDiem.isNotEmpty)
                            _TagChip(prefixText: 'DĐ', label: danhDiem),
                          if (location.isNotEmpty)
                            _TagChip(
                              icon: Icons.location_on_outlined,
                              label: location,
                            ),
                        ],
                      ),
                    ],
                    if (remark.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        remark,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatQty(item.qty),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: qtyColor,
                    ),
                  ),
                  Text(
                    'tồn',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData? icon;
  final String? prefixText;
  final String label;

  const _TagChip({this.icon, this.prefixText, required this.label});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: Colors.grey.shade700),
              const SizedBox(width: 4),
            ],
            if (prefixText != null) ...[
              Text(
                prefixText!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
