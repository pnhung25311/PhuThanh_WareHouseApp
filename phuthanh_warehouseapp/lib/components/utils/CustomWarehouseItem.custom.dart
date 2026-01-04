import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Location.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
import 'package:phuthanh_warehouseapp/model/system/DisplaySetting.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';
// import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class WarehouseItem extends StatefulWidget {
  final WareHouse item;
  final VoidCallback? onLongPress;

  const WarehouseItem({super.key, required this.item, this.onLongPress});

  @override
  State<WarehouseItem> createState() => _WarehouseItemState();
}

class _WarehouseItemState extends State<WarehouseItem> {
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
  List<Location> loacation = [];
  List<VehicleType> vehicles = [];
  InfoService infoService = InfoService();
  NavigationHelper navigationHelper = NavigationHelper();
  MySharedPreferences mySharedPreferences = MySharedPreferences();

  @override
  void initState() {
    super.initState();
    _loadDisplaySettings();
    _loadDataLocation();
    _loadDataVehicleType();
  }

  Future<void> _loadDataLocation() async {
    List<Location> data;

    data = await infoService.fetchLocations();

    if (!mounted) return;
    setState(() {
      loacation = data;
    });
  }

  Future<void> _loadDataVehicleType() async {
    List<VehicleType> data;

    data = await infoService.LoadDtataVehicleType();

    if (!mounted) return;
    setState(() {
      vehicles = data;
    });
  }

  Future<void> _loadDisplaySettings() async {
    if (!mounted) return;
    final itemSetting = await mySharedPreferences.getDataObject(
      "showhideWareHouse",
    );
    displaySetting = DisplaySetting.fromJson(itemSetting);

    setState(() {
      showID_PartNo = displaySetting!.showIDPartNo;
      showID_ReplacedPartNo = displaySetting!.showIDReplacedPartNo;
      showID_Keeton = displaySetting!.showIDKeeton;
      showIndustrial = displaySetting!.showIndustrial;
      showParameter = displaySetting!.showParameter;
      showRemark = displaySetting!.showRemark;
      showVehicleDetails = displaySetting!.showVehicleDetails;
      showVehicleTypeName = displaySetting!.showVehicleTypeName;
      showUnitName = displaySetting!.showUnitName;
      showCountryName = displaySetting!.showCountryName;
      showManufacturerName = displaySetting!.showManufacturerName;
      showSupplierName = displaySetting!.showSupplierName;
      showSupplierActualName = displaySetting!.showSupplierActualName;
    });
  }

  // bool _getBool(String key) {
  //   final value = AppState.instance.get(key);
  //   return value ?? true;
  // }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final helper = FunctionHelper();
    final roles = AppState.instance.get("role");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            WarehouseDetailScreen(
              item: item,
              readOnly: !roles,
              isUpDate: roles,
              isReadOnlyHistory: !roles,
            ),
          );
        },
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔝 HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.nameProduct ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _QtyBadge(qty: item.qty),
                ],
              ),

              const SizedBox(height: 6),

              /// 🧾 MAIN INFO
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
              _row(
                showRemark,
                Icons.notes,
                "Ghi chú",
                widget.item.remarkOfDataWarehouse,
              ),
              _row(true, Icons.notes, "Mã hóa đơn", widget.item.idBill),
              _row(
                true,
                Icons.location_on_sharp,
                "Vị trí",
                helper.getNamesFromIdsDynamic<Location>(
                  ids: widget.item.locationID.toString(),
                  list: loacation,
                  getId: (e) => e.LocationID.toString(),
                  getName: (e) => e.NameLocation.toString(),
                ),
              ),

              /// 🧩 EXTRA INFO (wrap chips)
              const SizedBox(height: 6),

              // Wrap(
              //   spacing: 6,
              //   runSpacing: 6,
              //   children: [
              //     if (showIndustrial) _Chip("CN: ${item.idIndustrial}"),
              //     if (showUnitName) _Chip("ĐVT: ${item.unitName}"),
              //     if (showCountryName) _Chip("Quốc gia: ${item.countryName}"),
              //     if (showVehicleTypeName)
              //       _Chip("Hãng xe: ${item.vehicleTypeName}"),
              //     if (showVehicleDetails)
              //       _Chip("Dòng xe: ${item.vehicleDetail}"),
              //     if (showManufacturerName)
              //       _Chip("Nhà SX: ${item.manufacturerName}"),
              //     if (showSupplierActualName)
              //       _Chip("NCC TT: ${item.supplierActualName}"),
              //     if (showSupplierName) _Chip("NCC CT: ${item.supplierName}"),
              //   ],
              // ),
              // if (showParameter || showRemark) const SizedBox(height: 8),
              // if (showParameter)
              //   _NoteLine(icon: Icons.tune, text: item.parameter),
              // if (showRemark)
              //   _NoteLine(icon: Icons.note, text: item.remarkOfDataWarehouse),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔢 QTY BADGE
class _QtyBadge extends StatelessWidget {
  final num? qty;

  const _QtyBadge({this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Tồn: ${qty ?? 0}",
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
      ),
    );
  }
}

/// ℹ️ INFO LINE
// class _InfoLine extends StatelessWidget {
//   final IconData icon;
//   final String text;

//   const _InfoLine({required this.icon, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               text,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 15),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

/// 🧩 CHIP
// class _Chip extends StatelessWidget {
//   final String? text;

//   const _Chip(this.text);

//   @override
//   Widget build(BuildContext context) {
//     if (text == null || text!.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text!,
//         style: const TextStyle(fontSize: 15),
//         overflow: TextOverflow.ellipsis,
//         maxLines: 1,
//       ),
//     );
//   }
// }

Widget _row(bool visible, IconData icon, String label, dynamic value) {
  if (!visible || value == null || value.toString().isEmpty) {
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

/// 📝 NOTE LINE
// class _NoteLine extends StatelessWidget {
//   final IconData icon;
//   final String? text;

//   const _NoteLine({required this.icon, this.text});

//   @override
//   Widget build(BuildContext context) {
//     if (text == null || text!.isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: Colors.grey),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               text!,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
