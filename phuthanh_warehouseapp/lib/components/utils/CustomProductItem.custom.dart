import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';

class ProductItem extends StatelessWidget {
  final Product item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProductItem({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: ListTile(
        title: Text(
          item.nameProduct.toString(),
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
              "Tên sản phẩm: ${item.nameProduct}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            // Text(
            //   "Hóa đơn: ${item.idBill}",
            //   overflow: TextOverflow.ellipsis,
            //   maxLines: 1,
            // ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          NavigationHelper.push(
            context,ProductDetailScreen(item: item, readOnly: true,),
          );
        },
        onLongPress: onLongPress,
      ),
    );
  }
}
