import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Warehouse.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/WarehouseInventoryItem.model.dart';
import 'package:phuthanh_warehouseapp/model/shared/Employee.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DanhMucService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DmvtService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/LichSuKhoService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/WarehouseService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/store/PinnedLookupStore.store.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/MaterialPickerSheet.widget.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/SearchableDropdownField.widget.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Chuyển 1 vật tư từ kho nguồn sang kho đích bằng 1 lời gọi atomic
/// `POST /api/dieu-chuyen-kho`: server ghi 2 dòng lịch sử (âm ở nguồn, dương ở
/// đích) cùng `noLot` + `TransferGroupID`, tự tạo dòng tồn kho đích nếu chưa
/// có và tính lại tồn cả 2 bên trong 1 transaction (lỗi thì rollback cả hai).
/// Chỉ áp dụng cho 6 kho dmvt, dmvt-lk, dmvt-kd, dmvt-397, dmvt-ks, dmvt-cty.
/// Phía app chỉ cần `dataWareHouseAid` của dòng tồn kho nguồn (lấy qua
/// `GET /api/ton-kho/{kho}/kiem-tra/{id}`).
class WarehouseTransferScreen extends StatefulWidget {
  final Warehouse sourceWarehouse;

  /// Truyền sẵn khi mở từ kết quả quét mã / long-press 1 item tồn kho — khoá
  /// luôn vật tư, không cho chọn lại. `dataWareHouseAid` thực tế dùng khi ghi
  /// lịch sử luôn được lấy mới từ API kiểm tra, không dùng trực tiếp từ đây.
  final WarehouseInventoryItem? initialItem;

  /// Mã lô lấy từ QR (`MaVT-MaLot`) — điền sẵn vào ô Số lô.
  final String? initialNoLot;

  const WarehouseTransferScreen({
    super.key,
    required this.sourceWarehouse,
    this.initialItem,
    this.initialNoLot,
  });

  @override
  State<WarehouseTransferScreen> createState() =>
      _WarehouseTransferScreenState();
}

