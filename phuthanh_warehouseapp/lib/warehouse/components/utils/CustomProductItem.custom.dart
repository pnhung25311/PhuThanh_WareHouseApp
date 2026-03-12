import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class ProductItem extends StatefulWidget {
  final Product item;
  final VoidCallback? onLongPress;

  const ProductItem({
    super.key,
    required this.item,
    this.onLongPress,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  List<VehicleType> vehicles = [];
  final InfoService _infoService = InfoService();
  final FunctionHelper _helper = FunctionHelper();
  final NavigationHelper _nav = NavigationHelper();

  @override
  void initState() {
    super.initState();
    _loadVehicleTypes();
  }

  Future<void> _loadVehicleTypes() async {
    final cached = AppState.instance.get<List<VehicleType>>("vehicleTypes");

    if (cached != null && cached.isNotEmpty) {
      if (!mounted) return;
      setState(() => vehicles = cached);
      return;
    }

    try {
      final data = await _infoService.LoadDtataVehicleType();
      AppState.instance.set("vehicleTypes", data);

      if (!mounted) return;
      setState(() => vehicles = data);
    } catch (e) {
      debugPrint("Load vehicle types failed: $e");
    }
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    final isAdminOrEditor = AppState.instance.get<bool>("role") == true;

    final vehicleTypeName = _helper.getNamesFromIdsDynamic<VehicleType>(
      ids: item.vehicleTypeID ?? "",
      list: vehicles,
      getId: (e) => e.VehicleTypeID.toString(),
      getName: (e) => e.VehicleTypeName,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4), width: 5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _nav.push(
            context,
            ProductDetailScreen(
              item: item,
              readOnly: !isAdminOrEditor,
              isUpDate: isAdminOrEditor,
            ),
          );
        },
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Text(
                item.nameProduct,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// PRODUCT INFO
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
                    _info(Icons.tag, "Keeton", item.idKeeton),
                    _info(Icons.precision_manufacturing, "CN", item.idIndustrial),
                    _info(Icons.view_list, "Part No", item.idPartNo),
                    _info(Icons.compare_arrows, "Part thay thế", item.idReplacedPartNo),
                  ],
                ),

              /// VEHICLE
              if (_hasValue(item.vehicleDetail) || _hasValue(vehicleTypeName))
                _section(
                  "Thông tin xe",
                  Colors.orange,
                  [
                    _info(Icons.directions_car, "Dòng xe", item.vehicleDetail),
                    _info(Icons.local_shipping, "Hãng xe", vehicleTypeName),
                  ],
                ),

              /// SPEC
              if (_hasValue(item.parameter) || _hasValue(item.unitName))
                _section(
                  "Thông số",
                  Colors.teal,
                  [
                    _info(Icons.tune, "Thông số", item.parameter),
                    _info(Icons.straighten, "ĐVT", item.unitName),
                  ],
                ),

              /// MANUFACTURER
              if (_hasValue(item.manufacturerName) || _hasValue(item.countryName))
                _section(
                  "Nhà sản xuất",
                  Colors.green,
                  [
                    _info(Icons.factory, "NSX", item.manufacturerName),
                    _info(Icons.public, "Nước", item.countryName),
                  ],
                ),

              /// SUPPLIER
              if (_hasValue(item.supplierActualName) ||
                  _hasValue(item.supplierName))
                _section(
                  "Nhà cung cấp",
                  Colors.purple,
                  [
                    _info(Icons.store, "NCC thực tế", item.supplierActualName),
                    _info(Icons.description, "NCC giấy tờ", item.supplierName),
                  ],
                ),

              /// NOTE
              if (_hasValue(item.remark))
                _section(
                  "Ghi chú",
                  Colors.grey,
                  [
                    _info(Icons.notes, "Ghi chú", item.remark),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}






/// SECTION

Widget _section(String title, Color color, List<Widget> children) {
  final items = children.where((e) => e != const SizedBox.shrink()).toList();
  if (items.isEmpty) return const SizedBox.shrink();

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
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





/// INFO ROW

Widget _info(IconData icon, String label, String? value) {
  if (value == null || value.trim().isEmpty) {
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
          width: 110,
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
            value,
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