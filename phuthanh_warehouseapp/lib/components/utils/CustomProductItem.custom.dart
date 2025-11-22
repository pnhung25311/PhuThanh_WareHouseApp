import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class ProductItem extends StatefulWidget {
  final Product item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int? index;

  const ProductItem({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.index,
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

  bool showVehicleTypeName = true;
  bool showUnitName = true;
  bool showCountryName = true;
  bool showManufacturerName = true;
  bool showSupplierName = true;
  bool showSupplierActualName = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // await _loadDisplaySettings();
    showID_PartNo = AppState.instance.get("showID_PartNoP");
    showID_ReplacedPartNo = AppState.instance.get("showID_ReplacedPartNoP");
    showID_Keeton = AppState.instance.get("showID_KeetonP");    
    showIndustrial = AppState.instance.get("showIndustrialP");    
    showParameter = AppState.instance.get("showParameterP");    
    showRemark = AppState.instance.get("showRemarkP");    
    showVehicleDetails = AppState.instance.get("showVehicleDetailsP");
    showVehicleTypeName = AppState.instance.get("showVehicleTypeNameP");
    showUnitName = AppState.instance.get("showUnitNameP");
    showCountryName = AppState.instance.get("showCountryNameP");
    showManufacturerName = AppState.instance.get("showManufacturerNameP");
    showSupplierName = AppState.instance.get("showSupplierNameP");
    showSupplierActualName = AppState.instance.get("showSupplierActualNameP");


  }


  @override
  Widget build(BuildContext context) {
    // print(AppState.instance.get("showhideProduct")?["showID_PartNo"]);
    print(widget.item.unitName);
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
            // print("object"),
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
            // if (AppState.instance.get("showhideProduct")?["showIndustrial"]==true)
              Text(
                "Mã công nghiệp: ${widget.item.idIndustrial}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showID_PartNo)
            // if (AppState.instance.get("showhideProduct")?["showID_PartNo"]==true)

              Text(
                "Danh Điểm: ${widget.item.idPartNo}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showID_ReplacedPartNo)
              Text(
                "Danh Điểm tương đương: ${widget.item.idReplacedPartNo}",
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
            if (showUnitName)
              Text(
                "ĐVT: ${widget.item.unitName}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showManufacturerName)
              Text(
                "Nhà sản xuất: ${widget.item.manufacturerName}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showVehicleDetails)
              Text(
                "Dòng xe: ${widget.item.vehicleDetail}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showVehicleTypeName)
              Text(
                "Loại xe: ${widget.item.vehicleTypeName}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showCountryName)
              Text(
                "Nước sản xuất: ${widget.item.countryName}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showSupplierActualName)
              Text(
                "Nhà cung cấp thực tế: ${widget.item.supplierActualName}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            if (showSupplierName)
              Text(
                "Nhà cung cấp giấy tờ: ${widget.item.supplierName}",
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
        onTap: () {
          NavigationHelper.push(
            context,
            ProductDetailScreen(
              item: widget.item,
              readOnly: true,
              isUpDate: false,
            ),
          );
        },
        onLongPress: widget.onLongPress,
      ),
    );
  }
}