class _WarehouseTransferScreenState extends State<WarehouseTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final LichSuKhoService _lichSuKhoService = LichSuKhoService();
  final WarehouseService _warehouseService = WarehouseService();
  final DmvtService _dmvtService = DmvtService();
  final DanhMucService _danhMucService = DanhMucService();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _noLotController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  List<Warehouse> _targetWarehouses = [];
  List<Dmvt> _materials = [];
  List<Employee> _employees = [];

  Warehouse? _selectedTarget;
  Dmvt? _selectedMaterial;
  Employee? _selectedEmployee;

  bool get _isMaterialLocked => widget.initialItem != null;

  @override
  void initState() {
    super.initState();
    _selectedMaterial = widget.initialItem?.material;
    _noLotController.text = widget.initialNoLot ?? '';
    _loadData();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    _noLotController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _targetWarehouses = kWarehouses
          .where(
            (w) =>
                w.id != widget.sourceWarehouse.id &&
                kTransferKhoCodes.contains(w.khoCode),
          )
          .toList();
    });

    final results = await Future.wait<Map<String, dynamic>>([
      _isMaterialLocked
          ? Future.value(<String, dynamic>{"isSuccess": true, "body": <Dmvt>[]})
          : _dmvtService.getAllDmvt(),
      _danhMucService.getAllEmployees(),
    ]);

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      final materialsResult = results[0];
      if (!_isMaterialLocked) {
        if (materialsResult["isSuccess"] == true) {
          _materials = materialsResult["body"] as List<Dmvt>;
        } else {
          _errorMessage = 'Không tải được danh mục vật tư.';
        }
      }

      final employeesResult = results[1];
      if (employeesResult["isSuccess"] == true) {
        _employees = employeesResult["body"] as List<Employee>;
        if (PinnedLookupStore.pinnedEmployee != null) {
          for (final e in _employees) {
            if (e.EmployeeID == PinnedLookupStore.pinnedEmployee!.EmployeeID) {
              _selectedEmployee = e;
              break;
            }
          }
        }
      }
    });
  }

  Future<void> _pickMaterial() async {
    final selected = await showMaterialPickerSheet(context, _materials);
    if (selected != null) setState(() => _selectedMaterial = selected);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int? _currentUserId() {
    final account = AppState.instance.get("account") as Account?;
    return account?.AccountID;
  }

  Future<void> _handleSubmit() async {
    if (_selectedMaterial == null) {
      _showSnackBar('Vui lòng chọn vật tư', isError: true);
      return;
    }
    if (_selectedTarget == null) {
      _showSnackBar('Vui lòng chọn kho đích', isError: true);
      return;
    }
    if (!kTransferKhoCodes.contains(widget.sourceWarehouse.khoCode)) {
      _showSnackBar(
        'Kho "${widget.sourceWarehouse.tenKho}" không hỗ trợ điều chuyển giữa các kho.',
        isError: true,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final material = _selectedMaterial!;
    final target = _selectedTarget!;

    setState(() => _isSaving = true);

    // Server cần đúng `dataWareHouseAid` của dòng tồn kho nguồn (404 nếu không
    // thấy). Kho đích không cần: server tự tìm theo vật tư / tự tạo.
    final check = await _warehouseService.checkMaterialInWarehouse(
      widget.sourceWarehouse.khoCode,
      material.aid,
    );
    if (!mounted) return;

    if (check["isSuccess"] != true) {
      setState(() => _isSaving = false);
      _showSnackBar(
        'Không kiểm tra được tồn kho ở "${widget.sourceWarehouse.tenKho}" (mã lỗi: ${check["statusCode"]})',
        isError: true,
      );
      return;
    }
    final sourceDataWareHouseAid = check["dataWareHouseAid"] as int?;
    if (check["exists"] != true || sourceDataWareHouseAid == null) {
      setState(() => _isSaving = false);
      _showSnackBar(
        'Vật tư chưa có tồn kho ở "${widget.sourceWarehouse.tenKho}" nên không thể điều chuyển.',
        isError: true,
      );
      return;
    }

    final qty = double.parse(_qtyController.text.trim().replaceAll(',', '.'));
    final note = _noteController.text.trim();
    final result = await _lichSuKhoService.dieuChuyenKho(
      sourceKho: widget.sourceWarehouse.khoCode,
      sourceDataWareHouseAid: sourceDataWareHouseAid,
      destKho: target.khoCode,
      qty: qty,
      noLot: _noLotController.text.trim(),
      employeeId: _selectedEmployee?.EmployeeID,
      // Ghi cùng 1 nội dung ở cả 2 đầu để đọc lịch sử ở bên nào cũng biết
      // trọn vẹn hành trình chuyển kho.
      remark:
          'Điều chuyển từ ${widget.sourceWarehouse.tenKho} đến ${target.tenKho}'
          '${note.isNotEmpty ? ' — $note' : ''}',
      time: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      createUser: _currentUserId(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result["isSuccess"] == true) {
      _showSnackBar('Chuyển kho thành công!');
      Navigator.pop(context, true);
    } else {
      _showSnackBar(
        result["message"]?.toString() ??
            'Chuyển kho thất bại (mã lỗi: ${result["statusCode"]})',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: const Text('Chuyển kho'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _kPrimaryColor),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildReadOnlyBox(
                            label: 'Kho nguồn',
                            value: widget.sourceWarehouse.tenKho,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: _kPrimaryColor,
                          ),
                        ),
                        Expanded(
                          child: SearchableDropdownField<Warehouse>(
                            label: 'Kho đích *',
                            value: _selectedTarget,
                            items: _targetWarehouses,
                            labelOf: (w) => w.tenKho,
                            allowClear: false,
                            onChanged: (v) =>
                                setState(() => _selectedTarget = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Vật tư',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _isMaterialLocked ? null : _pickMaterial,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                          color: _isMaterialLocked
                              ? Colors.grey.shade100
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedMaterial == null
                                    ? 'Chạm để chọn vật tư'
                                    : '${_selectedMaterial!.maVt} — ${_selectedMaterial!.tenVt}',
                                style: TextStyle(
                                  color: _selectedMaterial == null
                                      ? Colors.grey.shade500
                                      : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!_isMaterialLocked)
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SearchableDropdownField<Employee>(
                      label: 'Nhân viên thực hiện',
                      value: _selectedEmployee,
                      items: _employees,
                      labelOf: (e) => e.NameEmployee,
                      onChanged: (v) => setState(() => _selectedEmployee = v),
                      isPinned: PinnedLookupStore.isEmployeePinned(
                        _selectedEmployee,
                      ),
                      onTogglePin: () => setState(
                        () => PinnedLookupStore.toggleEmployeePin(
                          _selectedEmployee,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Số lượng *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Bắt buộc nhập';
                        final parsed = double.tryParse(
                          v.trim().replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed <= 0)
                          return 'Số lượng không hợp lệ';
                        return null;
                      },
                    ),
                    if (kNoLotKhoCodes.contains(
                      widget.sourceWarehouse.khoCode,
                    )) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _noLotController,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Số lô',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: (_isSaving || _isLoading) ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'CHUYỂN KHO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
