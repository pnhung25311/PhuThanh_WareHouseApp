import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/GenerateCodeAID.helper.dart';
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
  String scannedCode = '';
  bool isProcessing = false;
  final TextEditingController _manualController = TextEditingController();
  String _statusHome = "Product";

  // 🔥 Set để tránh quét trùng
  Set<String> scannedCodes = {};

  // MobileScannerController để bật/tắt flash
  final MobileScannerController _controller = MobileScannerController();

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (isProcessing) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue ?? '';

    if (code.isEmpty) return;

    if (scannedCodes.contains(code)) return;

    scannedCodes.add(code);
    _processCode(code);
  }

  Future<void> _processCode(String code) async {
    if (isProcessing) return;

    setState(() {
      scannedCode = code;
      isProcessing = true;
    });

    try {
      if (widget.isUpdate) {
        _statusHome = AppState.instance.get("StatusHome") ?? "Product";

        if (_statusHome == 'Product') {
          final product = await InfoService.findProduct(code);

          if (product != null) {
            _showToast("✅ Đã tìm thấy sản phẩm $code");

            NavigationHelper.pushReplacement(
              context,
              ProductDetailScreen(
                item: product,
                isCreateHistory: true,
                isCreate: false,
                readOnly: false,
                isUpDate: true,
                isReadOnlyHistory: false,
              ),
            );

            scannedCodes.clear();
            isProcessing = false;
            return;
          }
        }

        final scannedItem = await Warehouseservice.getWarehouseById(code);

        if (scannedItem != null) {
          _showToast("✅ Tìm thấy dữ liệu kho $code");

          NavigationHelper.pushReplacement(
            context,
            WarehouseDetailScreen(
              item: scannedItem,
              isCreateHistory: true,
              isReadOnlyHistory: false,
            ),
          );

          scannedCodes.clear();
          isProcessing = false;
          return;
        }

        final product = await InfoService.findProduct(code);

        if (product != null) {
          final dataWareHouseAID = await CodeHelper.generateCodeAID("WH");

          final item = WareHouse(
            dataWareHouseAID: dataWareHouseAID,
            productAID: product.productAID,
            productID: product.productID,
            idKeeton: product.idKeeton,
            countryID: product.countryID,
            idIndustrial: product.idIndustrial,
            idPartNo: product.idPartNo,
            idReplacedPartNo: product.idReplacedPartNo,
            img1: product.img1,
            img2: product.img2,
            img3: product.img3,
            lastTime: product.lastTime,
            manufacturerID: product.manufacturerID,
            nameProduct: product.nameProduct,
            parameter: product.parameter,
            supplierID: product.supplierID,
            unitID: product.unitID,
            remarkOfDataWarehouse: "",
            qty: 0,
          );

          _showToast("⚠ Không có trong kho — sẽ tạo mới");

          NavigationHelper.pushReplacement(
            context,
            WarehouseDetailScreen(
              item: item,
              isCreateHistory: true,
              isCreate: true,
              readOnly: true,
              isReadOnlyHistory: false,
            ),
          );

          scannedCodes.clear();
          isProcessing = false;
          return;
        }

        _showToast("❌ Không tìm thấy dữ liệu cho mã: $code");

        setState(() {
          isProcessing = false;
          scannedCodes.clear();
          scannedCode = "";
          _manualController.clear();
        });

        return;
      }

      NavigationHelper.pop(context, scannedCode);
    } catch (e) {
      _showToast("❌ Lỗi khi lấy dữ liệu");
      setState(() => isProcessing = false);
    }
  }

@override
Widget build(BuildContext context) {
  final double rectWidth = 350;
  final double rectHeight = 300;

  return Scaffold(
    body: Stack(
      children: [
        // Camera scanner
        MobileScanner(
          controller: _controller,
          onDetect: _handleBarcode,
        ),

        // Overlay tối xung quanh khung quét
        LayoutBuilder(builder: (context, constraints) {
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
        }),

        // Khung scan
        Center(
          child: Container(
            width: rectWidth,
            height: rectHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.yellow, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Nút flash
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
                  color: state == TorchState.on ? Colors.yellow : Colors.white,
                  size: 30,
                ),
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
        ),

        // Input barcode thủ công
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
