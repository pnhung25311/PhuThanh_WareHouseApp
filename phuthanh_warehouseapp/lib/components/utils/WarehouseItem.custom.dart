import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';

class WarehouseItem extends StatelessWidget {
  final WareHouse item;
  final bool isUpDate;
  final bool isCreate;
  final bool isCreateHistory;
  final VoidCallback? onLongPress;

  const WarehouseItem({
    super.key,
    required this.item,
    this.isUpDate = false,
    this.isCreate = false,
    this.isCreateHistory = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: ListTile(
        title: Text(
          item.nameProduct,
          overflow: TextOverflow.ellipsis, // 👈 rút gọn nếu tên quá dài
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mã sản phẩm: ${item.productID}",
              overflow: TextOverflow.ellipsis, // 👈 rút gọn
              maxLines: 1,
            ),
            Text(
              "Số lượng: ${item.qty}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              "Hóa đơn: ${item.idBill}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WarehouseDetailScreen(item: item, readOnly: true,),
            ),
          );
        },
        onLongPress: onLongPress,
      ),
    );
  }
}
