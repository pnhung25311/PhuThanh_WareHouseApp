import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/DanhMuc.model.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DanhMucService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DmvtService.service.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/widget/SearchableDropdownField.widget.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Thêm mới / sửa 1 vật tư. `ma_vt` là duy nhất toàn hệ thống và không được
/// sửa sau khi tạo (business rule server), nên khi sửa ô này bị khoá.
class MaterialFormScreen extends StatefulWidget {
  final Dmvt? initial;

  const MaterialFormScreen({super.key, this.initial});

  bool get isEditing => initial != null;

  @override
  State<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DmvtService _dmvtService = DmvtService();
  final DanhMucService _danhMucService = DanhMucService();
  final ApiClient _apiClient = ApiClient();
  final FunctionConvertHelper _convertHelper = FunctionConvertHelper();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _maVtController;
  late final TextEditingController _tenVtController;
  late final TextEditingController _dvtController;
  late final TextEditingController _danhDiemgController;
  late final TextEditingController _danhDiemddController;
  late final TextEditingController _danhDiemcController;
  late final TextEditingController _thongSoController;
  late final TextEditingController _dongXeController;
  late final TextEditingController _hsCodeController;
  late final TextEditingController _ghiChuController;

  bool _isLoadingLookups = true;
  bool _isSaving = false;
  String? _errorMessage;
  bool? _isInternalNetwork;

  List<Manufacturer> _manufacturers = [];
  List<Country> _countries = [];
  List<Customer> _customers = [];
  List<VehicleBrand> _vehicleBrands = [];

  Manufacturer? _selectedManufacturer;
  Country? _selectedCountry;
  Customer? _selectedCustomer;
  VehicleBrand? _selectedVehicleBrand;

