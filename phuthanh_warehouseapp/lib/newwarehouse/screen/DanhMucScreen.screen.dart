import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/SearchTextHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/DanhMuc.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DanhMucService.service.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Xem 4 danh mục tra cứu (phụ lục): hãng sản xuất, hãng xe, nước sản xuất,
/// khách hàng/nhà cung cấp — dữ liệu read-only, chỉ để tìm/xem, không sửa xoá.
class DanhMucScreen extends StatefulWidget {
  const DanhMucScreen({super.key});

  @override
  State<DanhMucScreen> createState() => _DanhMucScreenState();
}

class _DanhMucScreenState extends State<DanhMucScreen>
    with SingleTickerProviderStateMixin {
  final DanhMucService _service = DanhMucService();
  late final TabController _tabController;

  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  List<Manufacturer> _manufacturers = [];
  List<VehicleBrand> _vehicleBrands = [];
  List<Country> _countries = [];
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      _service.getAllHangSx(),
      _service.getAllHangXe(),
      _service.getAllNuocSx(),
      _service.getAllKhachHang(),
    ]);

    if (!mounted) return;

    final failed = results.where((r) => r["isSuccess"] != true).toList();

    setState(() {
      _isLoading = false;
      _manufacturers = results[0]["body"] as List<Manufacturer>;
      _vehicleBrands = results[1]["body"] as List<VehicleBrand>;
      _countries = results[2]["body"] as List<Country>;
      _customers = results[3]["body"] as List<Customer>;
      if (failed.isNotEmpty) {
        _errorMessage = 'Không tải được đầy đủ danh mục, kéo xuống để tải lại.';
      }
    });
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final result = await _service.syncDanhMuc();

    if (!mounted) return;
    setState(() => _isSyncing = false);

    if (result["isSuccess"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đồng bộ danh mục thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadAll();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"]?.toString() ??
                'Đồng bộ thất bại (mã lỗi: ${result["statusCode"]})',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Danh mục tra cứu'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Đồng bộ danh mục',
            onPressed: _isSyncing ? null : _handleSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kPrimaryColor,
                    ),
                  )
                : const Icon(Icons.sync_rounded, color: _kPrimaryColor),
          ),
        ],
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: _kPrimaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _kPrimaryColor,
          tabs: const [
            Tab(text: 'Hãng SX'),
            Tab(text: 'Hãng xe'),
            Tab(text: 'Nước SX'),
            Tab(text: 'Khách hàng/NCC'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _kPrimaryColor),
            )
          : RefreshIndicator(
              color: _kPrimaryColor,
              onRefresh: _loadAll,
              child: Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      color: Colors.red.shade50,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _CatalogListView<Manufacturer>(
                          items: _manufacturers,
                          searchText: (m) => '${m.maHang} ${m.tenHang}',
                          itemBuilder: (m) =>
                              _CatalogTile(code: m.maHang, title: m.tenHang),
                        ),
                        _CatalogListView<VehicleBrand>(
                          items: _vehicleBrands,
                          searchText: (v) => '${v.maHangxe} ${v.tenHangxe}',
                          itemBuilder: (v) => _CatalogTile(
                            code: v.maHangxe,
                            title: v.tenHangxe,
                          ),
                        ),
                        _CatalogListView<Country>(
                          items: _countries,
                          searchText: (c) => '${c.maNuoc} ${c.tenNuoc}',
                          itemBuilder: (c) =>
                              _CatalogTile(code: c.maNuoc, title: c.tenNuoc),
                        ),
                        _CatalogListView<Customer>(
                          items: _customers,
                          searchText: (k) =>
                              '${k.maKh} ${k.tenKh} ${k.tenKh2} ${k.diaChi}',
                          itemBuilder: (k) => _CatalogTile(
                            code: k.maKh,
                            title: k.tenKh,
                            subtitle: [
                              if (k.diaChi.isNotEmpty) k.diaChi,
                              if (k.dienThoai.isNotEmpty) 'ĐT: ${k.dienThoai}',
                            ].join(' • '),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CatalogListView<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) searchText;
  final Widget Function(T item) itemBuilder;

  const _CatalogListView({
    required this.items,
    required this.searchText,
    required this.itemBuilder,
  });

  @override
  State<_CatalogListView<T>> createState() => _CatalogListViewState<T>();
}

class _CatalogListViewState<T> extends State<_CatalogListView<T>> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    final query = _searchController.text;
    return widget.items
        .where(
          (item) => SearchTextHelper.matches([widget.searchText(item)], query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Tìm theo mã hoặc tên...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            '${filtered.length} mục',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Center(
                        child: Text(
                          widget.items.isEmpty
                              ? 'Không có dữ liệu'
                              : 'Không tìm thấy mục phù hợp',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      widget.itemBuilder(filtered[index]),
                ),
        ),
      ],
    );
  }
}

class _CatalogTile extends StatelessWidget {
  final String code;
  final String title;
  final String? subtitle;

  const _CatalogTile({required this.code, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          code.isNotEmpty ? code.substring(0, 1).toUpperCase() : '?',
          style: const TextStyle(
            color: _kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        title.isNotEmpty ? title : '(Chưa có tên)',
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          code,
          if (subtitle != null && subtitle!.isNotEmpty) subtitle!,
        ].join(' • '),
        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
