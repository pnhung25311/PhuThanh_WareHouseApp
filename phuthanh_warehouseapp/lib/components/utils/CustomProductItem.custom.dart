import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
import 'package:phuthanh_warehouseapp/model/system/DisplaySetting.model.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';
// import 'package:phuthanh_warehouseapp/store/AppState.store.dart';
// import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class ProductItem extends StatefulWidget {
  final Product item;
  final VoidCallback? onLongPress;

  const ProductItem({super.key, required this.item, this.onLongPress});

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool showProductID = true;
  bool showID_Keeton = true;
  bool showIndustrial = true;
  bool showID_PartNo = true;
  bool showID_ReplacedPartNo = true;
  bool showParameter = true;
  bool showRemark = true;
  bool showVehicleDetails = true;

  bool showVehicleTypeName = true;
  bool showUnitName = true;
  bool showCountryName = true;
  bool showManufacturerName = true;
  bool showSupplierName = true;
  bool showSupplierActualName = true;
  DisplaySetting? displaySetting;
  List<VehicleType> vehicles = [];
  InfoService infoService = InfoService();
  NavigationHelper navigationHelper = NavigationHelper();
      MySharedPreferences mySharedPreferences =MySharedPreferences();


  // final DisplaySetting displaySetting;

  @override
  void initState() {
    super.initState();
    // _loadDisplaySettings();
    _loadDataVehicel();
  }

  // bool _getBool(String key) {
  //   final value = AppState.instance.get(key);
  //   return value ?? true;
  // }
  Future<void> _loadDataVehicel() async {
    AppState.instance.set("vehicleAppState", null);
    final vehicleAppState = await AppState.instance.get("vehicleAppState");

    List<VehicleType> data;

    if (vehicleAppState != null) {
      data = List<VehicleType>.from(vehicleAppState);
    } else {
      data = await infoService.LoadDtataVehicleType();
      AppState.instance.set("vehicleAppState", data);
    }

    if (!mounted) return;
    setState(() {
      vehicles = data;
    });
  }

  // Future<void> _loadDisplaySettings() async {
  //   if (!mounted) return;
  //   final itemSetting = await mySharedPreferences.getDataObject(
  //     "showhideProduct",
  //   );
  //   // final itemSetting = AppState.instance.get("showhideProduct");
  //   setState(() {
  //     displaySetting = DisplaySetting.fromJson(itemSetting);
  //     showID_PartNo = displaySetting!.showIDPartNo;
  //     showID_ReplacedPartNo = displaySetting!.showIDReplacedPartNo;
  //     showID_Keeton = displaySetting!.showIDKeeton;
  //     showIndustrial = displaySetting!.showIndustrial;
  //     showParameter = displaySetting!.showParameter;
  //     showRemark = displaySetting!.showRemark;
  //     showVehicleDetails = displaySetting!.showVehicleDetails;
  //     showVehicleTypeName = displaySetting!.showVehicleTypeName;
  //     showUnitName = displaySetting!.showUnitName;
  //     showCountryName = displaySetting!.showCountryName;
  //     showManufacturerName = displaySetting!.showManufacturerName;
  //     showSupplierName = displaySetting!.showSupplierName;
  //     showSupplierActualName = displaySetting!.showSupplierActualName;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final helper = FunctionHelper();
    final roles = AppState.instance.get("role");
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          navigationHelper.push(
            context,
            ProductDetailScreen(item: item, readOnly: !roles, isUpDate: roles),
          );
        },
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== TITLE =====
              Text(
                widget.item.nameProduct.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 6),

              /// ===== DATA =====
              _row(true, Icons.qr_code, "Mã sản phẩm", widget.item.productID),
              _row(
                showID_Keeton,
                Icons.confirmation_number,
                "Mã Keeton",
                widget.item.idKeeton,
              ),
              _row(
                showIndustrial,
                Icons.precision_manufacturing,
                "Mã công nghiệp",
                widget.item.idIndustrial,
              ),
              _row(
                showID_PartNo,
                Icons.view_list,
                "Danh điểm",
                widget.item.idPartNo,
              ),
              _row(
                showID_ReplacedPartNo,
                Icons.compare_arrows,
                "Danh điểm TĐ",
                widget.item.idReplacedPartNo,
              ),
              _row(
                showParameter,
                Icons.tune,
                "Thông số",
                widget.item.parameter,
              ),
              _row(showUnitName, Icons.straighten, "ĐVT", widget.item.unitName),
              _row(
                showManufacturerName,
                Icons.factory,
                "Nhà sản xuất",
                widget.item.manufacturerName,
              ),
              _row(
                showVehicleDetails,
                Icons.directions_car,
                "Dòng xe",
                widget.item.vehicleDetail,
              ),
              _row(
                showVehicleTypeName,
                Icons.local_shipping,
                "Hãng xe",
                helper.getNamesFromIdsDynamic<VehicleType>(
                  ids: widget.item.vehicleTypeID.toString(),
                  list: vehicles,
                  getId: (e) => e.VehicleTypeID.toString(),
                  getName: (e) => e.VehicleTypeName.toString(),
                ),
              ),
              _row(
                showCountryName,
                Icons.public,
                "Nước SX",
                widget.item.countryName,
              ),
              _row(
                showSupplierActualName,
                Icons.store,
                "NCC thực tế",
                widget.item.supplierActualName,
              ),
              _row(
                showSupplierName,
                Icons.description,
                "NCC giấy tờ",
                widget.item.supplierName,
              ),
              _row(showRemark, Icons.notes, "Ghi chú", widget.item.remark),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== ẨN LÀ ẨN ICON + TEXT + SPACE =====
  Widget _row(bool visible, IconData icon, String label, dynamic value) {
    if (!visible || value == null || value.toString().isEmpty) {
      // if (!visible ) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
