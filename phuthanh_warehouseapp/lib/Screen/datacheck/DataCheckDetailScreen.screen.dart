import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/formatters/DotToMinusFormatte.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
// import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
// import 'package:phuthanh_warehouseapp/components/utils/CustomDatePicker.custom.dart';
import 'package:phuthanh_warehouseapp/model/info/DataCheck.model.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/service/SheetService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class DataCheckDetailScreen extends StatefulWidget {
  final DataCheck item;
  final bool readOnly;
  final bool isUpdate;
  final bool isCreate;

  const DataCheckDetailScreen({
    super.key,
    required this.item,
    this.readOnly = false,
    this.isUpdate = false,
    this.isCreate = false,
  });

  @override
  State<DataCheckDetailScreen> createState() => _DataCheckDetailScreenState();
}

class _DataCheckDetailScreenState extends State<DataCheckDetailScreen> {
  // ===== CONTROLLERS =====
  final TextEditingController productIDController = TextEditingController();
  final TextEditingController partNoController = TextEditingController();
  final TextEditingController nameProductController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  final TextEditingController qtyWarehouseController = TextEditingController();
  final TextEditingController qtyCheckController = TextEditingController();
  final TextEditingController qtyDifferentController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  SheetService sheetService = SheetService();
  DateTime? selectedDate;
  Formatdatehelper formatdatehelper = Formatdatehelper();
  NavigationHelper navigationHelper = NavigationHelper();
  MySharedPreferences mySharedPreferences = MySharedPreferences();

  @override
  void initState() {
    super.initState();

    /// ===== GÁN DỮ LIỆU TỪ MODEL =====
    productIDController.text = widget.item.productID ?? '';
    partNoController.text = widget.item.idPartNo ?? '';
    nameProductController.text = widget.item.nameProduct ?? '';
    countryController.text = widget.item.nameCountry ?? '';
    supplierController.text = widget.item.nameSupplier ?? '';
    unitController.text = widget.item.nameUnit ?? '';

    qtyWarehouseController.text = widget.item.qtyWareHouse?.toString() ?? '';
    qtyCheckController.text = widget.item.qtyCheck?.toString() ?? '';
    qtyDifferentController.text = widget.item.qtyDifferent?.toString() ?? '';

    remarkController.text = widget.item.remark ?? '';
    selectedDate = widget.item.lastTime;

    qtyCheckController.addListener(() {
      final double qtyWarehouse =
          double.tryParse(qtyWarehouseController.text) ?? 0;
      final double qtyCheck = double.tryParse(qtyCheckController.text) ?? 0;
      final double qtyDifferent = qtyCheck - qtyWarehouse;

      qtyDifferentController.text = qtyDifferent.toString();
    });
  }

  Future<String?> getFullname() async {
    Map<String, dynamic>? account = await mySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["UserName"];
    return fullname;
  }

  void _onSave() async {
    try {
      final DrawerItem item = AppState.instance.get("itemDrawer");
      String? fullName = await getFullname();
      if (widget.isCreate) {
        final response = await sheetService.AddSheetWh(
          item.wareHouseCheckDataBase.toString(),
          jsonEncode({
            "SheetAID": widget.item.sheetAID,
            "ProductAID": widget.item.productAID,
            "QtyWareHouse": qtyWarehouseController.text.trim(),
            "QtyCheck": qtyCheckController.text.trim(),
            "QtyDifferent": qtyDifferentController.text.trim(),
            "LastUser": await fullName.toString().trim(),
            "Remark": remarkController.text.trim(),
            "LastTime": formatdatehelper.formatYMDHMS(DateTime.now()),
          }),
        );
        if (response["isSuccess"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm sản phẩm thành công'),
              duration: const Duration(milliseconds: 500),
            ),
          );
          // NavigationHelper.pushAndRemoveUntil(context, HomeCheckListScreen());
          navigationHelper.pop(context, true);
        }
      }

      if (widget.isUpdate) {
        final response = await sheetService.upDateDataCheck(
          item.wareHouseCheckDataBase.toString(),
          widget.item.checkAID.toString(),
          jsonEncode({
            "QtyCheck": qtyCheckController.text.trim(),
            "QtyDifferent": qtyDifferentController.text.trim(),
            "Remark": remarkController.text.trim(),
            "LastUser": await fullName.toString().trim(),
            "LastTime": formatdatehelper.formatYMDHMS(DateTime.now()),
          }),
        );
        if (response["isSuccess"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật sản phẩm thành công'),
              duration: const Duration(milliseconds: 500),
            ),
          );
          navigationHelper.pop(context, true);
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Lỗi kết nối: $e'),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }

    /// TODO: gọi API lưu dữ liệu tại đây
    /// await DataCheckService.update(updatedItem);
  }

  @override
  void dispose() {
    productIDController.dispose();
    partNoController.dispose();
    nameProductController.dispose();
    countryController.dispose();
    supplierController.dispose();
    unitController.dispose();
    qtyWarehouseController.dispose();
    qtyCheckController.dispose();
    qtyDifferentController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết kiểm kê"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== THÔNG TIN SẢN PHẨM =====
            CustomTextField(
              label: "Mã sản phẩm",
              controller: productIDController,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            CustomTextField(
              label: "Danh điểm (Part No)",
              controller: partNoController,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            CustomTextField(
              label: "Tên sản phẩm",
              controller: nameProductController,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            CustomTextField(
              label: "Quốc gia",
              controller: countryController,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            CustomTextField(
              label: "Nhà cung cấp",
              controller: supplierController,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            CustomTextField(
              label: "Đơn vị tính",
              controller: unitController,
              readOnly: true,
            ),

            const Divider(height: 30),

            /// ===== SỐ LƯỢNG =====
            CustomTextField(
              label: "Số lượng kho",
              controller: qtyWarehouseController,
              keyboardType: TextInputType.number,
              readOnly: true,
              inputFormatters: [DotToMinusFormatter()],
            ),
            const SizedBox(height: 10),

            CustomTextField(
              label: "Số lượng kiểm",
              controller: qtyCheckController,
              keyboardType: TextInputType.number,
              readOnly: widget.readOnly,
              inputFormatters: [DotToMinusFormatter()],
            ),
            const SizedBox(height: 10),

            CustomTextField(
              label: "Chênh lệch",
              controller: qtyDifferentController,
              keyboardType: TextInputType.number,
              readOnly: true,
              inputFormatters: [DotToMinusFormatter()],
            ),

            const Divider(height: 30),

            /// ===== THỜI GIAN + GHI CHÚ =====
            // CustomDateTimePicker(
            //   label: "Thời gian kiểm",
            //   initialDate: selectedDate ?? DateTime.now(),
            //   readOnly: widget.readOnly,
            //   onChanged: (value) {
            //     setState(() {
            //       selectedDate = value;
            //     });
            //   },
            // ),
            // const SizedBox(height: 10),
            CustomTextField(
              label: "Ghi chú",
              controller: remarkController,
              readOnly: widget.readOnly,
              // maxLines: 3,
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Quay lại"),
                ),
                const SizedBox(width: 16),

                if (!widget.readOnly)
                  ElevatedButton.icon(
                    onPressed: _onSave,
                    icon: const Icon(Icons.save),
                    label: const Text("Lưu"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
