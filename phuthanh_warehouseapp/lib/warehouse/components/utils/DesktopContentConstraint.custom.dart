import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/ResponsiveHelper.helper.dart';

/// Bọc nội dung để trên desktop giới hạn chiều rộng tối đa và căn giữa,
/// tránh form/danh sách bị kéo giãn hết chiều ngang màn hình rộng.
/// Trên mobile trả nguyên [child], không thay đổi gì.
class DesktopContentConstraint extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const DesktopContentConstraint({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDesktopLayout(context)) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
