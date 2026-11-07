import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/DanhMuc.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/LichSuKho.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Warehouse.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/WarehouseInventoryItem.model.dart';
import 'package:phuthanh_warehouseapp/model/shared/Employee.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DanhMucService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/LichSuKhoService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/store/PinnedLookupStore.store.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/SearchableDropdownField.widget.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Lịch sử nhập/xuất của 1 vật tư tại 1 kho — `GET /api/lich-su-kho/{kho}`
/// trả về toàn bộ lịch sử của cả kho, nên lọc theo `productAid` ở client.
/// Quy ước hiển thị: `qty` dương = Nhập (xanh), âm = Xuất (đỏ) — API không
/// có field `type` riêng, dấu của `qty` là cách duy nhất phân biệt.
class MaterialHistoryScreen extends StatefulWidget {
  final Warehouse warehouse;
  final WarehouseInventoryItem item;

  /// Mã lô lấy từ QR (`MaVT-MaLot`) — điền sẵn vào form thêm mới.
  final String? initialNoLot;

  const MaterialHistoryScreen({
    super.key,
    required this.warehouse,
    required this.item,
    this.initialNoLot,
  });

  @override
  State<MaterialHistoryScreen> createState() => _MaterialHistoryScreenState();
}

class _MaterialHistoryScreenState extends State<MaterialHistoryScreen> {
  final LichSuKhoService _service = LichSuKhoService();

  bool _isLoading = true;
  String? _errorMessage;
  List<LichSuKho> _history = [];

