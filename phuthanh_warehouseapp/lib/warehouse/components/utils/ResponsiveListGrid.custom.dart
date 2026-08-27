import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/ResponsiveHelper.helper.dart';

/// Danh sách dùng chung: mobile hiển thị [ListView] 1 cột như hiện tại,
/// desktop tự chuyển sang [GridView] nhiều cột (tuỳ chiều rộng cửa sổ)
/// tái dùng đúng [itemBuilder] hiện có, không cần viết lại item.
class ResponsiveListGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  /// Chiều rộng ước lượng của 1 item trên desktop, dùng để tính số cột.
  final double desktopItemWidth;
  final double desktopSpacing;

  const ResponsiveListGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.desktopItemWidth = 320,
    this.desktopSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDesktopLayout(context)) {
      return ListView.builder(
        padding: padding,
        physics: physics,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / desktopItemWidth)
            .floor()
            .clamp(2, 4);

        // Item cao thấp không đều (card nhiều section tuỳ dữ liệu) nên dùng
        // bố cục dạng masonry (mỗi cột tự co giãn theo nội dung) thay vì
        // GridView childAspectRatio cố định, tránh tràn (overflow) nội dung.
        final columnChildren = List.generate(columns, (_) => <Widget>[]);
        for (var i = 0; i < itemCount; i++) {
          final child = itemBuilder(context, i);
          final column = columnChildren[i % columns];
          if (column.isNotEmpty) {
            column.add(SizedBox(height: desktopSpacing));
          }
          column.add(child);
        }

        return SingleChildScrollView(
          padding: padding,
          physics: physics,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < columns; c++) ...[
                if (c != 0) SizedBox(width: desktopSpacing),
                Expanded(child: Column(children: columnChildren[c])),
              ],
            ],
          ),
        );
      },
    );
  }
}
