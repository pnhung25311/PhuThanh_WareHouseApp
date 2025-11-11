import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

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
    // _loadDisplaySettings();
    _init();
  }

  
  Future<void> _init() async {
    // await _loadDisplaySettings();
    showID_PartNo = AppState.instance.get("showID_PartNoWH");
    showID_ReplacedPartNo = AppState.instance.get("showID_ReplacedPartNoWH");
    showID_Keeton = AppState.instance.get("showID_KeetonWH");    
    showIndustrial = AppState.instance.get("showIndustrialWH");    
    showParameter = AppState.instance.get("showParameterWH");    
    showRemark = AppState.instance.get("showRemarkWH");    
    showVehicleDetails = AppState.instance.get("showVehicleDetailsWH");
    showVehicleTypeName = AppState.instance.get("showVehicleTypeNameWH");
    showUnitName = AppState.instance.get("showUnitNameWH");
    showCountryName = AppState.instance.get("showCountryNameWH");
    showManufacturerName = AppState.instance.get("showManufacturerNameWH");
    showSupplierName = AppState.instance.get("showSupplierNameWH");
    showSupplierActualName = AppState.instance.get("showSupplierActualNameWH");


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
        onTap: () {
          NavigationHelper.push(
            context,
            WarehouseDetailScreen(
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
