import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/PendingScreenshot.model.dart';

/// Quản lý ảnh/video chưa lưu lên server. Dữ liệu nằm hẳn trong thư mục
/// `Documents/Captures` của app (không phụ thuộc SharedPreferences nên không
/// mất khi tắt app, đăng xuất hay đổi đường dẫn container) — chỉ mất khi
/// người dùng xóa hoặc đã upload thành công.
class PendingScreenshotStore {
  /// Tăng mỗi khi kho Local thay đổi, để màn hình đang mở tự tải lại
  /// (ví dụ ảnh chụp màn hình bên ngoài app vừa được lưu vào).
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<Directory> _directory() async {
    final docDir = await getApplicationDocumentsDirectory();
    return Directory('${docDir.path}/Captures').create(recursive: true);
  }

  /// Đưa file vào kho Local (copy vào thư mục bền vững nếu file đang
  /// nằm ngoài, ví dụ thư mục tạm của camera/ảnh chụp màn hình) và trả về
  /// file đã lưu bền vững để dùng cho các thao tác tiếp theo.
  Future<File> addPending(File file) async {
    final dir = await _directory();
    if (file.parent.path == dir.path) return file;

    final dotIndex = file.path.lastIndexOf('.');
    final ext = dotIndex == -1 ? '' : file.path.substring(dotIndex);
    final target = await _uniquePath(dir, ext);

    // Các file đưa vào đây là bản sao tạm do bộ chọn ảnh/camera tạo ra (hoặc
    // cache ảnh chụp màn hình), nên chuyển hẳn sang kho thay vì sao chép lần
    // nữa: tức thì kể cả với video vài trăm MB. Khác ổ đĩa thì mới phải copy.
    File saved;
    try {
      saved = await file.rename(target);
    } on FileSystemException {
      saved = await file.copy(target);
    }
    // Mốc thời gian của file trong Local là lúc nó được thêm vào (file từ
    // thư viện ảnh có thể mang ngày quay rất cũ, sẽ bị xếp cuối danh sách).
    await saved.setLastModified(DateTime.now());
    changes.value++;
    return saved;
  }

  /// Đường dẫn chưa tồn tại trong [dir] (tên theo thời gian; tránh trùng khi
  /// thêm nhiều file trong cùng 1 mili giây).
  Future<String> _uniquePath(Directory dir, String ext) async {
    var stamp = DateTime.now().millisecondsSinceEpoch;
    while (await File('${dir.path}/$stamp$ext').exists()) {
      stamp++;
    }
    return '${dir.path}/$stamp$ext';
  }

  /// Xóa 1 file khỏi kho Local (dùng sau khi upload thành công).
  Future<void> removePendingByPath(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) await file.delete();
    changes.value++;
  }

  /// Xóa nhiều file cùng lúc (chỉ thông báo thay đổi 1 lần).
  Future<void> removePendingByPaths(Iterable<String> filePaths) async {
    for (final path in filePaths) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    changes.value++;
  }

  /// Danh sách ảnh/video chưa lưu, mới nhất lên đầu (thời điểm chụp = thời
  /// điểm sửa file, giữ nguyên khi đổi tên).
  Future<List<PendingScreenshot>> getAll() async {
    final dir = await _directory();
    final items = <PendingScreenshot>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      items.add(
        PendingScreenshot(
          filePath: entity.path,
          capturedAt: stat.modified.millisecondsSinceEpoch,
          size: stat.size,
        ),
      );
    }
    items.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return items;
  }
}
