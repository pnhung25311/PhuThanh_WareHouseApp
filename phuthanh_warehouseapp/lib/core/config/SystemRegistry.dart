import 'package:flutter/widgets.dart';
import 'package:phuthanh_warehouseapp/business/HomeBusiness.dart';
import 'package:phuthanh_warehouseapp/file/screen/TreeviewPage.screen.dart';
import 'package:phuthanh_warehouseapp/model/system/SystemOption.model.dart';
import 'package:phuthanh_warehouseapp/newbusiness/screen/ProductSyncScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/NewWarehouseHomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/screen/screenshot/ScreenshotHistoryScreen.screen.dart';
import 'package:phuthanh_warehouseapp/tapdoan/screen/TapDoanHomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/HomeScreen.screen.dart';

/// Nơi duy nhất khai báo các hệ thống hiển thị ở dropdown chọn hệ thống
/// trên màn hình đăng nhập, cùng màn hình đích của mỗi hệ thống.
///
/// Thêm/bớt một hệ thống chỉ cần sửa ở đây — không cần đụng vào
/// LoginScreen.screen.dart.
class SystemRegistry {
  SystemRegistry._();

  static final List<SystemOption> systems = [
    // SystemOption(name: 'Hệ thống kho', value: 'system1', id: 1),
    SystemOption(name: 'Hệ thống kinh doanh', value: 'system2', id: 2),
    SystemOption(name: 'Quản lý tệp tin', value: 'system3', id: 3),
    SystemOption(name: 'Hệ thống kho mới', value: 'system4', id: 4),
    SystemOption(name: 'Hệ thống kinh doanh mới', value: 'system5', id: 5),
    SystemOption(name: 'Hệ thống MediaCloud', value: 'system6', id: 6),
    SystemOption(name: 'Hệ thống kho tập đoàn', value: 'system7', id: 7),
  ];

  static final Map<int, WidgetBuilder> _screenBuilders = {
    1: (context) => HomeScreen(),
    2: (context) => HomeBusinessScreen(),
    3: (context) => TreeViewPage(),
    4: (context) => const NewWarehouseHomeScreen(),
    5: (context) => const ProductSyncScreen(),
    6: (context) => const ScreenshotHistoryScreen(),
    7: (context) => const TapDoanHomeScreen(),
  };

  /// Trả về màn hình đích tương ứng với hệ thống đã chọn.
  static Widget screenFor(BuildContext context, SystemOption system) {
    final builder = _screenBuilders[system.id];
    if (builder == null) {
      throw StateError('Không có màn hình cho hệ thống id=${system.id}');
    }
    return builder(context);
  }
}
