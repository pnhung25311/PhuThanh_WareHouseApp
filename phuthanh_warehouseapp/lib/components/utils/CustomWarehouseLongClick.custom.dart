import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDialog.custom.dart';
import 'package:phuthanh_warehouseapp/helper/WarehouseHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/ViewImgWareHouse.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseHistoryScreen.screen.dart';
import 'package:flutter/services.dart'; // cần để dùng Clipboard
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';

class WarehouseLongClick {
  static Future<String?> getFullname() async {
    Map<String, dynamic>? account = await MySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["FullName"];
    return fullname;
  }

  static Future<void> showDialog(BuildContext context, WareHouse item) async {
    List<String> items = await Warehouseservice.getItemhWareHouse();
    // 🔹 Tạo Map từ danh sách
    Map<String, String> converted = {
      for (var it in items) it: convertWarehouseName(it),
    };
    final cleared = WareHouseHelper.clearFields(item, [
      'Qty_Expected',
      'locationID',
      'ID_Bill',
      'Qty',
      'Remark',
    ]);
    String? fullname = await getFullname();
    final clearedWithFullname = cleared.copyWith(fullName: fullname ?? '');
    // --- Single-select example (nếu cần) ---
    final chosenSingle = await GenericPickerDialog.showSingle<String>(
      context,
      items: items,
      title: 'Chọn 1 vị trí',
      labelBuilder: (key) => converted[key] ?? key,
      initialValue: null, // hoặc a key string nếu có
    );

    if (chosenSingle != null) {
      print(chosenSingle);
      print(item.toJson());
      final response = await Warehouseservice.addWarehouseRow(
        chosenSingle,
        clearedWithFullname.toJson(),
      );

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Nhân bản thành công')));
        Navigator.pop(context, true); // quay lại và báo màn trước refresh
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Lỗi nhân bản: ${response}')));
      }
      Navigator.pop(context);
    }
  }

  static String convertWarehouseName(String name) {
    return name.replaceFirst('WareHouse', 'Kho ');
  }

  static void show(BuildContext context, WareHouse item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              item.productID,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //XEM ẢNH
          ListTile(
            leading: const Icon(Icons.image, color: Colors.blue),
            title: const Text('Xem ảnh'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewImageScreen(item: item)),
              );
            },
          ),
          //SAO CHÉP
          ListTile(
            leading: const Icon(Icons.copy, color: Colors.green),
            title: const Text('Sao chép'),
            onTap: () async {
              // 1️⃣ Chuẩn bị nội dung copy
              String textToCopy =
                  '''Product ID: ${item.productID}\nMã keeton: ${item.idKeeton}\nMã công nghiệp: ${item.idIndustrial}\nDanh điểm: ${item.idPartNo}\nDanh điểm tương đương: ${item.idReplacedPartNo}\nTên sản phẩm: ${item.nameProduct}\nSố lượng: ${item.qty}\nSố lượng dự kiến: ${item.qtyExpected}\nMã số hóa đơn: ${item.idBill}\nThông số: ${item.parameter}\nGhi chú: ${item.remark}\n''';

              // 2️⃣ Copy vào clipboard
              await Clipboard.setData(ClipboardData(text: textToCopy));

              // 3️⃣ Thông báo người dùng
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Đã copy thông tin")),
              );

              // 4️⃣ Đóng modal
              Navigator.pop(context);
            },
          ),
          //XEM LỊCH SỬ NHẬP XUẤT
          ListTile(
            leading: const Icon(Icons.history, color: Colors.green),
            title: const Text('Xem lịch sử nhập/xuất'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WarehouseHistoryScreen(productID: item.productID),
                ),
              );
            },
          ),
          //THÊM NHẬP XUẤT
          ListTile(
            leading: const Icon(Icons.update, color: Colors.green),
            title: const Text('Thêm nhập/xuất'),
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WarehouseDetailScreen(
                    item: item,
                    readOnly: true,
                    isCreateHistory: true,
                  ),
                ),
              );
            },
          ),
          //CHỈNH SỬA THÔNG TIN
          ListTile(
            leading: const Icon(Icons.update, color: Colors.green),
            title: const Text('Chỉnh sửa thông tin '),
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WarehouseDetailScreen(item: item, isUpDate: true),
                ),
              );
            },
          ),
          //NHÂN BẢN
          ListTile(
            leading: const Icon(Icons.update, color: Colors.green),
            title: const Text('Nhân bản'),
            onTap: () async {
              showDialog(context, item);
            },
          ),
        ],
      ),
    );
  }
}
