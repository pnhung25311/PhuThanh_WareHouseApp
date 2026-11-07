import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/model/tapdoan/Company.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/SearchableDropdownField.widget.dart';
import 'package:phuthanh_warehouseapp/tapdoan/screen/LichSuTapDoanScreen.screen.dart';
import 'package:phuthanh_warehouseapp/tapdoan/screen/PhieuKhoScreen.screen.dart';
import 'package:phuthanh_warehouseapp/tapdoan/service/KhoTapDoanService.service.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);
final NumberFormat _qtyFormat = NumberFormat('#,##0.##');

/// Tồn kho của 1 công ty theo kho con, kèm 3 thao tác nhập / xuất / điều chuyển.
class CompanyInventoryScreen extends StatefulWidget {
  final Company company;

  const CompanyInventoryScreen({super.key, required this.company});

  @override
  State<CompanyInventoryScreen> createState() => _CompanyInventoryScreenState();
}

class _CompanyInventoryScreenState extends State<CompanyInventoryScreen> {
  final KhoTapDoanService _service = KhoTapDoanService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<SubWarehouse> _warehouses = [];
  SubWarehouse? _selected;
  List<TonKhoCty> _items = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadWarehouses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _service.getSubWarehouses();
    if (!mounted) return;

    final list = result["body"] as List<SubWarehouse>;
    if (result["isSuccess"] != true || list.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = result["isSuccess"] == true
            ? 'Chưa có kho con nào (bảng Warehouse trống).'
            : 'Không tải được danh mục kho (mã lỗi: ${result["statusCode"]})';
      });
      return;
    }
    _warehouses = list;
    _selected = list.first;
    await _loadInventory();
  }

  Future<void> _loadInventory() async {
    final warehouse = _selected;
    if (warehouse == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await _service.getInventory(widget.company.code, warehouse.id);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result["isSuccess"] == true) {
        _items = result["body"] as List<TonKhoCty>;
      } else {
        _items = [];
        _errorMessage = result["message"]?.toString() ?? 'Không tải được tồn kho (mã lỗi: ${result["statusCode"]})';
      }
    });
  }

  List<TonKhoCty> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((e) => '${e.item.material.maVt} ${e.item.material.tenVt}'.toLowerCase().contains(query)).toList();
  }

  Future<void> _openPhieu(LoaiPhieu loai) async {
    final source = _selected;
    if (source == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PhieuKhoScreen(
          company: widget.company,
          loai: loai,
          warehouses: _warehouses,
          source: source,
          stock: _items,
        ),
      ),
    );
    if (changed == true) _loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    final canAct = _selected != null && !_isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('Kho ${widget.company.name}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Lịch sử nhập/xuất',
            icon: const Icon(Icons.history_rounded),
            onPressed: _warehouses.isEmpty
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LichSuTapDoanScreen(company: widget.company, warehouses: _warehouses, initialWarehouse: _selected),
                      ),
                    ),
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _selected == null ? _loadWarehouses : _loadInventory),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchableDropdownField<SubWarehouse>(
              label: 'Kho',
              value: _selected,
              items: _warehouses,
              labelOf: (w) => w.name,
              allowClear: false,
              enabled: _warehouses.isNotEmpty,
              onChanged: (v) {
                if (v == null || v == _selected) return;
                setState(() => _selected = v);
                _loadInventory();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo mã hoặc tên vật tư...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              _actionButton('Nhập', Icons.south_west_rounded, canAct ? () => _openPhieu(LoaiPhieu.nhap) : null),
              const SizedBox(width: 8),
              _actionButton('Xuất', Icons.north_east_rounded, canAct ? () => _openPhieu(LoaiPhieu.xuat) : null),
              const SizedBox(width: 8),
              _actionButton('Điều chuyển', Icons.swap_horiz_rounded, canAct && _warehouses.length > 1 ? () => _openPhieu(LoaiPhieu.dieuChuyen) : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback? onPressed) {
    return Expanded(
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(backgroundColor: _kPrimaryColor),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _kPrimaryColor));
    if (_errorMessage != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))));
    }
    final items = _filtered;
    if (items.isEmpty) return Center(child: Text('Kho chưa có vật tư', style: TextStyle(color: Colors.grey.shade600)));

    return RefreshIndicator(
      onRefresh: _loadInventory,
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final row = items[index].item;
          final location = row.location;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.material.tenVt.isNotEmpty ? row.material.tenVt : '(Chưa có tên)', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(row.material.maVt, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      if (location != null && location.isNotEmpty) Text('Vị trí: $location', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(_qtyFormat.format(row.qty), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: row.qty > 0 ? _kPrimaryColor : Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