  // 3 ô ảnh: ảnh mới chọn/chụp (chưa upload) và ảnh đã có sẵn (khi sửa).
  final List<File?> _newImages = [null, null, null];
  final List<String?> _existingImageUrls = [null, null, null];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _maVtController = TextEditingController(text: initial?.maVt ?? '');
    _tenVtController = TextEditingController(text: initial?.tenVt ?? '');
    _dvtController = TextEditingController(text: initial?.dvt ?? '');
    _danhDiemgController = TextEditingController(
      text: initial?.danhDiemg ?? '',
    );
    _danhDiemddController = TextEditingController(
      text: initial?.danhDiemdd ?? '',
    );
    _danhDiemcController = TextEditingController(
      text: initial?.danhDiemc ?? '',
    );
    _thongSoController = TextEditingController(text: initial?.thongSo ?? '');
    _dongXeController = TextEditingController(text: initial?.dongXe ?? '');
    _hsCodeController = TextEditingController(text: initial?.hsCode ?? '');
    _ghiChuController = TextEditingController(text: initial?.ghiChu ?? '');
    _existingImageUrls[0] = initial?.img1;
    _existingImageUrls[1] = initial?.img2;
    _existingImageUrls[2] = initial?.img3;
    _checkNetwork();
    _loadLookups();
  }

  @override
  void dispose() {
    _maVtController.dispose();
    _tenVtController.dispose();
    _dvtController.dispose();
    _danhDiemgController.dispose();
    _danhDiemddController.dispose();
    _danhDiemcController.dispose();
    _thongSoController.dispose();
    _dongXeController.dispose();
    _hsCodeController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _checkNetwork() async {
    try {
      final result = await _apiClient.isInternalNetwork();
      if (mounted) setState(() => _isInternalNetwork = result);
    } catch (_) {
      if (mounted) setState(() => _isInternalNetwork = false);
    }
  }

  String _resolveUrl(String url) {
    return _convertHelper.resolveNetworkUrl(url, _isInternalNetwork == true);
  }

  Future<void> _loadLookups() async {
    setState(() {
      _isLoadingLookups = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      _danhMucService.getAllHangSx(),
      _danhMucService.getAllNuocSx(),
      _danhMucService.getAllKhachHang(),
      _danhMucService.getAllHangXe(),
    ]);

    if (!mounted) return;

    final failed = results.where((r) => r["isSuccess"] != true).toList();

    setState(() {
      _isLoadingLookups = false;
      _manufacturers = results[0]["body"] as List<Manufacturer>;
      _countries = results[1]["body"] as List<Country>;
      _customers = results[2]["body"] as List<Customer>;
      _vehicleBrands = results[3]["body"] as List<VehicleBrand>;

      if (failed.isNotEmpty) {
        _errorMessage =
            'Không tải được đầy đủ danh mục tra cứu, vui lòng thử lại.';
      }

      final initial = widget.initial;
      if (initial != null) {
        _selectedManufacturer = _firstWhereOrNull(
          _manufacturers,
          (m) => m.maHang == initial.hangSx.trim(),
        );
        _selectedCountry = _firstWhereOrNull(
          _countries,
          (c) => c.maNuoc == initial.ncSx.trim(),
        );
        _selectedCustomer = _firstWhereOrNull(
          _customers,
          (k) => k.maKh == initial.ncc.trim(),
        );
        _selectedVehicleBrand = _firstWhereOrNull(
          _vehicleBrands,
          (v) => v.maHangxe == initial.hangXe.trim(),
        );
      }
    });
  }

  T? _firstWhereOrNull<T>(List<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage(int slot) async {
    final hasImage =
        _newImages[slot] != null ||
        (_existingImageUrls[slot]?.trim().isNotEmpty ?? false);

    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.blue,
                ),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(sheetContext, 'camera'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.purple,
                ),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(sheetContext, 'gallery'),
              ),
              if (hasImage)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text('Xóa ảnh'),
                  onTap: () => Navigator.pop(sheetContext, 'remove'),
                ),
            ],
          ),
        );
      },
    );

    if (action == null) return;

    if (action == 'remove') {
      setState(() {
        _newImages[slot] = null;
        _existingImageUrls[slot] = null;
      });
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _newImages[slot] = File(picked.path);
        _existingImageUrls[slot] = null;
      });
    } catch (e) {
      _showSnackBar('Không thể chọn ảnh: $e', isError: true);
    }
  }

  Dmvt _buildMaterial({
    required int aid,
    String? img1,
    String? img2,
    String? img3,
  }) {
    return Dmvt(
      aid: aid,
      maVt: _maVtController.text.trim(),
      tenVt: _tenVtController.text.trim(),
      dvt: _dvtController.text.trim(),
      danhDiemg: _danhDiemgController.text.trim(),
      danhDiemdd: _danhDiemddController.text.trim(),
      danhDiemc: _danhDiemcController.text.trim(),
      thongSo: _thongSoController.text.trim(),
      hangSx: _selectedManufacturer?.maHang ?? '',
      tenHang: _selectedManufacturer?.tenHang,
      ncSx: _selectedCountry?.maNuoc ?? '',
      tenNuoc: _selectedCountry?.tenNuoc,
      ncc: _selectedCustomer?.maKh ?? '',
      tenKh: _selectedCustomer?.tenKh,
      hangXe: _selectedVehicleBrand?.maHangxe ?? '',
      tenHangxe: _selectedVehicleBrand?.tenHangxe,
      dongXe: _dongXeController.text.trim(),
      hsCode: _hsCodeController.text.trim(),
      ghiChu: _ghiChuController.text.trim(),
      img1: img1,
      img2: img2,
      img3: img3,
    );
  }

  /// Upload ảnh mới (nếu có) cho vật tư mã `maVt` rồi trả về URL cuối cùng
  /// cho 1 ô ảnh; giữ nguyên URL cũ nếu người dùng không đổi, `null` nếu ô
  /// ảnh bị xóa. `maVt` không phụ thuộc vào việc vật tư đã được tạo hay chưa.
  Future<String?> _resolveImageForSubmit(String maVt, int slot) async {
    final newFile = _newImages[slot];
    if (newFile == null) {
      final existing = _existingImageUrls[slot];
      return (existing != null && existing.trim().isNotEmpty) ? existing : null;
    }

    final result = await _dmvtService.uploadImage(maVt, newFile, slot + 1);
    if (result["isSuccess"] != true) {
      throw Exception(result["message"]?.toString() ?? 'Tải ảnh lên thất bại');
    }
    return result["url"].toString();
  }

  String _saveErrorMessage(Map<String, dynamic> result, String maVt) {
    final statusCode = result["statusCode"];
    return statusCode == 409 || statusCode == 400
        ? 'Mã vật tư "$maVt" đã tồn tại hoặc không hợp lệ.'
        : (result["message"]?.toString() ??
              'Lưu vật tư thất bại (mã lỗi: $statusCode)');
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final maVt = _maVtController.text.trim();

    try {
      final img1 = await _resolveImageForSubmit(maVt, 0);
      final img2 = await _resolveImageForSubmit(maVt, 1);
      final img3 = await _resolveImageForSubmit(maVt, 2);

      final material = _buildMaterial(
        aid: widget.initial?.aid ?? 0,
        img1: img1,
        img2: img2,
        img3: img3,
      );

      final result = widget.isEditing
          ? await _dmvtService.updateMaterial(widget.initial!.aid, material)
          : await _dmvtService.createMaterial(material);

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (result["isSuccess"] == true) {
        Navigator.pop(context, true);
      } else {
        _showSnackBar(_saveErrorMessage(result, material.maVt), isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar('Lỗi khi lưu vật tư: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa vật tư' : 'Thêm vật tư mới'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoadingLookups
          ? const Center(
              child: CircularProgressIndicator(color: _kPrimaryColor),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildImageRow(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _maVtController,
                    label: 'Mã vật tư *',
                    enabled: !widget.isEditing,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Bắt buộc nhập'
                        : null,
                  ),
                  _buildTextField(
                    controller: _tenVtController,
                    label: 'Tên vật tư *',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Bắt buộc nhập'
                        : null,
                  ),
                  _buildTextField(
                    controller: _dvtController,
                    label: 'Đơn vị tính (DVT)',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _danhDiemgController,
                          label: 'Danh điểm g',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _danhDiemddController,
                          label: 'Danh điểm dd',
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    controller: _danhDiemcController,
                    label: 'Danh điểm c',
                  ),
                  _buildTextField(
                    controller: _thongSoController,
                    label: 'Thông số kỹ thuật',
                    maxLines: 2,
                  ),
                  _buildDropdown<Manufacturer>(
                    label: 'Hãng sản xuất',
                    items: _manufacturers,
                    value: _selectedManufacturer,
                    labelOf: (m) => '${m.maHang} - ${m.tenHang}',
                    onChanged: (v) => setState(() => _selectedManufacturer = v),
                  ),
                  _buildDropdown<Country>(
                    label: 'Nước sản xuất',
                    items: _countries,
                    value: _selectedCountry,
                    labelOf: (c) => '${c.maNuoc} - ${c.tenNuoc}',
                    onChanged: (v) => setState(() => _selectedCountry = v),
                  ),
                  _buildDropdown<Customer>(
                    label: 'Nhà cung cấp',
                    items: _customers,
                    value: _selectedCustomer,
                    labelOf: (k) => '${k.maKh} - ${k.tenKh}',
                    onChanged: (v) => setState(() => _selectedCustomer = v),
                  ),
                  _buildDropdown<VehicleBrand>(
                    label: 'Hãng xe',
                    items: _vehicleBrands,
                    value: _selectedVehicleBrand,
                    labelOf: (v) => '${v.maHangxe} - ${v.tenHangxe}',
                    onChanged: (v) => setState(() => _selectedVehicleBrand = v),
                  ),
                  _buildTextField(
                    controller: _dongXeController,
                    label: 'Dòng xe',
                  ),
                  _buildTextField(
                    controller: _hsCodeController,
                    label: 'HS Code',
                  ),
                  _buildTextField(
                    controller: _ghiChuController,
                    label: 'Ghi chú',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isSaving || _isLoadingLookups ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.isEditing ? 'LƯU THAY ĐỔI' : 'THÊM VẬT TƯ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageRow() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 10 : 0),
            child: _buildImageSlot(index),
          ),
        );
      }),
    );
  }

  Widget _buildImageSlot(int index) {
    final newFile = _newImages[index];
    final existingUrl = _existingImageUrls[index]?.trim();

    Widget content;
    if (newFile != null) {
      content = Image.file(
        newFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      content = Image.network(
        _resolveUrl(existingUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
      );
    } else {
      content = Icon(
        Icons.add_a_photo_outlined,
        color: Colors.grey.shade400,
        size: 28,
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: () => _pickImage(index),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SearchableDropdownField<T>(
        label: label,
        value: value,
        items: items,
        labelOf: labelOf,
        onChanged: onChanged,
      ),
    );
  }
}
