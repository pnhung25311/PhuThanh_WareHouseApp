import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phuthanh_warehouseapp/components/ScreenshotOptionsSheet.custom.dart';
import 'package:phuthanh_warehouseapp/helper/DeviceNameHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FolderPickerHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/CapturedScreenshot.model.dart';
import 'package:phuthanh_warehouseapp/service/PendingScreenshotStore.service.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotChannel.service.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotService.service.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotSettings.service.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// Lắng nghe sự kiện chụp màn hình toàn app (kể cả khi app đang chạy nền,
/// dừng khi tiến trình app bị tắt hẳn) và hiển thị popup cho người dùng
/// chọn: lưu vào server, lưu vào máy, lưu cả 2, hoặc copy ảnh.
class ScreenshotHelper {
  ScreenshotHelper._internal();
  static final ScreenshotHelper instance = ScreenshotHelper._internal();

  final ScreenshotService _service = ScreenshotService();
  final PendingScreenshotStore _pendingStore = PendingScreenshotStore();

  StreamSubscription<CapturedScreenshot>? _subscription;
  bool _isSheetOpen = false;

  /// Bắt đầu lắng nghe sự kiện chụp màn hình. Gọi 1 lần khi app khởi động.
  Future<void> start(GlobalKey<NavigatorState> navigatorKey) async {
    if (_subscription != null) return;
    await _requestPermissions();

    _subscription = ScreenshotChannel.onScreenshotTaken.listen((event) async {
      if (!event.file.existsSync()) return;

      // Chụp bên ngoài app: không có UI để hỏi, lưu thẳng vào "Local".
      if (event.fromBackground) {
        await _pendingStore.addPending(event.file);
        return;
      }

      if (_isSheetOpen) return;
      final context = navigatorKey.currentContext;
      if (context == null) return;
      await _handleScreenshot(context, event.file);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;
    await [Permission.photos, Permission.storage].request();
  }

  Future<void> _handleScreenshot(BuildContext context, File tempFile) async {
    final file = await _pendingStore.addPending(tempFile);

    _isSheetOpen = true;
    final action = await ScreenshotOptionsSheet.show(context, file);
    _isSheetOpen = false;
    if (action == null || !context.mounted) return;

    switch (action) {
      case ScreenshotAction.saveToServer:
        await _saveToServer(context, file);
        break;
      case ScreenshotAction.saveToDevice:
        await _saveToDevice(context, file);
        break;
      case ScreenshotAction.saveBoth:
        // Lưu máy trước: upload thành công sẽ xóa file khỏi kho Local.
        await _saveToDevice(context, file);
        if (context.mounted) await _saveToServer(context, file);
        break;
      case ScreenshotAction.copy:
        await _copyToClipboard(context, file);
        break;
    }
  }

  Future<void> _saveToServer(BuildContext context, File file) async {
    try {
      // Bật "Đẩy thẳng lên server" thì vào folder chính; không thì hỏi chọn
      // thư mục (mặc định là folder đang xem).
      final settings = ScreenshotSettings();
      final String? folder = await settings.isDirectUpload()
          ? await settings.directUploadFolder()
          : (context.mounted
                ? await FolderPickerHelper.pick(
                    context,
                    initial: await settings.currentFolder(),
                  )
                : null);
      if (folder == null) return; // người dùng hủy: file vẫn nằm trong Local

      final deviceName = await DeviceNameHelper.current();
      final result = await _service.uploadScreenshot(file, deviceName, folder);
      final success = result.ok;
      if (success) await _pendingStore.removePendingByPath(file.path);
      if (!context.mounted) return;
      _showMessage(
        context,
        success
            ? 'Đã lưu ảnh chụp màn hình lên server (folder $folder)'
            : 'Lưu lên server thất bại: ${result.errorMessage}',
      );
    } catch (e) {
      if (context.mounted) _showMessage(context, 'Lỗi khi lưu lên server: $e');
    }
  }

  Future<void> _saveToDevice(BuildContext context, File file) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final destDir = Directory('${docDir.path}/Screenshots')
        ..createSync(recursive: true);
      final destPath = '${destDir.path}/${file.uri.pathSegments.last}';
      await file.copy(destPath);
      if (context.mounted) {
        _showMessage(context, 'Đã lưu ảnh chụp màn hình vào máy');
      }
    } catch (e) {
      if (context.mounted) _showMessage(context, 'Lỗi khi lưu vào máy: $e');
    }
  }

  Future<void> _copyToClipboard(BuildContext context, File file) async {
    try {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        if (context.mounted) {
          _showMessage(context, 'Thiết bị không hỗ trợ copy ảnh');
        }
        return;
      }
      final bytes = await file.readAsBytes();
      final item = DataWriterItem();
      item.add(Formats.png(bytes));
      await clipboard.write([item]);
      if (context.mounted) _showMessage(context, 'Đã copy ảnh vào clipboard');
    } catch (e) {
      if (context.mounted) _showMessage(context, 'Lỗi khi copy ảnh: $e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)));
  }
}
