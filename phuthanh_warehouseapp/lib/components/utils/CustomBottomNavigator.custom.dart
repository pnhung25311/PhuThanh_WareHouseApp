import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/ScanBarcodeScreen.screen.dart';

class CustomBottomNavigator extends StatefulWidget {
  final List<Widget> screens;
  final List<BottomNavigationBarItem> items;
  final int initialIndex;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomBottomNavigator({
    Key? key,
    required this.screens,
    required this.items,
    this.initialIndex = 0,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
  }) : super(key: key);

  @override
  State<CustomBottomNavigator> createState() => _CustomBottomNavigatorState();
}

class _CustomBottomNavigatorState extends State<CustomBottomNavigator> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ScanScreen(isUpdate: true,)));
      return; // không đổi _selectedIndex
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: widget.selectedColor,
        unselectedItemColor: widget.unselectedColor,
        onTap: _onItemTapped,
        iconSize: 30,
        items: widget.items.map((item) {
          if (item.label == "Scan") {
            return BottomNavigationBarItem(
              icon: SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.qr_code_scanner, // icon scan
                  color: Colors.red, // màu riêng cho icon scan
                  size: 50,
                ),
              ),
              label: item.label,
            );
          }
          return item;
        }).toList(),
      ),
    );
  }
}
