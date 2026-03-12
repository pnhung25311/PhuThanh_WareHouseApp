import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/WareHouse/WarehouseDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class WarehouseItem extends StatefulWidget {
  final WareHouse item;
  final VoidCallback? onLongPress;

  const WarehouseItem({
    super.key,
    required this.item,
    this.onLongPress,
  });

  @override
  State<WarehouseItem> createState() => _WarehouseItemState();
}

class _WarehouseItemState extends State<WarehouseItem> {
  List<VehicleType> vehicles = [];
  final InfoService infoService = InfoService();
  final NavigationHelper navigationHelper = NavigationHelper();

  @override
  void initState() {
    super.initState();
    _loadVehicleTypes();
  }

  Future<void> _loadVehicleTypes() async {
    final data = await infoService.LoadDtataVehicleType();
    if (!mounted) return;

    setState(() {
      vehicles = data;
    });
  }

  bool _hasValue(dynamic value) {
    return value != null && value.toString().trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final helper = FunctionHelper();
    final roles = AppState.instance.get("role");

    final vehicleType = helper.getNamesFromIdsDynamic<VehicleType>(
      ids: item.vehicleTypeID.toString(),
      list: vehicles,
      getId: (e) => e.VehicleTypeID.toString(),
      getName: (e) => e.VehicleTypeName.toString(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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

              /// HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.nameProduct ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _QtyBadge(qty: item.qty),
                ],
              ),

              const SizedBox(height: 12),

              /// PRODUCT
              if (_hasValue(item.productID) ||
                  _hasValue(item.idKeeton) ||
                  _hasValue(item.idIndustrial) ||
                  _hasValue(item.idPartNo) ||
                  _hasValue(item.idReplacedPartNo))
                _section(
                  "Thông tin sản phẩm",
                  Colors.blue,
                  [
                    _info(Icons.qr_code, "Mã SP", item.productID),
                    _info(Icons.confirmation_number, "Keeton", item.idKeeton),
                    _info(Icons.precision_manufacturing, "CN", item.idIndustrial),
                    _info(Icons.view_list, "Danh điểm", item.idPartNo),
                    _info(Icons.compare_arrows, "Danh điểm TĐ", item.idReplacedPartNo),
                  ],
                ),

              /// VEHICLE
              if (_hasValue(item.vehicleDetail) || _hasValue(vehicleType))
                _section(
                  "Thông tin xe",
                  Colors.orange,
                  [
                    _info(Icons.directions_car, "Dòng xe", item.vehicleDetail),
                    _info(Icons.local_shipping, "Hãng xe", vehicleType),
                  ],
                ),

              /// MANUFACTURER
              if (_hasValue(item.manufacturerName) || _hasValue(item.countryName))
                _section(
                  "Nhà sản xuất",
                  Colors.green,
                  [
                    _info(Icons.factory, "NSX", item.manufacturerName),
                    _info(Icons.public, "Quốc gia", item.countryName),
                  ],
                ),

              /// SUPPLIER
              if (_hasValue(item.supplierActualName) || _hasValue(item.supplierName))
                _section(
                  "Nhà cung cấp",
                  Colors.purple,
                  [
                    _info(Icons.store, "NCC thực tế", item.supplierActualName),
                    _info(Icons.description, "NCC chứng từ", item.supplierName),
                  ],
                ),

              /// OTHER
              if (_hasValue(item.parameter) ||
                  _hasValue(item.unitName) ||
                  _hasValue(item.idBill) ||
                  _hasValue(item.locationID) ||
                  _hasValue(item.remarkOfDataWarehouse))
                _section(
                  "Thông tin khác",
                  Colors.teal,
                  [
                    _info(Icons.tune, "Thông số", item.parameter),
                    _info(Icons.straighten, "ĐVT", item.unitName),
                    _info(Icons.receipt_long, "Hóa đơn", item.idBill),
                    _info(Icons.location_on, "Vị trí", item.locationID),
                    _info(Icons.notes, "Ghi chú", item.remarkOfDataWarehouse),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}



/// SECTION UI

Widget _section(String title, Color color, List<Widget> children) {
  final items = children.where((e) => e != const SizedBox.shrink()).toList();
  if (items.isEmpty) return const SizedBox.shrink();

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.3),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        /// CONTENT
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: items),
        ),
      ],
    ),
  );
}



/// INFO LINE

Widget _info(IconData icon, String label, dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFE5E5E5),
          width: 0.6,
        ),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 6),

        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}



/// BADGE TỒN KHO

class _QtyBadge extends StatelessWidget {
  final num? qty;

  const _QtyBadge({this.qty});

  @override
  Widget build(BuildContext context) {
    final quantity = qty ?? 0;

    Color color;

    if (quantity == 0) {
      color = Colors.red;
    } else if (quantity < 10) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Tồn $quantity",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}