  /// true nếu đã thêm/sửa/xóa ít nhất 1 dòng lịch sử — báo cho màn tồn kho
  /// biết cần tải lại để lấy đúng `Qty` mới (server tự tính lại SUM).
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Server tính `Qty` tồn kho = SUM(qty) các dòng lịch sử cùng
  /// `dataWareHouseAid` — tính lại y hệt công thức đó ở client để hiển thị
  /// ngay số mới nhất mà không cần gọi lại API tồn kho.
  double get _currentQty {
    final dataWareHouseAid = widget.item.dataWareHouseAid;
    if (_history.isEmpty) return widget.item.qty;
    double sum = 0;
    bool matchedAny = false;
    for (final h in _history) {
      if (h.dataWareHouseAid == dataWareHouseAid) {
        sum += h.qty ?? 0;
        matchedAny = true;
      }
    }
    return matchedAny ? sum : widget.item.qty;
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.getHistory(widget.warehouse.khoCode);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result["isSuccess"] == true) {
        final all = result["body"] as List<LichSuKho>;
        _history =
            all.where((h) => h.productAid == widget.item.material.aid).toList()
              ..sort((a, b) => (b.time ?? '').compareTo(a.time ?? ''));
      } else {
        _errorMessage =
            'Không tải được lịch sử (mã lỗi: ${result["statusCode"]})';
      }
    });
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

  Future<void> _openAddForm() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _HistoryFormSheet(
        khoCode: widget.warehouse.khoCode,
        dataWareHouseAid: widget.item.dataWareHouseAid,
        initialNoLot: widget.initialNoLot,
      ),
    );

    if (result == true) {
      _changed = true;
      _loadHistory();
    }
  }

  Future<void> _openEditForm(LichSuKho entry) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _HistoryFormSheet(
        khoCode: widget.warehouse.khoCode,
        dataWareHouseAid: widget.item.dataWareHouseAid,
        editing: entry,
      ),
    );

    if (result == true) {
      _changed = true;
      _loadHistory();
    }
  }

  Future<void> _handleDelete(LichSuKho entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa dòng lịch sử này không?',
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

    if (confirmed != true) return;

    final result = await _service.deleteHistory(
      widget.warehouse.khoCode,
      entry.historyAid,
      updateUser: (AppState.instance.get("account") as Account?)?.AccountID,
    );
    if (!mounted) return;

    if (result["isSuccess"] == true) {
      _showSnackBar('Đã xóa lịch sử');
      _changed = true;
      _loadHistory();
    } else {
      _showSnackBar(
        result["message"]?.toString() ??
            'Xóa thất bại (mã lỗi: ${result["statusCode"]})',
        isError: true,
      );
    }
  }

  void _showRowActionSheet(LichSuKho entry) {
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
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: _kPrimaryColor),
                title: const Text('Sửa'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openEditForm(entry);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text('Xóa'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _handleDelete(entry);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  String _formatQty(double value) {
    final abs = value.abs();
    if (abs == abs.floor()) return abs.toInt().toString();
    return abs.toStringAsFixed(1);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 5),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qty = _currentQty;
    final qtyColor = qty > 0 ? _kPrimaryColor : Colors.redAccent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: const Text('Lịch sử vật tư'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: RefreshIndicator(
          color: _kPrimaryColor,
          onRefresh: _loadHistory,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.material.tenVt.isNotEmpty
                                ? widget.item.material.tenVt
                                : '(Chưa có tên)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.item.material.maVt} • Kho: ${widget.warehouse.tenKho}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatQty(qty),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: qtyColor,
                          ),
                        ),
                        Text(
                          'tồn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _kPrimaryColor,
          tooltip: 'Thêm nhập/xuất',
          onPressed: _openAddForm,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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

    if (_history.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Text(
                'Chưa có giao dịch nào',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = _history[index];
        final qty = entry.qty ?? 0;
        final isExport = qty < 0;
        final color = isExport ? Colors.redAccent : Colors.green;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExport
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isExport ? 'Xuất kho' : 'Nhập kho',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${isExport ? '-' : '+'}${_formatQty(qty)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Ngày',
                      _formatDate(entry.time),
                    ),
                    if ((entry.nameEmployee ?? '').trim().isNotEmpty)
                      _buildInfoRow(
                        Icons.person_outline_rounded,
                        'Nhân viên',
                        entry.nameEmployee!.trim(),
                      ),
                    if ((entry.tenKh ?? '').trim().isNotEmpty)
                      _buildInfoRow(
                        Icons.local_shipping_outlined,
                        'NCC/Khách hàng',
                        entry.tenKh!.trim(),
                      ),
                    if ((entry.noLot ?? '').trim().isNotEmpty)
                      _buildInfoRow(
                        Icons.inventory_2_outlined,
                        'Số lô',
                        entry.noLot!.trim(),
                      ),
                    if ((entry.remark ?? '').trim().isNotEmpty)
                      _buildInfoRow(
                        Icons.notes_rounded,
                        'Ghi chú',
                        entry.remark!.trim(),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                onPressed: () => _showRowActionSheet(entry),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Form thêm/sửa 1 dòng lịch sử nhập/xuất — dùng chung cho cả thêm mới
/// (`editing == null`) và sửa (`editing != null`).
class _HistoryFormSheet extends StatefulWidget {
  final String khoCode;
  final int? dataWareHouseAid;
  final LichSuKho? editing;
  final String? initialNoLot;

  const _HistoryFormSheet({
    required this.khoCode,
    this.dataWareHouseAid,
    this.editing,
    this.initialNoLot,
  });

  @override
  State<_HistoryFormSheet> createState() => _HistoryFormSheetState();
}

class _HistoryFormSheetState extends State<_HistoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final LichSuKhoService _service = LichSuKhoService();
  final DanhMucService _danhMucService = DanhMucService();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _noLotController = TextEditingController();

  bool _isExport = false;
  DateTime _date = DateTime.now();
  bool _isSaving = false;
  bool _isLoadingLookups = true;
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  List<Employee> _employees = [];
  Employee? _selectedEmployee;

  bool get _isEditing => widget.editing != null;

  /// Chỉ 5 kho có cột NoLot; kho khác server bỏ qua nên ẩn ô nhập.
  bool get _hasNoLot => kNoLotKhoCodes.contains(widget.khoCode);

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      final qty = editing.qty ?? 0;
      _isExport = qty < 0;
      _qtyController.text = qty.abs() == qty.abs().floor()
          ? qty.abs().toInt().toString()
          : qty.abs().toString();
      _remarkController.text = editing.remark ?? '';
      _noLotController.text = editing.noLot ?? '';
      final parsedDate = DateTime.tryParse(editing.time ?? '');
      if (parsedDate != null) _date = parsedDate;
    } else {
      _noLotController.text = widget.initialNoLot ?? '';
    }
    _loadLookups();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _remarkController.dispose();
    _noLotController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() => _isLoadingLookups = true);

    final results = await Future.wait([
      _danhMucService.getAllKhachHang(),
      _danhMucService.getAllEmployees(),
    ]);

    if (!mounted) return;

    final editing = widget.editing;

    setState(() {
      _isLoadingLookups = false;

      final customersResult = results[0];
      if (customersResult["isSuccess"] == true) {
        _customers = customersResult["body"] as List<Customer>;
        if (editing?.ncc != null && editing!.ncc!.trim().isNotEmpty) {
          for (final c in _customers) {
            if (c.maKh == editing.ncc!.trim()) {
              _selectedCustomer = c;
              break;
            }
          }
        } else if (!_isEditing && PinnedLookupStore.pinnedCustomer != null) {
          // Thêm mới (không phải sửa) -> áp dụng NCC đã ghim từ lần trước.
          for (final c in _customers) {
            if (c.maKh == PinnedLookupStore.pinnedCustomer!.maKh) {
              _selectedCustomer = c;
              break;
            }
          }
        }
      }

      final employeesResult = results[1];
      if (employeesResult["isSuccess"] == true) {
        _employees = employeesResult["body"] as List<Employee>;
        if (editing?.employeeId != null) {
          for (final e in _employees) {
            if (e.EmployeeID == editing!.employeeId) {
              _selectedEmployee = e;
              break;
            }
          }
        } else if (!_isEditing && PinnedLookupStore.pinnedEmployee != null) {
          // Thêm mới (không phải sửa) -> áp dụng nhân viên đã ghim từ lần trước.
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  int? _currentUserId() {
    final account = AppState.instance.get("account") as Account?;
    return account?.AccountID;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final rawQty = double.parse(
      _qtyController.text.trim().replaceAll(',', '.'),
    );
    final signedQty = _isExport ? -rawQty : rawQty;
    // `employeeId` = nhân viên thực hiện nghiệp vụ (chọn từ danh sách nhân
    // viên), khác với `createUser` = tài khoản app đang đăng nhập ghi bản ghi.
    final employeeId = _selectedEmployee?.EmployeeID;
    final userId = _currentUserId();
    final time = DateFormat('yyyy-MM-dd').format(_date);

    final result = _isEditing
        ? await _service.updateHistory(
            khoCode: widget.khoCode,
            historyAid: widget.editing!.historyAid,
            dataWareHouseAid: widget.dataWareHouseAid,
            qty: signedQty,
            employeeId: employeeId,
            ncc: _selectedCustomer?.maKh,
            remark: _remarkController.text.trim(),
            time: time,
            noLot: _hasNoLot ? _noLotController.text.trim() : null,
            updateUser: userId,
          )
        : await _service.addHistory(
            khoCode: widget.khoCode,
            dataWareHouseAid: widget.dataWareHouseAid,
            qty: signedQty,
            employeeId: employeeId,
            ncc: _selectedCustomer?.maKh,
            remark: _remarkController.text.trim(),
            time: time,
            noLot: _hasNoLot ? _noLotController.text.trim() : null,
            createUser: userId,
          );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result["isSuccess"] == true) {
      Navigator.pop(context, true);
    } else {
      _showSnackBar(
        result["message"]?.toString() ??
            'Lưu thất bại (mã lỗi: ${result["statusCode"]})',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Sửa lịch sử nhập/xuất'
                      : 'Thêm lịch sử nhập/xuất',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Nhập')),
                    ButtonSegment(value: true, label: Text('Xuất')),
                  ],
                  selected: {_isExport},
                  onSelectionChanged: (selection) =>
                      setState(() => _isExport = selection.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: _kPrimaryColor.withOpacity(0.15),
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
                    if (v == null || v.trim().isEmpty) return 'Bắt buộc nhập';
                    final parsed = double.tryParse(
                      v.trim().replaceAll(',', '.'),
                    );
                    if (parsed == null || parsed <= 0)
                      return 'Số lượng không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(_date)),
                        const Icon(Icons.calendar_today_outlined, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SearchableDropdownField<Employee>(
                  label: 'Nhân viên thực hiện',
                  value: _selectedEmployee,
                  items: _employees,
                  labelOf: (e) => e.NameEmployee,
                  enabled: !_isLoadingLookups,
                  onChanged: (v) => setState(() => _selectedEmployee = v),
                  isPinned: PinnedLookupStore.isEmployeePinned(
                    _selectedEmployee,
                  ),
                  onTogglePin: () => setState(
                    () =>
                        PinnedLookupStore.toggleEmployeePin(_selectedEmployee),
                  ),
                ),
                const SizedBox(height: 14),
                SearchableDropdownField<Customer>(
                  label: 'NCC / Khách hàng',
                  value: _selectedCustomer,
                  items: _customers,
                  labelOf: (c) => '${c.maKh} - ${c.tenKh}',
                  enabled: !_isLoadingLookups,
                  onChanged: (v) => setState(() => _selectedCustomer = v),
                  isPinned: PinnedLookupStore.isCustomerPinned(
                    _selectedCustomer,
                  ),
                  onTogglePin: () => setState(
                    () =>
                        PinnedLookupStore.toggleCustomerPin(_selectedCustomer),
                  ),
                ),
                if (_hasNoLot) ...[
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
                  controller: _remarkController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSubmit,
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
                        : Text(
                            _isEditing ? 'LƯU THAY ĐỔI' : 'THÊM MỚI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
