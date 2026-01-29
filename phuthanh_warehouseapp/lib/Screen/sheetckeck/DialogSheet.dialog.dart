import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/service/SheetService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class DialogSheet extends StatefulWidget {
  @override
  _DialogSheetState createState() => _DialogSheetState();
}

class _DialogSheetState extends State<DialogSheet> {
  TextEditingController sheetIDController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  SheetService sheetService = SheetService();
  Formatdatehelper formatdatehelper = Formatdatehelper();
  NavigationHelper navigationHelper = NavigationHelper();

  Future<String?> getFullname() async {
    MySharedPreferences mySharedPreferences = MySharedPreferences();

    Map<String, dynamic>? account = await mySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["UserName"];
    return fullname;
  }

  void _createSheet() async {
    try {
      String? fullName = await getFullname();
      final DrawerItem item = AppState.instance.get("itemDrawer");
      final response = await sheetService.AddSheetWh(
        item.wareHouseSheetDataBase.toString(),
        jsonEncode({
          "SheetID": sheetIDController.text.trim(),
          "Remark": remarkController.text.trim(),
          "Status": 0,
          "LastUser": await fullName.toString().trim(),
          "LastTime": formatdatehelper.formatYMDHMS(DateTime.now()),
        }),
      );
      if (response["isSuccess"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm phiếu thành công'),
            duration: const Duration(milliseconds: 500),
          ),
        );
        // NavigationHelper.pushAndRemoveUntil(context, HomeCheckListScreen());
        navigationHelper.pop(context, true); // Thoát màn hình
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo Sheet mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              label: "Mã Phiếu:",
              controller: sheetIDController,
              hintText: "Nhập mã phiếu",
              // readOnly: widget.readOnly,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: "Ghi chú phiếu:",
              controller: remarkController,
              hintText: "Nhập ghi chú phiếu",
              // readOnly: widget.readOnly,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 212, 124, 118),
                  ),
                  onPressed: () {
                    navigationHelper.pop(context);
                  },
                  child: Text('Thoát'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 49, 216, 85),
                  ),
                  onPressed: () {
                    _createSheet();
                  },
                  child: Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
