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
// import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

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

  void _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (isProcessing) return;
    if (barcodeCapture.barcodes.isEmpty) return;

    final barcode = barcodeCapture.barcodes.first;
    final code = barcode.rawValue ?? '';

    if (code.isEmpty) return;
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
            NavigationHelper.pushReplacement(
              context,
              ProductDetailScreen(
                item: product,
                isCreateHistory: true,
                isCreate: true,
                readOnly: true,
                isReadOnlyHistory: false,
              ),
            );
          }
        } else {
          final scannedItem = await Warehouseservice.getWarehouseById(code);
          if (scannedItem != null) {
            // ✅ Tìm thấy sản phẩm -> nhảy trang
            print("object=========================================");
            Future.delayed(const Duration(milliseconds: 100), () {
              NavigationHelper.pushReplacement(
                context,
                WarehouseDetailScreen(
                  item: scannedItem,
                  isCreateHistory: true,
                  isReadOnlyHistory: false,
                ),
              );
            });
          } else {
            // ❌ Không tìm thấy sản phẩm -> hỏi có muốn thêm không
            final product = await InfoService.findProduct(code);
            print("========================================");
            print(product);
            if (product != null) {
              final dataWareHouseAID = await CodeHelper.generateCodeAID("WH");

              final item = WareHouse(
                dataWareHouseAID: dataWareHouseAID,
                productAID: product.productAID,
                productID: product.productID,
                idKeeton: product.idKeeton,
                // idBill: product.idBill,
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
                // qtyExpected: product.qtyExpected,
                supplierID: product.supplierID,
                unitID: product.unitID,
                remarkOfDataWarehouse: "",
                qty: 0,
              );
              print(item);
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
            } else {
              _reloadScanPage();
            }
            setState(() => isProcessing = false);
          }
        }
      } else {
        NavigationHelper.pop(context, scannedCode);
      }
    } catch (e) {
      print('❌ Lỗi khi lấy sản phẩm: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi khi lấy sản phẩm')));
      setState(() => isProcessing = false);
    }
  }

  // 🔹 Reload lại trang scan
  void _reloadScanPage() {
    setState(() {
      scannedCode = '';
      isProcessing = false;
      _manualController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double rectWidth = 350;
    final double rectHeight = 300;

    return Scaffold(
      appBar: AppBar(title: const Text('Quét hoặc nhập Barcode')),
      body: Stack(
        children: [
          // Camera
          MobileScanner(onDetect: _handleBarcode),

          // Overlay tối
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

          // Khung quét
          Center(
            child: Stack(
              children: [
                Container(
                  width: rectWidth,
                  height: rectHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow, width: 1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
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

          // Hiển thị kết quả + ô nhập barcode thủ công (dùng CustomTextFieldIcon)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 8,
                //   ),
                //   color: Colors.black45,
                //   child: Text(
                //     'Kết quả: ${scannedCode.isEmpty ? 'Chưa có' : scannedCode}',
                //     style: const TextStyle(color: Colors.white, fontSize: 18),
                //   ),
                // ),
                const SizedBox(height: 16),

                // 🔹 TextField nhập barcode thủ công
                CustomTextFieldIcon(
                  label: '',
                  controller: _manualController,
                  hintText: 'Nhập mã barcode thủ công',
                  suffixIcon: Icons.check_circle,
                  onSuffixIconPressed: () {
                    final code = _manualController.text.trim();
                    if (code.isNotEmpty) {
                      _processCode(code);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập mã barcode'),
                        ),
                      );
                    }
                  },
                  onSubmitted: (value) {
                    final code = value.trim();
                    if (code.isNotEmpty) {
                      _processCode(code);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập mã barcode'),
                        ),
                      );
                    }
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
