import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';

class WarehouseItem extends StatefulWidget {
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
  State<WarehouseItem> createState() => _WarehouseItemState();

  // @override
  // Widget build(BuildContext context) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  //     elevation: 3,
  //     child: ListTile(
  //       title: Text(
  //         item.nameProduct.toString(),
  //         overflow: TextOverflow.ellipsis, // 👈 rút gọn nếu tên quá dài
  //         maxLines: 1,
  //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //       ),
  //       subtitle: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "Mã sản phẩm: ${item.productID}",
  //             overflow: TextOverflow.ellipsis, // 👈 rút gọn
  //             maxLines: 1,
  //           ),
  //           Text(
  //             "Số lượng: ${item.qty}",
  //             overflow: TextOverflow.ellipsis,
  //             maxLines: 1,
  //           ),
  //           Text(
  //             "Hóa đơn: ${item.idBill}",
  //             overflow: TextOverflow.ellipsis,
  //             maxLines: 1,
  //           ),
  //         ],
  //       ),
  //       isThreeLine: true,
  //       onTap: () {
  //         NavigationHelper.push(
  //           context,WarehouseDetailScreen(
  //               item: item,
  //               readOnly: true,
  //               isReadOnlyHistory: true,
  //             ),
  //         );
  //       },
  //       onLongPress: onLongPress,
  //     ),
  //   );
  // }


}
class _WarehouseItemState extends State<WarehouseItem> {
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
    _loadDisplaySettings();
  }

    Future<void> _loadDisplaySettings() async {
    final settings = await MySharedPreferences.getDataObject("showhideWareHouse");
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
        showUnitName = settings["showUnitName"] ?? true;
        showVehicleTypeName = settings["showVehicleTypeName"] ?? true;
        showCountryName = settings["showCountryName"] ?? true;
        showManufacturerName = settings["showManufacturerName"] ?? true;
        showSupplierName = settings["showSupplierName"] ?? true;
        showSupplierActualName = settings["showSupplierActualName"] ?? true;
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
                        Text(
              "SL tồn: ${widget.item.qty}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
                        Text(
              "Mã hóa đơn: ${widget.item.idBill}",
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
                "Ghi chú: ${widget.item.remarkOfDataWarehouse}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
        isThreeLine: true,
        onTap:
            () {
              NavigationHelper.push(
                context,
                WarehouseDetailScreen(item: widget.item, readOnly: false, isUpDate: true,),
              );
            },
        onLongPress: widget.onLongPress,
      ),
    );
  }
}