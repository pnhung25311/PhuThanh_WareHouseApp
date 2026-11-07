import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/ScannedCode.helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phuthanh_warehouseapp/components/ScanFromImageButton.custom.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/DmvtDetailScreen.screen.dart';

/// Quét mã vật tư (`ma_vt`) trong toàn bộ danh mục — quét/nhập xong nhảy
/// thẳng vào màn chi tiết của đúng vật tư đó. So khớp trên danh sách vật tư
/// đã tải sẵn (không gọi thêm API).
class ScanMaterialScreen extends StatefulWidget {
  final List<Dmvt> items;

  const ScanMaterialScreen({super.key, required this.items});

  @override
  State<ScanMaterialScreen> createState() => _ScanMaterialScreenState();
}

class _ScanMaterialScreenState extends State<ScanMaterialScreen> {
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

  Dmvt? _findItem(String code) {
    final normalized = code.trim().toUpperCase();
    for (final item in widget.items) {
      if (item.maVt.trim().toUpperCase() == normalized) return item;
    }
    return null;
  }

  Future<void> _processCode(String code) async {
    // QR dạng `MaVT-MaLot`: màn này chỉ tra vật tư nên bỏ phần mã lô.
    final item = resolveScannedCode<Dmvt>(code, _findItem)?.item;

    if (item == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy vật tư với mã "$code"'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      _isLocked = false;
      return;
    }

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => DmvtDetailScreen(item: item)),
    );
    if (changed == true) _changed = true;

    _isLocked = false;
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
        title: const Text(
          'Quét mã vật tư',
          style: TextStyle(color: Colors.white),
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
