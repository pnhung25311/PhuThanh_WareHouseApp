import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/ResponsiveHelper.helper.dart';

class CustomBottomNavigator extends StatelessWidget {
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

  const CustomBottomNavigator({
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

  void _handleTap(int index) {
    if (scanIndex != null && index == scanIndex && onScanTap != null) {
      onScanTap!();
      return;
    }
    onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktopLayout(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: _handleTap,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: IconThemeData(color: selectedColor),
              unselectedIconTheme: IconThemeData(color: unselectedColor),
              destinations: _buildRailDestinations(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: screens[currentIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
        items: _buildItems(),
        onTap: _handleTap,
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

  List<NavigationRailDestination> _buildRailDestinations() {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      if (scanIndex != null && index == scanIndex) {
        return NavigationRailDestination(
          icon: Icon(scanIcon, color: scanColor),
          label: Text(item.label ?? ''),
        );
      }
      return NavigationRailDestination(
        icon: item.icon,
        selectedIcon: item.activeIcon,
        label: Text(item.label ?? ''),
      );
    }).toList();
  }
}
