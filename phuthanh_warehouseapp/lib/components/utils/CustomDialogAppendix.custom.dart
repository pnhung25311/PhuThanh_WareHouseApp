import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';

Future<bool?> showAddDialogDynamic(
  BuildContext context, {
  required int model,
}) async {
  final TextEditingController controller = TextEditingController();
  Map<String, String> body = {};
  String table = "";
InfoService infoService = InfoService();
  NavigationHelper navigationHelper = NavigationHelper();

  // 🧩 Biến dropdown (chỉ dùng khi model == 5)
  String? selectedCategory;
  final Map<String, String> categories = {
    "1": "Nhà cung cấp",
    "2": "Nhập khẩu",
    "3": "Khách hàng",
  };

  void setBody() {
    switch (model) {
      case 1:
        table = "Country";
        body = {"Name": controller.text};
        break;
      case 2:
        table = "Employee";
        body = {"NameEmployee": controller.text};
        break;
      case 3:
        table = "Location";
        body = {"NameLocation": controller.text};
        break;
      case 4:
        table = "Manufacturer";
        body = {"Name": controller.text};
        break;
      case 5:
        table = "Supplier";
        body = {"Name": controller.text, "Category": selectedCategory ?? ""};
        break;
      case 6:
        table = "Unit";
        body = {"Name": controller.text};
        break;
      default:
        table = "";
        break;
    }
  }

  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Thêm mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔤 Ô nhập tên
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Tên",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🧩 Dropdown hiển thị khi model == 5
                  if (model == 5)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Loại",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: categories.entries
                          .map(
                            (entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedCategory = value);
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;

                  // ⚠️ Kiểm tra dropdown khi là Supplier
                  if (model == 5 && selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng chọn loại nhà cung cấp"),
                      ),
                    );
                    return;
                  }

                  setBody();
                  await infoService.addAppendix(table,jsonEncode( body));
                  navigationHelper.pop(context, true); // ✅ Báo thêm thành công
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    },
  );
}
