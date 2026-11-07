import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';
import 'package:phuthanh_warehouseapp/model/shared/Employee.model.dart';
import 'package:phuthanh_warehouseapp/model/tapdoan/Company.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DanhMucService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DmvtService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/LichSuKhoService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/MaterialPickerSheet.widget.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/SearchableDropdownField.widget.dart';
import 'package:phuthanh_warehouseapp/tapdoan/service/KhoTapDoanService.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);
final NumberFormat _qtyFormat = NumberFormat('#,##0.##');

enum LoaiPhieu { nhap, xuat, dieuChuyen }

extension on LoaiPhieu {
  String get title => switch (this) {
        LoaiPhieu.nhap => 'Phiếu nhập kho',
        LoaiPhieu.xuat => 'Phiếu xuất kho',
        LoaiPhieu.dieuChuyen => 'Phiếu xuất điều chuyển',
      };

  /// Nhập chọn vật tư từ toàn danh mục; xuất/điều chuyển chỉ chọn từ vật tư
  /// đang có tồn trong kho nguồn.
  bool get needsStock => this != LoaiPhieu.nhap;
}

class _Line {
  final Dmvt material;
  final TonKhoCty? stock;
  double qty;
  String? location;

  _Line({required this.material, this.stock, required this.qty, this.location});
}

/// Phiếu nhập / xuất / xuất điều chuyển nhiều dòng vật tư cho 1 kho con.
/// Server chỉ nhận từng vật tư một nên lưu phiếu = gọi API lần lượt từng
/// dòng; dòng nào thành công thì bị gỡ khỏi phiếu, dòng lỗi giữ lại để sửa
/// và lưu lại mà không bị ghi trùng.
class PhieuKhoScreen extends StatefulWidget {
  final Company company;
  final LoaiPhieu loai;
  final List<SubWarehouse> warehouses;
  final SubWarehouse source;
  final List<TonKhoCty> stock;

  const PhieuKhoScreen({
    super.key,
    required this.company,
    required this.loai,
    required this.warehouses,
    required this.source,
    required this.stock,
  });

  @override
  State<PhieuKhoScreen> createState() => _PhieuKhoScreenState();
}

class _PhieuKhoScreenState extends State<PhieuKhoScreen> {
  final KhoTapDoanService _service = KhoTapDoanService();
  final LichSuKhoService _lichSuKhoService = LichSuKhoService();
  final TextEditingController _remarkController = TextEditingController();

  final List<_Line> _lines = [];
  List<Dmvt> _allMaterials = [];
  List<Employee> _employees = [];
  Employee? _employee;
  SubWarehouse? _dest;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _changed = false;

