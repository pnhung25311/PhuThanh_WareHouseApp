import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/ScannedCode.helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phuthanh_warehouseapp/components/ScanFromImageButton.custom.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Warehouse.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/WarehouseInventoryItem.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/MaterialHistoryScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/WarehouseTransferScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/WarehouseService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/store/PinnedLookupStore.store.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Quét mã vật tư (`ma_vt`) trong 1 kho — quét/nhập xong sẽ hiện thông tin
/// vật tư (tồn kho hiện có) và cho phép Nhập/Xuất, Điều chuyển, hoặc Chỉnh
/// sửa thông tin vật tư ngay. So khớp trên danh sách tồn kho đã tải sẵn của
/// kho đang xem (không gọi thêm API), vì `ma_vt` chỉ có ý nghĩa trong phạm
/// vi 1 kho cụ thể ở đây.
class ScanInventoryScreen extends StatefulWidget {
  final Warehouse warehouse;
  final List<WarehouseInventoryItem> items;

  const ScanInventoryScreen({
    super.key,
    required this.warehouse,
    required this.items,
  });

  @override
  State<ScanInventoryScreen> createState() => _ScanInventoryScreenState();
}

class _ScanInventoryScreenState extends State<ScanInventoryScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();

  bool _isLocked = false;
  bool _changed = false;

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isLocked) return;
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue?.trim() ?? '';
    if (code.isEmpty) return;

    _isLocked = true;
    _processCode(code);
  }

  WarehouseInventoryItem? _findItem(String code) {
    final normalized = code.trim().toUpperCase();
    for (final item in widget.items) {
      if (item.material.maVt.trim().toUpperCase() == normalized) return item;
    }
    return null;
  }

  Future<void> _processCode(String code) async {
    // QR dạng `MaVT-MaLot` (vd SC00001234-0102T3DL).
    final scanned = resolveScannedCode<WarehouseInventoryItem>(code, _findItem);
    final item = scanned?.item;

    if (item == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không tìm thấy vật tư với mã "$code" trong ${widget.warehouse.tenKho}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      _isLocked = false;
      return;
    }

    await _showResultSheet(item, scanned!.noLot);
    _isLocked = false;
  }

  Future<void> _showResultSheet(
    WarehouseInventoryItem item,
    String? noLot,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ScanResultSheet(item: item, noLot: noLot),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case 'history':
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => MaterialHistoryScreen(
              warehouse: widget.warehouse,
              item: item,
              initialNoLot: noLot,
            ),
          ),
        );
        if (changed == true) _changed = true;
        break;
      case 'transfer':
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => WarehouseTransferScreen(
              sourceWarehouse: widget.warehouse,
              initialItem: item,
              initialNoLot: noLot,
            ),
          ),
        );
        if (changed == true) _changed = true;
        break;
      case 'edit':
        final saved = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) =>
              EditLocationSheet(warehouse: widget.warehouse, item: item),
        );
        if (saved == true) _changed = true;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _changed),
        ),
        title: Text(
          'Quét mã — ${widget.warehouse.tenKho}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          ScanFromImageButton(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final isOn = value.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: isOn ? Colors.yellow : Colors.white,
                ),
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),
          Center(
            child: Container(
              width: 260,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Đưa mã vật tư vào khung để quét',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _manualController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Hoặc nhập mã vật tư thủ công...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final code = _manualController.text.trim();
                      if (code.isNotEmpty) _processCode(code);
                    },
                  ),
                ),
                onSubmitted: (value) {
                  final code = value.trim();
                  if (code.isNotEmpty) _processCode(code);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanResultSheet extends StatelessWidget {
  final WarehouseInventoryItem item;
  final String? noLot;

  const _ScanResultSheet({required this.item, this.noLot});

  String _formatQty(double value) {
    if (value == value.floor()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final m = item.material;
    final qtyColor = item.qty > 0 ? _kPrimaryColor : Colors.redAccent;
    final location = item.location?.trim() ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (noLot ?? '').isEmpty
                            ? m.maVt
                            : '${m.maVt} • Lô: $noLot',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.tenVt.isNotEmpty ? m.tenVt : '(Chưa có tên)',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
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
                      _formatQty(item.qty),
                      style: TextStyle(
                        fontSize: 22,
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
            if (location.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, 'transfer'),
                    icon: const Icon(Icons.compare_arrows_rounded),
                    label: const Text('Điều chuyển'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kPrimaryColor,
                      side: const BorderSide(color: _kPrimaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, 'history'),
                    icon: const Icon(
                      Icons.swap_vert_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Nhập / Xuất',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, 'edit'),
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Sửa vị trí'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form sửa `Vị trí`/`Ghi chú` của 1 dòng tồn kho — `PUT /api/ton-kho/{kho}/{id}`.
/// Không cho sửa số tồn ở đây: API set thẳng `qty` nên luôn gửi lại giá trị
/// hiện tại để tránh làm lệch số tồn thật (số tồn chỉ nên đổi qua lịch sử).
class EditLocationSheet extends StatefulWidget {
  final Warehouse warehouse;
  final WarehouseInventoryItem item;

  const EditLocationSheet({required this.warehouse, required this.item});

  @override
  State<EditLocationSheet> createState() => EditLocationSheetState();
}

class EditLocationSheetState extends State<EditLocationSheet> {
  late final TextEditingController _locationController = TextEditingController(
    text:
        PinnedLookupStore.pinnedLocation ?? widget.item.location?.trim() ?? '',
  );
  late final TextEditingController _remarkController = TextEditingController(
    text: widget.item.remark ?? '',
  );

  bool _isSaving = false;

  @override
  void dispose() {
    _locationController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  int? _currentUserId() {
    final account = AppState.instance.get("account") as Account?;
    return account?.AccountID;
  }

  Future<void> _save() async {
    final userId = _currentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không xác định được người dùng hiện tại'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await WarehouseService().capNhatTonKho(
      khoCode: widget.warehouse.khoCode,
      dataWareHouseAid: widget.item.dataWareHouseAid,
      qty: widget.item.qty,
      location: _locationController.text.trim(),
      remark: _remarkController.text.trim(),
      updateUser: userId,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result["isSuccess"] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ?? 'Cập nhật vị trí thất bại',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.item.material;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sửa vị trí',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${m.maVt} — ${m.tenVt.isNotEmpty ? m.tenVt : "(Chưa có tên)"}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Vị trí',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Builder(
                      builder: (context) {
                        final isPinned = PinnedLookupStore.isLocationPinned(
                          _locationController.text,
                        );
                        return IconButton(
                          tooltip: isPinned
                              ? 'Bỏ ghim'
                              : 'Ghim vị trí này (dùng lại cho lần sau)',
                          onPressed: () => setState(
                            () => PinnedLookupStore.toggleLocationPin(
                              _locationController.text,
                            ),
                          ),
                          icon: Icon(
                            isPinned
                                ? Icons.push_pin_rounded
                                : Icons.push_pin_outlined,
                            color: isPinned
                                ? _kPrimaryColor
                                : Colors.grey.shade500,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
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
