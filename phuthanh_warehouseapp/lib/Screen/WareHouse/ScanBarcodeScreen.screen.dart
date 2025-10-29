import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  final bool isUpdate;
  const ScanScreen({super.key, required this.isUpdate});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String scannedCode = '';
  bool isProcessing = false; // ⚡ cờ để chỉ xử lý 1 barcode duy nhất

  void _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (isProcessing) return; // nếu đang xử lý -> thoát
    if (barcodeCapture.barcodes.isEmpty) return;

    final barcode = barcodeCapture.barcodes.first;
    final code = barcode.rawValue ?? 'Không có giá trị';

    if (scannedCode != code) {
      setState(() {
        scannedCode = code;
        isProcessing = true; // bắt đầu xử lý
      });

      try {
        final scannedItem = await Warehouseservice.getWarehouseById(code);
        if (scannedItem != null) {
          if (widget.isUpdate) {
            // delay 100ms để tránh lỗi push nhiều lần
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => WarehouseDetailScreen(
                    item: scannedItem,
                    isCreateHistory: true,
                    isReadOnlyHistory: false,
                  ),
                ),
              );
            });
          } else {
            Navigator.pop(context, scannedCode);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy sản phẩm')),
          );
          setState(() => isProcessing = false); // cho phép quét lại
        }
      } catch (e) {
        print('❌ Lỗi khi lấy sản phẩm: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi khi lấy sản phẩm')));
        setState(() => isProcessing = false); // cho phép quét lại
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kích thước khung quét
    final double rectWidth = 350;
    final double rectHeight = 300;

    return Scaffold(
      appBar: AppBar(title: const Text('Quét Barcode/QR')),
      body: Stack(
        children: [
          // Camera
          MobileScanner(onDetect: _handleBarcode),

          // Overlay mờ xung quanh khung scan
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;

              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: (height - rectHeight) / 2,
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: (height - rectHeight) / 2,
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                  Positioned(
                    top: (height - rectHeight) / 2,
                    left: 0,
                    width: (width - rectWidth) / 2,
                    height: rectHeight,
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                  Positioned(
                    top: (height - rectHeight) / 2,
                    right: 0,
                    width: (width - rectWidth) / 2,
                    height: rectHeight,
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                ],
              );
            },
          ),

          // Khung scan chữ nhật + laser đỏ cố định
          Center(
            child: Stack(
              children: [
                // Khung scan
                Container(
                  width: rectWidth,
                  height: rectHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow, width: 1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                // Laser đỏ cố định
                Positioned(
                  top: rectHeight / 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: rectWidth,
                    height: 2,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // Hiển thị kết quả quét
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.black45,
                child: Text(
                  'Kết quả: $scannedCode',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
