import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/ChangeSystemDialog.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/SearchTextHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/DanhMucScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/DmvtDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/MaterialBulkImportScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/MaterialFormScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/ScanMaterialScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/screen/WarehouseListScreen.screen.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DmvtService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/FullScreenImageViewer.widget.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);
const String _kAllCategory = 'Tất cả';

class NewWarehouseHomeScreen extends StatefulWidget {
  const NewWarehouseHomeScreen({super.key});

  @override
  State<NewWarehouseHomeScreen> createState() => _NewWarehouseHomeScreenState();
}

class _NewWarehouseHomeScreenState extends State<NewWarehouseHomeScreen> {
  final DmvtService _dmvtService = DmvtService();
  final TextEditingController _searchController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  final FunctionConvertHelper _convertHelper = FunctionConvertHelper();

  bool _isLoading = true;
  String? _errorMessage;
  List<Dmvt> _items = [];
  String _selectedCategory = _kAllCategory;
  bool? _isInternalNetwork;

  @override
  void initState() {
    super.initState();
    _loadDmvt();
    _checkNetwork();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _checkNetwork() async {
    try {
      final result = await _apiClient.isInternalNetwork();
      if (mounted) setState(() => _isInternalNetwork = result);
    } catch (_) {
      if (mounted) setState(() => _isInternalNetwork = false);
    }
  }

  /// Ảnh vật tư trả về IP nội bộ (192.168.1.54) — chỉ giữ nguyên khi thiết bị
  /// đang ở mạng LAN, còn lại tự đổi sang IP public; đồng thời percent-encode
  /// URL (khoảng trắng, tên file tiếng Việt) để tải được ảnh.
  String _resolveImageUrl(String url) {
    return _convertHelper.resolveNetworkUrl(url, _isInternalNetwork == true);
  }

  List<String> _imagesOf(Dmvt item) {
    return [item.img1, item.img2, item.img3]
        .whereType<String>()
        .where((url) => url.trim().isNotEmpty)
        .map(_resolveImageUrl)
        .toList();
  }

  void _openImages(Dmvt item) {
    final images = _imagesOf(item);
    if (images.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vật tư chưa có ảnh nào')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(urls: images),
      ),
    );
  }

