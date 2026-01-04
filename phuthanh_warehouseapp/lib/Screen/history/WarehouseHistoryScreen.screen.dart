import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomHistoryItem.custom.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/ViewHistory.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/HistoryService.service.dart';

class WarehouseHistoryScreen extends StatefulWidget {
  final WareHouse item;

  const WarehouseHistoryScreen({Key? key, required this.item})
    : super(key: key);

  @override
  State<WarehouseHistoryScreen> createState() => _WarehouseHistoryScreenState();
}

class _WarehouseHistoryScreenState extends State<WarehouseHistoryScreen> {
  late Future<List<ViewHistory>> _futureHistory;
  HistoryService historyService = HistoryService();
  @override
  void initState() {
    super.initState();
    _futureHistory = historyService.LoadDtata(
      widget.item.dataWareHouseAID.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lịch sử nhập/xuất: ${widget.item.productID}"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ViewHistory>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Lỗi khi tải dữ liệu: ${snapshot.error}"),
            );
          }

          final histories = snapshot.data ?? [];
          if (histories.isEmpty) {
            return const Center(child: Text("Không có lịch sử nào"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureHistory = historyService.LoadDtata(
                  widget.item.dataWareHouseAID.toString(),
                );
              });
            },
            child: ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                return HistoryItem(
                  history: histories[index],
                  warehouse: widget.item,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
