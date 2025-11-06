import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ViewImgProduct.screen.dart';
import 'package:flutter/services.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';

class ProductLongClick {
  static Future<String?> getFullname() async {
    Map<String, dynamic>? account = await MySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["FullName"];
    return fullname;
  }

  static void show(BuildContext context, Product item) {
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
          ListTile(
            leading: const Icon(Icons.image, color: Colors.blue),
            title: const Text('Xem ảnh'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewImageScreen(item: item)),
              );
            },
          ),
          //SAO CHÉP
          ListTile(
            leading: const Icon(Icons.copy, color: Colors.green),
            title: const Text('Sao chép'),
            onTap: () async {
              // 1️⃣ Chuẩn bị nội dung copy
              String textToCopy =
                  '''Product ID: ${item.productID}\n
                  Mã keeton: ${item.idKeeton}\n
                  Mã công nghiệp: ${item.idIndustrial}\n
                  Danh điểm: ${item.idPartNo}\n
                  Danh điểm tương đương: ${item.idReplacedPartNo}\n
                  Tên sản phẩm: ${item.nameProduct}\n
                  Thông số: ${item.parameter}\n
                  Ghi chú: ${item.remark}\n''';

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
          //CHỈNH SỬA THÔNG TIN
          ListTile(
            leading: const Icon(Icons.update, color: Colors.green),
            title: const Text('Chỉnh sửa thông tin '),
            onTap: () async {
              Navigator.pop(context);
              NavigationHelper.push(
                context,
                ProductDetailScreen(item: item, isUpDate: true),
              );
            },
          ),
        ],
      ),
    );
  }
}