  void _showItemActionSheet(Dmvt item) {
    final imageCount = _imagesOf(item).length;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  item.tenVt.isNotEmpty ? item.tenVt : item.maVt,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: _kPrimaryColor,
                ),
                title: Text(
                  imageCount > 0 ? 'Xem ảnh ($imageCount)' : 'Chưa có ảnh nào',
                ),
                enabled: imageCount > 0,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openImages(item);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDmvt() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _dmvtService.getAllDmvt();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result["isSuccess"] == true) {
        _items = result["body"] as List<Dmvt>;
      } else {
        _errorMessage =
            'Không tải được danh mục vật tư (mã lỗi: ${result["statusCode"]})';
      }
    });
  }

  List<String> get _categories {
    final set = <String>{};
    for (final item in _items) {
      final segment = (item.segmentName ?? '').trim();
      if (segment.isNotEmpty) set.add(segment);
    }
    final list = set.toList()..sort();
    return [_kAllCategory, ...list];
  }

  List<Dmvt> get _visibleItems {
    final query = _searchController.text;

    return _items.where((item) {
      if (_selectedCategory != _kAllCategory &&
          (item.segmentName ?? '').trim() != _selectedCategory) {
        return false;
      }

      return SearchTextHelper.matches(item.searchFields, query);
    }).toList();
  }

  Future<void> _openScan() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ScanMaterialScreen(items: _items),
      ),
    );
    if (changed == true) _loadDmvt();
  }

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Hệ thống kho mới',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.inventory_2_outlined,
                  color: _kPrimaryColor,
                ),
                title: const Text('Danh mục vật tư'),
                onTap: () => Navigator.pop(sheetContext),
              ),
              ListTile(
                leading: const Icon(
                  Icons.warehouse_rounded,
                  color: _kPrimaryColor,
                ),
                title: const Text('Chọn kho / Tồn kho'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WarehouseListScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.upload_file_rounded,
                  color: _kPrimaryColor,
                ),
                title: const Text('Thêm hàng loạt vật tư (Excel)'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final imported = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaterialBulkImportScreen(),
                    ),
                  );
                  if (imported == true) _loadDmvt();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.menu_book_rounded,
                  color: _kPrimaryColor,
                ),
                title: const Text('Danh mục tra cứu (phụ lục)'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DanhMucScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  kChangeSystemIcon,
                  color: kChangeSystemColor,
                ),
                title: const Text(
                  'Đổi hệ thống',
                  style: TextStyle(color: kChangeSystemColor),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showChangeSystemDialog(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openCategoryFilterSheet() {
    final categories = _categories;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Lọc theo nhóm vật tư',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              for (final category in categories)
                RadioListTile<String>(
                  title: Text(category),
                  value: category,
                  groupValue: _selectedCategory,
                  activeColor: _kPrimaryColor,
                  onChanged: (value) {
                    if (value != null)
                      setState(() => _selectedCategory = value);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Danh mục vật tư'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: 'Quét mã vật tư',
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.black87,
            ),
            onPressed: _items.isEmpty ? null : _openScan,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Menu',
              icon: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
              onPressed: _openMainMenu,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _kPrimaryColor,
        onRefresh: _loadDmvt,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const MaterialFormScreen()),
          );
          if (created == true) _loadDmvt();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kPrimaryColor),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    }

    final categories = _categories;
    final visibleItems = _visibleItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        if (categories.length > 1) _buildCategoryChips(categories),
        _buildResultCount(visibleItems.length),
        Expanded(
          child: visibleItems.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Text(
                          _items.isEmpty
                              ? 'Không có dữ liệu'
                              : 'Không tìm thấy vật tư phù hợp',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: visibleItems.length,
                  itemBuilder: (context, index) {
                    final item = visibleItems[index];
                    return _DmvtListItem(
                      item: item,
                      styleIndex: index,
                      resolveImageUrl: _resolveImageUrl,
                      onTap: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DmvtDetailScreen(item: item),
                          ),
                        );
                        if (changed == true) _loadDmvt();
                      },
                      onLongPress: () => _showItemActionSheet(item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Tìm theo mã, tên, danh điểm...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () => _searchController.clear(),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _openCategoryFilterSheet,
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kPrimaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedCategory = category),
            selectedColor: _kPrimaryColor,
            backgroundColor: Colors.white,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCount(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Icon(Icons.list_alt_rounded, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            'Tìm thấy $count vật tư',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ItemStyle {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _ItemStyle(this.icon, this.bgColor, this.iconColor);
}

class _DmvtListItem extends StatelessWidget {
  final Dmvt item;
  final int styleIndex;
  final String Function(String url) resolveImageUrl;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DmvtListItem({
    required this.item,
    required this.styleIndex,
    required this.resolveImageUrl,
    required this.onTap,
    required this.onLongPress,
  });

  static const List<_ItemStyle> _stylePalette = [
    _ItemStyle(Icons.adjust_rounded, Color(0xFFEDE9FE), Color(0xFF7C6FEF)),
    _ItemStyle(Icons.crop_square_rounded, Color(0xFFFFF3E0), Color(0xFFFFA726)),
    _ItemStyle(
      Icons.view_headline_rounded,
      Color(0xFFE0F2F1),
      Color(0xFF26A69A),
    ),
    _ItemStyle(Icons.hexagon_outlined, Color(0xFFFCE4EC), Color(0xFFEC407A)),
  ];

  static const Map<String, Color> _unitColors = {
    'Bộ': Color(0xFFFFA726),
    'Cái': Color(0xFF42A5F5),
  };

  String get _danhDiem {
    if (item.danhDiemdd.trim().isNotEmpty) return item.danhDiemdd.trim();
    if (item.danhDiemg.trim().isNotEmpty) return item.danhDiemg.trim();
    return item.danhDiemc.trim();
  }

  String get _vehicleTag {
    final hang = item.hangXe.trim();
    final dong = item.dongXe.trim();
    if (hang.isEmpty) return dong;
    if (dong.isEmpty) return hang;
    return '$hang $dong';
  }

  String get _manufacturerLine {
    final hangSx = (item.tenHang?.trim().isNotEmpty ?? false)
        ? item.tenHang!.trim()
        : item.hangSx.trim();
    final nuoc = (item.tenNuoc?.trim().isNotEmpty ?? false)
        ? item.tenNuoc!.trim()
        : item.ncSx.trim();
    if (hangSx.isEmpty) return nuoc;
    if (nuoc.isEmpty) return hangSx;
    return '$hangSx - $nuoc';
  }

  String get _supplierLine {
    return (item.tenKh?.trim().isNotEmpty ?? false)
        ? item.tenKh!.trim()
        : item.ncc.trim();
  }

  String get _manufacturerAndSupplierLine {
    final supplier = _supplierLine;
    return [
      _manufacturerLine,
      if (supplier.isNotEmpty) 'NCC: $supplier',
    ].where((s) => s.isNotEmpty).join(' • ');
  }

  Widget _buildLeadingAvatar(_ItemStyle style) {
    final imageUrl = item.img1?.trim();
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildStyleAvatar(style);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        resolveImageUrl(imageUrl),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildStyleAvatar(style),
      ),
    );
  }

  Widget _buildStyleAvatar(_ItemStyle style) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(style.icon, color: style.iconColor, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _stylePalette[styleIndex % _stylePalette.length];
    final unitColor = _unitColors[item.dvt.trim()] ?? Colors.blueGrey;
    final vehicleTag = _vehicleTag;
    final danhDiem = _danhDiem;
    final manufacturerAndSupplierLine = _manufacturerAndSupplierLine;
    final thongSo = item.thongSo.trim();
    final hsCode = item.hsCode.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeadingAvatar(style),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.maVt,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.dvt.trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: unitColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.dvt,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: unitColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.tenVt.isNotEmpty ? item.tenVt : '(Chưa có tên)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (thongSo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        thongSo,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (manufacturerAndSupplierLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        manufacturerAndSupplierLine,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (vehicleTag.isNotEmpty ||
                        danhDiem.isNotEmpty ||
                        hsCode.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (vehicleTag.isNotEmpty)
                            _TagChip(
                              icon: Icons.directions_car_filled_rounded,
                              label: vehicleTag,
                            ),
                          if (danhDiem.isNotEmpty)
                            _TagChip(prefixText: 'DĐ', label: danhDiem),
                          if (hsCode.isNotEmpty)
                            _TagChip(prefixText: 'HS', label: hsCode),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData? icon;
  final String? prefixText;
  final String label;

  const _TagChip({this.icon, this.prefixText, required this.label});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: Colors.grey.shade700),
              const SizedBox(width: 4),
            ],
            if (prefixText != null) ...[
              Text(
                prefixText!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
