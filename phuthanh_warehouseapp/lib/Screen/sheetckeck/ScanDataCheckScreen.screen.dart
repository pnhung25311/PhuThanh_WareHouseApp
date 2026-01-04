import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phuthanh_warehouseapp/Screen/datacheck/DataCheckDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/DataCheck.model.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Sheet.model.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/service/SheetService.service.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class ScanDataCheckScreen extends StatefulWidget {
  const ScanDataCheckScreen({super.key});

  @override
  State<ScanDataCheckScreen> createState() => _ScanDataCheckScreenState();
}

class _ScanDataCheckScreenState extends State<ScanDataCheckScreen> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
  );

  final TextEditingController _manualController = TextEditingController();

  bool enableScanWindow = true;
  bool isProcessing = false;
  Set<String> scannedCodes = {};
  InfoService infoService = InfoService();
  SheetService sheetService = SheetService();
  Warehouseservice warehouseservice = Warehouseservice();
        NavigationHelper navigationHelper = NavigationHelper();


  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      checkInit();
    });
  }

  // ================= HANDLE BARCODE =================
  void _handleBarcode(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    if (isProcessing) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue ?? barcode.displayValue ?? '';

    if (code.isEmpty) return;

    _processCode(code);
  }

  // ================= PROCESS CODE =================
  Future<void> _processCode(String code) async {
    if (isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final DrawerItem drawerItem = AppState.instance.get("itemDrawer");
      // final sheetAID = AppState.instance.get("SheetAID");
      final Sheet? itemSheet = AppState.instance.get("Sheet");

      // 1️⃣ CHECK TRONG DATA CHECK (UPDATE)
      final scannedItemCheck = await sheetService.getDataCheckById(
        drawerItem.wareHouseDataCheck.toString(),
        jsonEncode({
          "SheetAID": itemSheet?.sheetAID.toString(),
          "ProductID": code.trim(),
        }),
      );

      if (scannedItemCheck != null) {
        final dataCheck = DataCheck(
          checkAID: scannedItemCheck.checkAID,
          sheetAID: scannedItemCheck.sheetAID,
          productAID: scannedItemCheck.productAID,
          productID: scannedItemCheck.productID,
          idPartNo: scannedItemCheck.idPartNo,
          nameProduct: scannedItemCheck.nameProduct,
          nameCountry: scannedItemCheck.nameCountry,
          nameSupplier: scannedItemCheck.nameSupplier,
          nameUnit: scannedItemCheck.nameUnit,
          qtyWareHouse: scannedItemCheck.qtyWareHouse,
          qtyCheck: scannedItemCheck.qtyCheck,
          qtyDifferent: scannedItemCheck.qtyDifferent,
          remark: "",
          lastTime: DateTime.now(),
        );

        final result = await navigationHelper.push(
          context,
          DataCheckDetailScreen(item: dataCheck, isUpdate: true),
        );

        if (result == true) {
          navigationHelper.pop(context, true); // 🔥 trả về HomeCheckListScreen
        }
        return;
      }

      // 2️⃣ KHÔNG CÓ → CHECK TRONG KHO (CREATE)
      final scannedItem = await warehouseservice.getWarehouseById(
        drawerItem.wareHouseTable.toString(),
        code.trim(),
      );

      if (scannedItem != null) {
        final dataCheck = DataCheck(
          checkAID: 0,
          sheetAID: AppState.instance.get("SheetAID"),
          productAID: scannedItem.productAID,
          productID: scannedItem.productID,
          idPartNo: scannedItem.idPartNo,
          nameProduct: scannedItem.nameProduct,
          nameCountry: scannedItem.countryName,
          nameSupplier: scannedItem.supplierName,
          nameUnit: scannedItem.unitName,
          qtyWareHouse: scannedItem.qty,
          qtyCheck: 0,
          qtyDifferent: 0,
          remark: "",
          lastTime: DateTime.now(),
        );

        final result = await navigationHelper.push(
          context,
          DataCheckDetailScreen(item: dataCheck, isCreate: true),
        );
        if (result == true) {
          navigationHelper.pop(context, true); // 🔥 trả về HomeCheckListScreen
        }
        // _showToast("Tìm thấy mã trong kho: $code");
        return;
      }

      final scannedProductItem = await infoService.findProduct(code);
      if (scannedProductItem != null) {
        final dataCheck = DataCheck(
          checkAID: 0,
          sheetAID: AppState.instance.get("SheetAID"),
          productAID: scannedProductItem.productAID,
          productID: scannedProductItem.productID,
          idPartNo: scannedProductItem.idPartNo,
          nameProduct: scannedProductItem.nameProduct,
          nameCountry: scannedProductItem.countryName,
          nameSupplier: scannedProductItem.supplierName,
          nameUnit: scannedProductItem.unitName,
          qtyWareHouse: 0,
          qtyCheck: 0,
          qtyDifferent: 0,
          remark: "",
          lastTime: DateTime.now(),
        );

        final result = await navigationHelper.push(
          context,
          DataCheckDetailScreen(item: dataCheck, isCreate: true),
        );
        // _showToast("Tìm thấy mã trong kho: $code");

        if (result == true) {
          navigationHelper.pop(context, true); // 🔥 trả về HomeCheckListScreen
        }
        return;
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
      _showToast("❌ Lỗi khi xử lý dữ liệu");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  // ================= TOAST =================
  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void checkInit() {
    final Sheet? itemSheet = AppState.instance.get("Sheet");

    if (itemSheet == null) {
      _showToast("❌ Chưa chọn phiếu");
      navigationHelper.pop(context);
      return;
    }
    if (itemSheet.status) {
      _showToast("❌ Phiếu đã hoàn thành");
      navigationHelper.pop(context);
      return;
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

          // INPUT BARCODE THỦ CÔNG
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: CustomTextFieldIcon(
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
          ),
        ],
      ),
    );
  }
}
