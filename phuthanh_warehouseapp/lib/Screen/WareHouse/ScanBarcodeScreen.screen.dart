import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class ScanScreen extends StatefulWidget {
  final bool isUpdate;
  const ScanScreen({super.key, required this.isUpdate});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      final roles = AppState.instance.get("role");
      if (widget.isUpdate) {
        final DrawerItem item = AppState.instance.get("itemDrawer");

        // ================= PRODUCT =================
        if (item.wareHouseCategory == 0) {
          final product = await infoService.findProduct(code);

          if (product["isSuccess"]) {
            _showToast("✅ Đã tìm thấy sản phẩm $code");

            navigationHelper
                .pushReplacement(
                  context,
                  ProductDetailScreen(
                    item: product["body"],
                    readOnly: !roles,
                    isUpDate: roles,
                  ),
                )
                .then((_) => isLocked = false);
            return;
          }
          if (product["statusCode"] == 403 ||
              product["statusCode"] == 401 ||
              product["statusCode"] == 0) {
            navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
            return;
          }
        } else {
          // ================= WAREHOUSE =================
          final scannedItem = await warehouseservice.getWarehouseById(
            item.wareHouseTable ?? '',
            code,
          );

          if (scannedItem["isSuccess"]) {
            _showToast("✅ Tìm thấy dữ liệu kho $code");
            navigationHelper
                .pushReplacement(
                  context,
                  WarehouseDetailScreen(
                    item: scannedItem["body"],
                    isUpDate: roles,
                    isCreateHistory: roles,
                    isReadOnlyHistory: !roles,
                  ),
                )
                .then((_) => isLocked = false);

            return;
          }
          if (scannedItem["statusCode"] == 403 ||
              scannedItem["statusCode"] == 401 ||
              scannedItem["statusCode"] == 0) {
            navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
            return;
          }

          // ================= CREATE NEW =================
          final product = await infoService.findProduct(code);
          if (product["isSuccess"]) {
            final newItem = WareHouse(
              productAID: product["body"].productAID,
              productID: product["body"].productID,
              idKeeton: product["body"].idKeeton,
              countryID: product["body"].countryID,
              idIndustrial: product["body"].idIndustrial,
              idPartNo: product["body"].idPartNo,
              idReplacedPartNo: product["body"].idReplacedPartNo,
              img1: product["body"].img1,
              img2: product["body"].img2,
              img3: product["body"].img3,
              lastTime: product["body"].lastTime,
              manufacturerID: product["body"].manufacturerID,
              nameProduct: product["body"].nameProduct,
              parameter: product["body"].parameter,
              supplierID: product["body"].supplierID,
              unitID: product["body"].unitID,
              remarkOfDataWarehouse: "",
              qty: 0,
            );
            if (product["statusCode"] == 403 ||
                product["statusCode"] == 401 ||
                product["statusCode"] == 0) {
              navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
              return;
            }

            _showToast("⚠ Không có trong kho — tạo mới");

            navigationHelper
                .pushReplacement(
                  context,
                  WarehouseDetailScreen(
                    item: newItem,
                    isCreate: roles,
                    isCreateHistory: roles,
                    readOnly: roles,
                    isReadOnlyHistory: !roles,
                  ),
                )
                .then((_) => isLocked = false);

            return;
          }
          // ================= NOT FOUND =================
          _showToast("❌ Không tìm thấy mã: $code");

          setState(() {
            isProcessing = false;
            scannedCode = '';
            _manualController.clear();
          });

          isLocked = false; // 🔓 cho quét lại
        }
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
