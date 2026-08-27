import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/ResponsiveHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDrawerUtils.custom.dart';

/// Scaffold dùng chung cho các màn hình "shell" (có Drawer chuyển hệ thống).
///
/// - Mobile: giữ nguyên hành vi cũ — Drawer trượt, nút hamburger tự động.
/// - Desktop (Windows/macOS/Linux + chiều rộng >= [kDesktopBreakpoint]):
///   hiển thị [CustomDrawerUtils] cố định làm sidebar bên trái, không có
///   Drawer trượt/nút hamburger.
class ResponsiveDrawerScaffold extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final VoidCallback? onWarehouseSelected;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ResponsiveDrawerScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.onWarehouseSelected,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktopLayout(context)) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: Row(
          children: [
            SizedBox(
              width: 280,
              child: CustomDrawerUtils(onWarehouseSelected: onWarehouseSelected),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: CustomDrawerUtils(onWarehouseSelected: onWarehouseSelected),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
