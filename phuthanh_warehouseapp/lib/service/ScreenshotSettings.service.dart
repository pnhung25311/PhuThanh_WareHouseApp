import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotService.service.dart';

/// Cài đặt của hệ thống chụp ảnh (lưu trong SharedPreferences).
class ScreenshotSettings {
  static const String _directUploadKey = 'screenshot_direct_upload';
  static const String _currentFolderKey = 'screenshot_current_folder';
  static const String _directUploadFolderKey = 'screenshot_direct_upload_folder';
  final MySharedPreferences _prefs = MySharedPreferences();

  /// Bật: ảnh/video chụp hoặc chọn từ thư viện được đẩy thẳng lên server,
  /// không lưu vào "Local" trên máy (chỉ giữ lại nếu upload thất bại).
  Future<bool> isDirectUpload() async =>
      await _prefs.getDataBool(_directUploadKey) ?? false;

  Future<void> setDirectUpload(bool value) =>
      _prefs.setDataBool(_directUploadKey, value);

  /// Folder đang chọn để upload/xem (mặc định `main`).
  Future<String> currentFolder() async =>
      await _prefs.getDataString(_currentFolderKey) ??
      ScreenshotService.defaultFolder;

  Future<void> setCurrentFolder(String folder) =>
      _prefs.setDataString(_currentFolderKey, folder);

  /// Folder nhận ảnh/video khi bật "Đẩy thẳng lên server" (mặc định `main`).
  /// Khi tắt, upload luôn đi vào folder đang chọn ([currentFolder]).
  Future<String> directUploadFolder() async =>
      await _prefs.getDataString(_directUploadFolderKey) ??
      ScreenshotService.defaultFolder;

  Future<void> setDirectUploadFolder(String folder) =>
      _prefs.setDataString(_directUploadFolderKey, folder);
}
