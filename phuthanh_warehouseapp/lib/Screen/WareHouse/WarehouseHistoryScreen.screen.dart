import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/History.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/service/HistoryService.service.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';

class WarehouseHistoryScreen extends StatefulWidget {
  final String productID;

  const WarehouseHistoryScreen({Key? key, required this.productID})
      : super(key: key);

  @override
  State<WarehouseHistoryScreen> createState() => _WarehouseHistoryScreen();
}

class _WarehouseHistoryScreen extends State<WarehouseHistoryScreen> {
  late Future<List<History>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = HistoryService.LoadDtata(widget.productID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lịch sử nhập/xuất: ${widget.productID}"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<History>>(
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
                _futureHistory = HistoryService.LoadDtata(widget.productID);
              });
            },
            child: ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final h = histories[index];
                final bool isImport = h.qty > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.4),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isImport
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : [Colors.red.shade50, Colors.red.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      onTap: () async {
                        WareHouse? itemWh =
                            await Warehouseservice.FindByIDWareHouse(
                                  widget.productID,
                                ) ??
                                WareHouse.empty();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WarehouseDetailScreen(
                              item: itemWh,
                              itemHistory: h,
                              isReadOnlyHistory: false,
                              isCreateHistory: true,
                              readOnly: true
                            ),
                          ),
                        );
                      },
                      title: Text(
                        "${isImport ? "Nhập" : "Xuất"} hàng - ${h.productID}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Số lượng: ${h.qty}"),
                            if (h.remark?.isNotEmpty ?? false)
                              Text("Ghi chú: ${h.remark}"),
                            Text(
                                "Thời gian: ${Formatdatehelper.formatDMY(Formatdatehelper.parseDate(h.time ?? ""))}"),
                            if (h.timeUpdate != null)
                              Text(
                                  "Cập nhật: ${Formatdatehelper.formatDMY(Formatdatehelper.parseDate(h.timeUpdate!))}"),
                            if (h.fullName != null)
                              Text("Người thao tác: ${h.fullName}"),
                          ],
                        ),
                      ),
                      trailing: CircleAvatar(
                        radius: 20,
                        backgroundColor: isImport ? Colors.green : Colors.red,
                        child: Icon(
                          isImport ? Icons.arrow_downward : Icons.arrow_upward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
