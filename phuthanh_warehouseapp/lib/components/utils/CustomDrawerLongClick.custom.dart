import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDialogDisplaySettings.custom.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';

class DrawerLongClick {
  static Future<String?> getFullname() async {
    Map<String, dynamic>? account = await MySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["FullName"];
    return fullname;
  }

static void show(BuildContext parentContext, String condition) {
  showModalBottomSheet(
    context: parentContext,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.update, color: Colors.green),
          title: const Text('Cài đặt hiển thị'),
          onTap: () async {
            // Dùng context gốc parentContext để pop sheet hiện tại
            Navigator.pop(parentContext); // đóng sheet trước
            // Mở sheet mới, cũng dùng context gốc
            showModalBottomSheet(
              context: parentContext,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) =>  DisplaySettingsDialog(
                condition:condition,
              ),
            );
          },
        ),
      ],
    ),
  );
}

}
