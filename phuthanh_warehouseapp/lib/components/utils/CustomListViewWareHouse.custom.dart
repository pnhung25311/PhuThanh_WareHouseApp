import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomWarehouseLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';

class WarehouseListView extends StatefulWidget {
  final List<WareHouse> warehouses;
  final Future<void> Function() onRefresh;
  const WarehouseListView({super.key, required this.warehouses, required this.onRefresh});

  @override
  State<WarehouseListView> createState() => _WarehouseListViewState();
}

class _WarehouseListViewState extends State<WarehouseListView> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.warehouses.isEmpty) {
      return const Center(child: Text("Không có dữ liệu kho hàng."));
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        key: const PageStorageKey('warehouseList'),
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.warehouses.length,
        itemBuilder: (context, index) {
          final item = widget.warehouses[index];
          return WarehouseItem(
            item: item,
            onLongPress: () {
              WarehouseLongClick.show(context, item);
            },
          );
        },
      ),
    );
  }
}
