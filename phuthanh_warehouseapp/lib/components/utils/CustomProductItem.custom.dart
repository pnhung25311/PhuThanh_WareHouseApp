import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';

class ProductItem extends StatefulWidget {
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
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool showProductID = true;
  bool showID_Keeton = true;
  bool showIndustrial = true;
  bool showID_PartNo = true;
  bool showID_ReplacedPartNo = true;
  bool showNameProduct = true;
  bool showParameter = true;
  bool showRemark = true;
  bool showVehicleDetails = true;

  @override
  void initState() {
    super.initState();
    _loadDisplaySettings();
  }

  Future<void> _loadDisplaySettings() async {
    final settings = await MySharedPreferences.getDataObject("showhideProduct");
    if (settings != null) {
      setState(() {
        showProductID = settings["showProductID"] ?? true;
        showID_Keeton = settings["showID_Keeton"] ?? true;
        showIndustrial = settings["showIndustrial"] ?? true;
        showID_PartNo = settings["showID_PartNo"] ?? true;
        showID_ReplacedPartNo = settings["showID_ReplacedPartNo"] ?? true;
        showNameProduct = settings["showNameProduct"] ?? true;
        showParameter = settings["showParameter"] ?? true;
        showRemark = settings["showRemark"] ?? true;
        showVehicleDetails = settings["showVehicleDetails"] ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: ListTile(
        title: Text(
          widget.item.nameProduct.toString(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mã sản phẩm: ${widget.item.productID}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (showID_Keeton)
              Text(
                "Mã keeton: ${widget.item.idKeeton}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showIndustrial)
              Text(
                "Mã công nghiệp: ${widget.item.idIndustrial}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showID_PartNo)
              Text(
                "Danh Điểm: ${widget.item.idPartNo}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showID_ReplacedPartNo)
              Text(
                "Danh Điểm: ${widget.item.idReplacedPartNo}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            // if (showNameProduct)
            //   Text(
            //     "Tên sản phẩm: ${widget.item.nameProduct}",
            //     overflow: TextOverflow.ellipsis,
            //     maxLines: 1,
            //   ),
            if (showParameter)
              Text(
                "Thông số: ${widget.item.parameter}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showVehicleDetails)
              Text(
                "Dòng xe: ${widget.item.vehicleDetail}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showRemark)
              Text(
                "Ghi chú: ${widget.item.remark}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
        isThreeLine: true,
        onTap:
            widget.onTap ??
            () {
              NavigationHelper.push(
                context,
                ProductDetailScreen(item: widget.item, readOnly: true),
              );
            },
        onLongPress: widget.onLongPress,
      ),
    );
  }
}
