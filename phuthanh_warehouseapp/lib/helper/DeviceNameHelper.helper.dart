import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';

/// Lấy tên thiết bị dùng để định danh ảnh chụp màn hình trên server
/// (deviceName = tên đăng nhập `UserName` của tài khoản đang đăng nhập).
class DeviceNameHelper {
  static final MySharedPreferences _prefs = MySharedPreferences();

  static Future<String> current() async {
    final accountJson = await _prefs.getDataObject('account');
    if (accountJson == null) return 'unknown';
    return Account.fromJson(accountJson).UserName;
  }
}