  List<SubWarehouse> get _destOptions => widget.warehouses.where((w) => w != widget.source).toList();

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    final results = await Future.wait<Map<String, dynamic>>([
      widget.loai.needsStock ? Future.value({"isSuccess": true, "body": <Dmvt>[]}) : DmvtService().getAllDmvt(),
      widget.loai == LoaiPhieu.nhap ? Future.value({"isSuccess": true, "body": <Employee>[]}) : DanhMucService().getAllEmployees(),
    ]);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (results[0]["isSuccess"] == true) _allMaterials = results[0]["body"] as List<Dmvt>;
      if (results[1]["isSuccess"] == true) _employees = results[1]["body"] as List<Employee>;
    });
    if (!widget.loai.needsStock && _allMaterials.isEmpty) _snack('Không tải được danh mục vật tư', isError: true);
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  int get _userId => (AppState.instance.get("account") as Account?)?.AccountID ?? 0;

  Future<void> _addLine() async {
    final needsStock = widget.loai.needsStock;
    final candidates = needsStock ? widget.stock.where((s) => s.item.qty > 0).map((s) => s.item.material).toList() : _allMaterials;
    if (candidates.isEmpty) {
      _snack(needsStock ? 'Kho này chưa có vật tư tồn để xuất' : 'Chưa có danh mục vật tư', isError: true);
      return;
    }
    final material = await showMaterialPickerSheet(context, candidates);
    if (material == null || !mounted) return;

    final stock = needsStock ? widget.stock.firstWhere((s) => s.item.material.aid == material.aid) : null;
    final existing = _lines.where((l) => l.material.aid == material.aid).firstOrNull;
    final result = await _askQty(material, stock, existing);
    if (result == null) return;

    setState(() {
      if (existing != null) {
        existing.qty = result.qty;
        existing.location = result.location;
      } else {
        _lines.add(_Line(material: material, stock: stock, qty: result.qty, location: result.location));
      }
    });
  }

  Future<({double qty, String? location})?> _askQty(Dmvt material, TonKhoCty? stock, _Line? existing) {
    final qtyController = TextEditingController(text: existing != null ? _qtyFormat.format(existing.qty).replaceAll(',', '') : '');
    final locationController = TextEditingController(text: existing?.location ?? '');
    final maxQty = stock?.item.qty;
    final formKey = GlobalKey<FormState>();

    return showDialog<({double qty, String? location})>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(material.tenVt.isNotEmpty ? material.tenVt : material.maVt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (maxQty != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('Tồn hiện tại: ${_qtyFormat.format(maxQty)}')),
              TextFormField(
                controller: qtyController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Số lượng *', border: OutlineInputBorder()),
                validator: (v) {
                  final qty = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  if (qty == null || qty <= 0) return 'Số lượng phải lớn hơn 0';
                  if (maxQty != null && qty > maxQty) return 'Vượt quá tồn kho (${_qtyFormat.format(maxQty)})';
                  return null;
                },
              ),
              if (widget.loai == LoaiPhieu.nhap) ...[
                const SizedBox(height: 12),
                TextFormField(controller: locationController, decoration: const InputDecoration(labelText: 'Vị trí', border: OutlineInputBorder())),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kPrimaryColor),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final location = locationController.text.trim();
              Navigator.pop(dialogContext, (
                qty: double.parse(qtyController.text.trim().replaceAll(',', '.')),
                location: location.isEmpty ? null : location,
              ));
            },
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_lines.isEmpty) {
      _snack('Phiếu chưa có dòng vật tư nào', isError: true);
      return;
    }
    if (widget.loai == LoaiPhieu.dieuChuyen && _dest == null) {
      _snack('Vui lòng chọn kho đích', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final remark = _remarkController.text.trim();
    final time = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final failures = <String>[];

    for (final line in List<_Line>.of(_lines)) {
      final result = await _saveLine(line, remark, time);
      if (result["isSuccess"] == true) {
        _lines.remove(line);
        _changed = true;
      } else {
        failures.add('${line.material.maVt}: ${result["message"] ?? 'mã lỗi ${result["statusCode"]}'}');
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (failures.isEmpty) {
      _snack('${widget.loai.title} thành công!');
      Navigator.pop(context, true);
    } else {
      _snack('${failures.length} dòng lỗi, đã gỡ các dòng thành công khỏi phiếu:\n${failures.join('\n')}', isError: true);
    }
  }

  Future<Map<String, dynamic>> _saveLine(_Line line, String remark, String time) {
    final khoCode = widget.company.code;
    switch (widget.loai) {
      case LoaiPhieu.nhap:
        return _service.nhapKho(
          khoCode: khoCode,
          warehouseId: widget.source.id,
          productAid: line.material.aid,
          qty: line.qty,
          location: line.location,
          remark: remark.isEmpty ? null : remark,
          createUser: _userId,
        );
      case LoaiPhieu.xuat:
        return _lichSuKhoService.addHistory(
          khoCode: khoCode,
          dataWareHouseAid: line.stock!.item.dataWareHouseAid,
          qty: -line.qty,
          employeeId: _employee?.EmployeeID,
          remark: remark.isEmpty ? 'Xuất kho ${widget.source.name}' : remark,
          time: time,
          createUser: _userId,
        );
      case LoaiPhieu.dieuChuyen:
        return _service.dieuChuyen(
          khoCode: khoCode,
          sourceDataWareHouseAid: line.stock!.item.dataWareHouseAid,
          destWarehouseId: _dest!.id,
          qty: line.qty,
          employeeId: _employee?.EmployeeID,
          remark: remark.isEmpty ? 'Điều chuyển từ ${widget.source.name} đến ${_dest!.name}' : remark,
          time: time,
          createUser: _userId,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isSaving) Navigator.pop(context, _changed);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(title: Text(widget.loai.title), backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0),
          body: _isLoading ? const Center(child: CircularProgressIndicator(color: _kPrimaryColor)) : _buildForm(),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: FilledButton(
                onPressed: _isSaving || _isLoading ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: _kPrimaryColor, minimumSize: const Size.fromHeight(48)),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Lưu phiếu (${_lines.length} dòng)'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final isTransfer = widget.loai == LoaiPhieu.dieuChuyen;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('${widget.company.name} — ${widget.source.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (isTransfer) ...[
          SearchableDropdownField<SubWarehouse>(
            label: 'Kho đích *',
            value: _dest,
            items: _destOptions,
            labelOf: (w) => w.name,
            allowClear: false,
            onChanged: (v) => setState(() => _dest = v),
          ),
          const SizedBox(height: 12),
        ],
        if (widget.loai != LoaiPhieu.nhap) ...[
          SearchableDropdownField<Employee>(
            label: 'Nhân viên thực hiện',
            value: _employee,
            items: _employees,
            labelOf: (e) => e.NameEmployee,
            onChanged: (v) => setState(() => _employee = v),
          ),
          const SizedBox(height: 12),
        ],
        TextField(controller: _remarkController, maxLines: 2, decoration: const InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Text('Vật tư', style: TextStyle(fontWeight: FontWeight.bold))),
            TextButton.icon(onPressed: _isSaving ? null : _addLine, icon: const Icon(Icons.add_rounded), label: const Text('Thêm vật tư')),
          ],
        ),
        if (_lines.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('Chưa có vật tư nào', style: TextStyle(color: Colors.grey.shade600)))),
        for (final line in _lines)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              title: Text(line.material.tenVt.isNotEmpty ? line.material.tenVt : line.material.maVt, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text([line.material.maVt, if (line.location != null) 'Vị trí: ${line.location}'].join(' · ')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_qtyFormat.format(line.qty), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kPrimaryColor)),
                  IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: _isSaving ? null : () => setState(() => _lines.remove(line))),
                ],
              ),
              onTap: _isSaving
                  ? null
                  : () async {
                      final result = await _askQty(line.material, line.stock, line);
                      if (result == null) return;
                      setState(() {
                        line.qty = result.qty;
                        line.location = result.location;
                      });
                    },
            ),
          ),
      ],
    );
  }
}
