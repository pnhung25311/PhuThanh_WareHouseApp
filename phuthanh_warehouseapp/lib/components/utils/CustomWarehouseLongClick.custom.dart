import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WareHouseTransfer.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/Screen/history/WarehouseHistoryScreen.screen.dart';
import 'package:flutter/services.dart';

class WarehouseLongClick {
  void show(BuildContext context, WareHouse item, bool role) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              item.productID.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //XEM ẢNH
          // ListTile(
          //   leading: const Icon(Icons.image, color: Colors.blue),
          //   title: const Text('Xem ảnh'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => ViewImageScreen(item: item)),
          //     );
          //   },
          // ),
          //SAO CHÉP
          ListTile(
            leading: const Icon(Icons.copy, color: Colors.green),
            title: const Text('Sao chép'),
            onTap: () async {
              // 1️⃣ Chuẩn bị nội dung copy
              String textToCopy =
                  '''Product ID: ${item.productID}\nMã keeton: ${item.idKeeton}\nMã công nghiệp: ${item.idIndustrial}\nDanh điểm: ${item.idPartNo}\nDanh điểm tương đương: ${item.idReplacedPartNo}\nTên sản phẩm: ${item.nameProduct}\nSố lượng: ${item.qty}\nSố lượng dự kiến: ${item.qtyExpected}\nMã số hóa đơn: ${item.idBill}\nThông số: ${item.parameter}\nGhi chú: ${item.remarkOfDataWarehouse}\n''';

              // 2️⃣ Copy vào clipboard
              await Clipboard.setData(ClipboardData(text: textToCopy));

              // 3️⃣ Thông báo người dùng
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Đã copy thông tin")),
              );

              // 4️⃣ Đóng modal
              Navigator.pop(context);
            },
          ),
          //XEM LỊCH SỬ NHẬP XUẤT
          ListTile(
            leading: const Icon(Icons.history, color: Colors.green),
            title: const Text('Xem lịch sử nhập/xuất'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WarehouseHistoryScreen(item: item),
                ),
              );
            },
          ),
          //THÊM NHẬP XUẤT
          if (role)
            ListTile(
              leading: const Icon(Icons.update, color: Colors.green),
              title: const Text('Thêm nhập/xuất'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WarehouseDetailScreen(
                      item: item,
                      readOnly: true,
                      isCreateHistory: true,
                    ),
                  ),
                );
              },
            ),
          //XUẤT ĐIỀU CHUYỂN
          // if (role)
          //   ListTile(
          //     leading: const Icon(Icons.update, color: Colors.green),
          //     title: const Text('Xuất điều chuyển'),
          //     onTap: () async {
          //       Navigator.pop(context);
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (_) => WareHouseTransfer(
          //             item: item,
          //             readOnly: role,
          //             isCreateHistory: role,
          //             isReadOnlyHistory: !role,
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          //CHỈNH SỬA THÔNG TIN
          // ListTile(
          //   leading: const Icon(Icons.update, color: Colors.green),
          //   title: const Text('Chỉnh sửa thông tin '),
          //   onTap: () async {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) =>
          //             WarehouseDetailScreen(item: item, isUpDate: true, isReadOnlyHistory: false, readOnly: true,),
          //       ),
          //     );
          //   },
          // ),
          //NHÂN BẢN
          // ListTile(
          //   leading: const Icon(Icons.update, color: Colors.green),
          //   title: const Text('Nhân bản'),
          //   onTap: () async {
          //     // showDialog(context, item);
          //   },
          // ),
        ],
      ),
    );
  }
}
