import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/core/config/SystemRegistry.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/system/SystemOption.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

/// Icon + màu dùng thống nhất cho MỌI nơi có hành động "Đổi hệ thống" trong
/// app (drawer của từng hệ thống, menu màn hình chính...) — tránh mỗi nơi tự
/// chọn 1 icon/màu khác nhau như trước.
const IconData kChangeSystemIcon = Icons.change_circle;
const Color kChangeSystemColor = Colors.green;

/// Hộp thoại "Đổi hệ thống" dùng chung cho mọi hệ thống — lấy danh sách từ
/// `SystemRegistry.systems` (không hard-code từng hệ thống riêng lẻ) nên
/// không bị lạc hậu mỗi khi thêm/bớt hệ thống. Chuyển thẳng sang màn hình hệ
/// thống khác (token đăng nhập vẫn còn hiệu lực), không cần đăng xuất rồi mở
/// lại app như trước.
Future<void> showChangeSystemDialog(BuildContext context) {
  final navigationHelper = NavigationHelper();

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Chọn hệ thống'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final system in SystemRegistry.systems)
                ListTile(
                  leading: const Icon(kChangeSystemIcon, color: kChangeSystemColor),
                  title: Text(system.name),
                  onTap: () => _switchTo(navigationHelper, context, dialogContext, system),
                ),
            ],
          ),
        ),
      );
    },
  );
}

void _switchTo(
  NavigationHelper navigationHelper,
  BuildContext context,
  BuildContext dialogContext,
  SystemOption system,
) {
  navigationHelper.pop(dialogContext);

  // Cập nhật hệ thống đang chọn trong AppState — các drawer đọc giá trị này
  // để hiện đúng tên hệ thống ở header và đúng menu con theo từng hệ thống
  // (ví dụ `CustomDrawerUtils`), nên phải cập nhật mỗi lần đổi, không chỉ lúc
  // đăng nhập.
  AppState.instance.set("selectedSystem", system.value);
  AppState.instance.set("selectedSystemName", system.name);

  navigationHelper.pushAndRemoveUntil(
    context,
    SystemRegistry.screenFor(context, system),
  );
}
