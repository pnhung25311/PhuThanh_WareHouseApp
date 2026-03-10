import 'package:flutter/material.dart';// sửa typo .sreen → .screen
import 'package:phuthanh_warehouseapp/warehouse/Screen/Product/ProductDetailScreen.sreen.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FunctionHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/model/info/VehicleTypeID.model.dart';
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
    // Lấy từ cache trước (AppState)
    final cached = AppState.instance.get<List<VehicleType>>("vehicleTypes");

    if (cached != null && cached.isNotEmpty) {
      if (!mounted) return;
      setState(() => vehicles = cached);
      return;
    }

    try {
      final data = await _infoService.LoadDtataVehicleType(); // sửa typo nếu cần: LoadDataVehicleType
      AppState.instance.set("vehicleTypes", data);
      if (!mounted) return;
      setState(() => vehicles = data);
    } catch (e) {
      // Có thể thêm thông báo lỗi nhẹ nếu muốn
      debugPrint("Load vehicle types failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;
    final isAdminOrEditor = AppState.instance.get<bool>("role") == true; // giả sử role true = có quyền edit

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 1,
      shadowColor: colorScheme.shadow.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)),
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
              // Product Name - nổi bật hơn
              Text(
                item.nameProduct,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8),

              const SizedBox(height: 10),

              // Nhóm thông tin chính
              _buildInfoRow(
                visible: true,
                icon: Icons.qr_code_2_rounded,
                label: "Mã SP",
                value: item.productID,
                color: colorScheme.primary,
              ),

              _buildInfoRow(
                visible: item.idKeeton.isNotEmpty == true,
                icon: Icons.tag_rounded,
                label: "Mã Keeton",
                value: item.idKeeton,
              ),

              _buildInfoRow(
                visible: item.idIndustrial.isNotEmpty == true,
                icon: Icons.precision_manufacturing_rounded,
                label: "Mã công nghiệp",
                value: item.idIndustrial,
              ),

              _buildInfoRow(
                visible: item.idPartNo.isNotEmpty == true,
                icon: Icons.view_list_rounded,
                label: "Part No",
                value: item.idPartNo,
              ),

              _buildInfoRow(
                visible: item.idReplacedPartNo.isNotEmpty == true,
                icon: Icons.compare_arrows_rounded,
                label: "Part No thay thế",
                value: item.idReplacedPartNo,
              ),

              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 8),

              // Nhóm thông số & xe
              _buildInfoRow(
                visible: item.parameter.isNotEmpty == true,
                icon: Icons.tune_rounded,
                label: "Thông số",
                value: item.parameter,
              ),

              _buildInfoRow(
                visible: item.unitName?.isNotEmpty == true,
                icon: Icons.straighten_rounded,
                label: "ĐVT",
                value: item.unitName,
              ),

              _buildInfoRow(
                visible: item.vehicleDetail.isNotEmpty == true,
                icon: Icons.directions_car_filled_rounded,
                label: "Dòng xe",
                value: item.vehicleDetail,
                color: Colors.teal.shade700,
              ),

              _buildInfoRow(
                visible: item.vehicleTypeID?.isNotEmpty == true,
                icon: Icons.local_shipping_rounded,
                label: "Hãng xe",
                value: _helper.getNamesFromIdsDynamic<VehicleType>(
                  ids: item.vehicleTypeID ?? "",
                  list: vehicles,
                  getId: (e) => e.VehicleTypeID.toString(),
                  getName: (e) => e.VehicleTypeName,
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 8),

              // Nhà cung cấp & khác
              _buildInfoRow(
                visible: item.manufacturerName?.isNotEmpty == true,
                icon: Icons.factory_rounded,
                label: "Nhà sản xuất",
                value: item.manufacturerName,
              ),

              _buildInfoRow(
                visible: item.countryName?.isNotEmpty == true,
                icon: Icons.public_rounded,
                label: "Nước SX",
                value: item.countryName,
              ),

              _buildInfoRow(
                visible: item.supplierActualName?.isNotEmpty == true,
                icon: Icons.store_rounded,
                label: "NCC thực tế",
                value: item.supplierActualName,
              ),

              _buildInfoRow(
                visible: item.supplierName?.isNotEmpty == true,
                icon: Icons.description_rounded,
                label: "NCC giấy tờ",
                value: item.supplierName,
              ),

              _buildInfoRow(
                visible: item.remark?.isNotEmpty == true,
                icon: Icons.notes_rounded,
                label: "Ghi chú",
                value: item.remark,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required bool visible,
    required IconData icon,
    required String label,
    String? value,
    Color? color,
    TextStyle? style,
  }) {
    if (!visible || value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final defaultColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? defaultColor.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110, // điều chỉnh theo thiết kế của bạn
            child: Text(
              "$label:",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                color: defaultColor,
                height: 1.35,
              ).merge(style),
            ),
          ),
        ],
      ),
    );
  }
}