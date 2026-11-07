import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Nút chọn ảnh QR/barcode từ thư viện để giải mã — dùng khi không quét được
/// bằng camera (máy ảo, mã in mờ, ảnh có sẵn trong máy).
class ScanFromImageButton extends StatelessWidget {
  final MobileScannerController controller;
  final ValueChanged<BarcodeCapture> onDetect;
  final double iconSize;

  const ScanFromImageButton({
    super.key,
    required this.controller,
    required this.onDetect,
    this.iconSize = 24,
  });

  Future<void> _pickAndAnalyze(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    BarcodeCapture? capture;
    try {
      capture = await controller.analyzeImage(picked.path);
    } catch (e) {
      // iOS Simulator không hỗ trợ phân tích ảnh từ file (chỉ chạy trên máy thật).
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is UnsupportedError
                ? 'Máy ảo iOS không hỗ trợ quét từ ảnh, hãy thử trên máy thật'
                : 'Không đọc được ảnh: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!context.mounted) return;

    if (capture == null || capture.barcodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy mã QR/barcode trong ảnh'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    onDetect(capture);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Quét từ ảnh trong thư viện',
      icon: Icon(Icons.image_search, color: Colors.white, size: iconSize),
      onPressed: () => _pickAndAnalyze(context),
    );
  }
}
