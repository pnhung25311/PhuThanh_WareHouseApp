import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/FolderPickerDialog.custom.dart';
import 'package:phuthanh_warehouseapp/helper/DeviceNameHelper.helper.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotService.service.dart';

/// Hỏi người dùng chọn thư mục trên server để đẩy ảnh/video lên.
class FolderPickerHelper {
  FolderPickerHelper._();

  static final ScreenshotService _service = ScreenshotService();

  /// Hiện hộp thoại chọn folder (chọn sẵn [initial]). [knownFolders] là danh
  /// sách đã có (nếu null sẽ tải từ server, tối đa vài giây rồi dùng danh
  /// sách tối thiểu). Trả về tên folder, hoặc null nếu hủy.
  static Future<String?> pick(
    BuildContext context, {
    required String initial,
    List<String>? knownFolders,
  }) async {
    var folders = knownFolders;
    if (folders == null) {
      try {
        final deviceName = await DeviceNameHelper.current();
        folders = await _service
            .listFolders(deviceName)
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        folders = const [];
      }
    }

    const main = ScreenshotService.defaultFolder;
    final list = <String>[
      main,
      ...folders.where((f) => f != main),
      if (initial != main && !folders.contains(initial)) initial,
    ];

    if (!context.mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (_) => FolderPickerDialog(folders: list, initial: initial),
    );
  }
}
