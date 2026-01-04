import 'package:flutter/material.dart';

class CustomBottomNavigatorSheetCheck extends StatelessWidget {
  final List<Widget> screens;
  final List<BottomNavigationBarItem> items;

  /// 🔥 index hiện tại (BẮT BUỘC)
  final int currentIndex;

  /// callback khi đổi tab
  final ValueChanged<int> onTabChanged;

  final Color selectedColor;
  final Color unselectedColor;

  final int? scanIndex;
  final VoidCallback? onScanTap;

  final IconData scanIcon;
  final Color scanColor;
  final double scanSize;

  const CustomBottomNavigatorSheetCheck({
    super.key,
    required this.screens,
    required this.items,
    required this.currentIndex,
    required this.onTabChanged,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.scanIndex,
    this.onScanTap,
    this.scanIcon = Icons.qr_code_scanner,
    this.scanColor = Colors.red,
    this.scanSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        items: _buildItems(),
        onTap: (index) {
          if (scanIndex != null && index == scanIndex && onScanTap != null) {
            onScanTap!();
            return;
          }
          onTabChanged(index);
        },
      ),
    );
  }

  List<BottomNavigationBarItem> _buildItems() {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      if (scanIndex != null && index == scanIndex) {
        return BottomNavigationBarItem(
          label: item.label,
          icon: SizedBox(
            height: scanSize,
            width: scanSize,
            child: Icon(scanIcon, size: scanSize, color: scanColor),
          ),
        );
      }
      return item;
    }).toList();
  }
}
