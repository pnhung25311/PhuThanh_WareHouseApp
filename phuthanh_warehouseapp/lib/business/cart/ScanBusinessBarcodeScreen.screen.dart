import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/cart/CartDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/WareHouseService.service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanBusinessCartScreen extends StatefulWidget {
  final bool isCart;
  const ScanBusinessCartScreen({super.key, required this.isCart});

  @override
  State<ScanBusinessCartScreen> createState() => _ScanBusinessCartScreenState();
}

class _ScanBusinessCartScreenState extends State<ScanBusinessCartScreen> {
  final MobileScannerController _controller = MobileScannerController();

  final TextEditingController _manualController = TextEditingController();

  bool enableScanWindow = true;
  bool isProcessing = false;
  bool isLocked = false; // 🔒 KHÓA QUÉT

  String scannedCode = '';

  final InfoService infoService = InfoService();
  final Warehouseservice warehouseservice = Warehouseservice();
  final NavigationHelper navigationHelper = NavigationHelper();

  @override
  void initState() {
    super.initState();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ================= HANDLE CAMERA SCAN =================
  void _handleBarcode(BarcodeCapture capture) {
    if (isLocked) return;
    if (capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue?.trim() ?? '';
    if (code.isEmpty) return;

    isLocked = true; // 🔒 khóa ngay
    _processCode(code);
  }

  // ================= CORE LOGIC =================
  Future<void> _processCode(String code) async {
    if (isProcessing) return;

    setState(() {
      scannedCode = code;
      isProcessing = true;
    });

    try {
      if (widget.isCart) {
        Product pro = Product.empty();
        final proBroken = await infoService.findProduct(code.toString().trim());
        pro = proBroken["body"];
        Cart cart = Cart(
          cartAID: 0,
          productID: pro.productID,
          idPartNo: pro.idPartNo,
          nameProduct: pro.nameProduct,
        );
        navigationHelper.pushReplacement(
          context,
          CartDetailScreen(item: cart, typeSave: "CREATE"),
        );
      } else {
        navigationHelper.pop(context, scannedCode);
      }
    } catch (e) {
      _showToast("❌ Lỗi xử lý mã");
      isLocked = false;
      setState(() => isProcessing = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final rectWidth = 350.0;
    final rectHeight = 300.0;

    return Scaffold(
      body: Stack(
        children: [
          // CAMERA
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              final left = (screenWidth - rectWidth) / 2;
              final top = (screenHeight - rectHeight) / 2;

              return MobileScanner(
                controller: _controller,
                onDetect: _handleBarcode,
                fit: BoxFit.cover, // full màn hình, cố định
                scanWindow: enableScanWindow
                    ? Rect.fromLTWH(left, top, rectWidth, rectHeight)
                    : null,
              );
            },
          ),

          // OVERLAY (CHỈ hiện khi bật chế độ quét khung)
          if (enableScanWindow)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

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

          // KHUNG SCAN (CHỈ hiện khi bật chế độ quét khung)
          if (1 == 1)
            // Khung scan mặc định full màn hình (bo góc)
            Center(
              child: Container(
                width: enableScanWindow
                    ? rectWidth
                    : MediaQuery.of(context).size.width,
                height: enableScanWindow
                    ? rectHeight
                    : MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow, width: 2),
                  borderRadius: BorderRadius.circular(
                    enableScanWindow ? 12 : 0,
                  ), // bo nhỏ nếu full màn hình
                ),
              ),
            ),

          // LASER LINE
          if (1 == 1)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: rectWidth,
                  height: 2,
                  color: Colors.red,
                ),
              ),
            ),

          // FLASH BUTTON
          Positioned(
            top: 40,
            right: 20,
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, value, child) {
                final state = value.torchState;
                return IconButton(
                  icon: Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                    color: state == TorchState.on
                        ? Colors.yellow
                        : Colors.white,
                    size: 30,
                  ),
                  onPressed: () => _controller.toggleTorch(),
                );
              },
            ),
          ),

          // NÚT BẬT/TẮT VÙNG SCAN
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(
                enableScanWindow
                    ? Icons.center_focus_strong
                    : Icons.center_focus_weak,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  enableScanWindow = !enableScanWindow;
                });
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TEXTFIELD
                CustomTextFieldIcon(
                  label: '',
                  controller: _manualController,
                  hintText: 'Nhập mã barcode thủ công',
                  suffixIcon: Icons.check_circle,
                  onSuffixIconPressed: () {
                    final code = _manualController.text.trim();
                    if (code.isNotEmpty) _processCode(code);
                  },
                  onSubmitted: (value) {
                    final code = value.trim();
                    if (code.isNotEmpty) _processCode(code);
                  },
                  backgroundColor: Colors.white,
                  borderColor: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
