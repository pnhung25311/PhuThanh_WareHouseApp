import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/LichSuKho.model.dart';
import 'package:phuthanh_warehouseapp/model/tapdoan/Company.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/LichSuKhoService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/SearchableDropdownField.widget.dart';
import 'package:phuthanh_warehouseapp/tapdoan/service/KhoTapDoanService.service.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);
final NumberFormat _qtyFormat = NumberFormat('#,##0.##');

enum _Direction { all, nhap, xuat }

/// Lịch sử nhập/xuất của 1 công ty. API lịch sử (`GET /api/lich-su-kho/{kho}`)
/// không có cột kho con, nên khi lọc theo kho con ta lấy tập
/// `dataWareHouseAid` của kho đó từ tồn kho (`ton-kho-cty`) rồi lọc phía app.
class LichSuTapDoanScreen extends StatefulWidget {
  final Company company;
  final List<SubWarehouse> warehouses;
  final SubWarehouse? initialWarehouse;

  const LichSuTapDoanScreen({
    super.key,
    required this.company,
    required this.warehouses,
    this.initialWarehouse,
  });

  @override
  State<LichSuTapDoanScreen> createState() => _LichSuTapDoanScreenState();
}

class _LichSuTapDoanScreenState extends State<LichSuTapDoanScreen> {
  final LichSuKhoService _historyService = LichSuKhoService();
  final KhoTapDoanService _service = KhoTapDoanService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<LichSuKho> _history = [];
  SubWarehouse? _warehouse;
  Set<int> _warehouseAids = {};
  _Direction _direction = _Direction.all;

  @override
  void initState() {
    super.initState();
    _warehouse = widget.initialWarehouse;
    _searchController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final warehouse = _warehouse;
    final results = await Future.wait<Map<String, dynamic>>([
      _historyService.getHistory(widget.company.code),
      if (warehouse != null) _service.getInventory(widget.company.code, warehouse.id),
    ]);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (results[0]["isSuccess"] != true) {
        _history = [];
        _errorMessage = 'Không tải được lịch sử (mã lỗi: ${results[0]["statusCode"]})';
        return;
      }
      _history = results[0]["body"] as List<LichSuKho>;
      if (warehouse != null) {
        if (results[1]["isSuccess"] == true) {
          _warehouseAids = (results[1]["body"] as List<TonKhoCty>).map((e) => e.item.dataWareHouseAid).toSet();
        } else {
          _history = [];
          _errorMessage = 'Không tải được tồn kho để lọc theo kho con';
        }
      }
    });
  }

  List<LichSuKho> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    final list = _history.where((h) {
      if (_warehouse != null && !_warehouseAids.contains(h.dataWareHouseAid)) return false;
      final qty = h.qty ?? 0;
      if (_direction == _Direction.nhap && qty <= 0) return false;
      if (_direction == _Direction.xuat && qty >= 0) return false;
      if (query.isEmpty) return true;
      return '${h.maVt} ${h.tenVt} ${h.nameEmployee ?? ''} ${h.remark ?? ''}'.toLowerCase().contains(query);
    }).toList();
    list.sort((a, b) {
      final byTime = (b.time ?? '').compareTo(a.time ?? '');
      return byTime != 0 ? byTime : b.historyAid.compareTo(a.historyAid);
    });
    return list;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? raw : DateFormat('dd/MM/yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('Lịch sử kho ${widget.company.name}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchableDropdownField<SubWarehouse>(
              label: 'Kho (để trống = tất cả)',
              value: _warehouse,
              items: widget.warehouses,
              labelOf: (w) => w.name,
              onChanged: (v) {
                setState(() => _warehouse = v);
                _load();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo vật tư, nhân viên, ghi chú...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                for (final entry in const {_Direction.all: 'Tất cả', _Direction.nhap: 'Nhập', _Direction.xuat: 'Xuất'}.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: _direction == entry.key,
                      selectedColor: const Color(0xFFCFE8E8),
                      onSelected: (_) => setState(() => _direction = entry.key),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _kPrimaryColor));
    if (_errorMessage != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))));
    }
    final items = _filtered;
    if (items.isEmpty) return Center(child: Text('Không có giao dịch phù hợp', style: TextStyle(color: Colors.grey.shade600)));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final h = items[index];
          final qty = h.qty ?? 0;
          final isIn = qty >= 0;
          final color = isIn ? Colors.green.shade700 : Colors.red.shade700;
          final employee = h.nameEmployee;
          final remark = h.remark;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(isIn ? Icons.south_west_rounded : Icons.north_east_rounded, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.tenVt.isNotEmpty ? h.tenVt : h.maVt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${h.maVt} · ${_formatDate(h.time)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      if (employee != null && employee.isNotEmpty) Text('NV: $employee', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      if (remark != null && remark.isNotEmpty) Text(remark, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${isIn ? '+' : ''}${_qtyFormat.format(qty)}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          );
        },
      ),
    );
  }
}
