import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/SearchTextHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Warehouse.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/WarehouseInventoryScreen.screen.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Màn hình chọn kho đang thao tác — điểm vào cho các màn tồn kho, giao dịch,
/// chuyển kho phía sau. kho cố định (`kWarehouses`), mỗi kho có endpoint
/// tồn kho riêng — không còn gọi API để lấy danh sách kho.
class WarehouseListScreen extends StatefulWidget {
  const WarehouseListScreen({super.key});

  @override
  State<WarehouseListScreen> createState() => _WarehouseListScreenState();
}

class _WarehouseListScreenState extends State<WarehouseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Warehouse> get _filtered => kWarehouses
      .where((w) => SearchTextHelper.matches([w.tenKho, w.khoCode], _query))
      .toList();

  @override
  Widget build(BuildContext context) {
    final warehouses = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Chọn kho'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tìm kho theo tên hoặc mã...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPrimaryColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: warehouses.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy kho phù hợp',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : _buildList(warehouses),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Warehouse> warehouses) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      itemCount: warehouses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final warehouse = warehouses[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WarehouseInventoryScreen(warehouse: warehouse),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warehouse_rounded,
                      color: _kPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      warehouse.tenKho,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
