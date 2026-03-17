import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/GenerateCodeAID.helper.dart';
import 'package:phuthanh_warehouseapp/helper/ImagePickerHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/WareHouseService.service.dart';
import 'package:collection/collection.dart';

class CartDetailScreen extends StatefulWidget {
  final Cart item;
  final bool isCreate;
  final bool isUpdate;
  final bool readOnly;

  const CartDetailScreen({
    super.key,
    required this.item,
    this.isCreate = false,
    this.isUpdate = false,
    this.readOnly = false,
  });

  @override
  State<CartDetailScreen> createState() => _CartDetailScreenState();
}

class _CartDetailScreenState extends State<CartDetailScreen> {
  // ── Services & Helpers ───────────────────────────────────────────────
  final InfoService infoService = InfoService();
  final Warehouseservice warehouseService = Warehouseservice();
  final Formatdatehelper formatdatehelper = Formatdatehelper();
  final NavigationHelper nav = NavigationHelper();
  final MySharedPreferences prefs = MySharedPreferences();
  final ImagePickerHelper imageHelper = ImagePickerHelper();
  final CodeHelper generateCodeAID = CodeHelper();

  // ── Controllers ──────────────────────────────────────────────────────
  final TextEditingController _cartIDCtrl = TextEditingController();
  final TextEditingController _fullnameCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController();
  final TextEditingController _remarkCtrl = TextEditingController();

  // ── Date fields ──────────────────────────────────────────────────────
  DateTime? _oderTime;

  // ── Dropdown data ────────────────────────────────────────────────────
  List<Supplier> suppliers = [];
  Supplier? selectedSupplier;

  // ── State ────────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Fill controllers
    _cartIDCtrl.text = widget.item.cartID ?? '';
    _fullnameCtrl.text = widget.item.fullName ?? '';
    _statusCtrl.text = widget.item.status ?? '';
    _remarkCtrl.text = widget.item.remark ?? '';

    _initAsync();
  }

  Future<void> _initAsync() async {
    if (widget.isCreate) {
      _cartIDCtrl.text = generateCodeAID.generateCodeCart();

      final fullName = await _getCurrentUserFullName(); // ✅ await
      _fullnameCtrl.text = fullName ?? '';
    }

    await _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    try {
      final suppList = await infoService.LoadDtataSupplier();
      setState(() {
        suppliers = suppList;
        selectedSupplier = suppliers.firstWhereOrNull(
          (s) => s.SupplierID == widget.item.partner,
        );
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi load suppliers: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _getCurrentUserFullName() async {
    final account = await prefs.getDataObject("account");
    return account?["FullName"] as String?;
  }

  // Future<int?> _getCurrentUserID() async {
  //   final account = await prefs.getDataObject("account");
  //   return account?["FullName"] as String?;
  // }

  Future<void> _saveGuarantee() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Chuẩn bị object Guarantee
      final cartCreate = widget.item.copyWith(
        cartID: _cartIDCtrl.text.trim(),
        accountID: 0,
        partner: selectedSupplier?.SupplierID ?? 0,
        status: 'PENDING',
        remark: _remarkCtrl.text,
        orderTime: _oderTime,
        lastTime: formatdatehelper.toSqlDateTime(DateTime.now()),
      );
      print(jsonEncode(cartCreate));

      if (widget.isCreate) {
        // Kiểm tra mã trùng (nếu backend hỗ trợ)
        final checkPayload = jsonEncode({"Cart": cartCreate.cartID});
        final exists = await infoService.checkProductID(
          "Cart",
          checkPayload,
        ); // giả định hàm này dùng chung
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mã phiếu bảo hành đã tồn tại!")),
          );
          return;
        } else {
          final response = await warehouseService.addWarehouseRow(
            "Cart",
            jsonEncode(cartCreate),
          );
          if (response["statusCode"] == 403 ||
              response["statusCode"] == 401 ||
              response["statusCode"] == 0) {
            // nav.pushAndRemoveUntil(context, const Loginscreen());

            return;
          }

          if (response["isSuccess"]) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Thêm mới thành công'),
                duration: const Duration(milliseconds: 500),
              ),
            );
            nav.pop(context, true); // quay lại và báo màn trước refresh
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Lỗi thêm mới: '),
                duration: const Duration(milliseconds: 500),
              ),
            );
          }
        }

        // response = await warehouseService.addWarehouseRow("Guarantee", jsonEncode(jsonBody));
      }
      // if (widget.isUpdate) {
      //   print(jsonEncode(guaranteeUpdate));

      //   final response = await warehouseService.upDateGuarantee(
      //     "Guarantee",
      //     widget.item.guaranteeAID.toString(),
      //     jsonEncode(guaranteeUpdate),
      //   );
      //   if (response["statusCode"] == 403 ||
      //       response["statusCode"] == 401 ||
      //       response["statusCode"] == 0) {
      //     nav.pushAndRemoveUntil(context, const Loginscreen());

      //     return;
      //   }

      //   if (response["isSuccess"]) {
      //     if (!mounted) return;
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('✅ Cập nhật thành công'),
      //         duration: const Duration(milliseconds: 500),
      //       ),
      //     );
      //     nav.pop(context, true); // quay lại và báo màn trước refresh
      //   } else {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('❌ Lỗi cập nhật: '),
      //         duration: const Duration(milliseconds: 500),
      //       ),
      //     );
      //   }

      // }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi lưu: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required Function(DateTime) onPicked,
    // String title = "Chọn ngày",
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      onPicked(picked);
      setState(() {});
    }
  }

  Widget _buildDateTile(String label, DateTime? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: widget.readOnly ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        child: Text(
          value != null ? formatdatehelper.formatDMY(value) : "Chưa chọn",
          style: TextStyle(color: value == null ? Colors.grey : null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isSaving) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Đang lưu phiếu bảo hành..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCreate
              ? "Thêm phiếu đơn hàng"
              : widget.item.cartID?.isNotEmpty == true
              ? "Phiếu ${widget.item.cartID}"
              : "Chi tiết đơn hàng",
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thông tin phiếu ───────────────────────────────────────
            CustomTextField(
              label: "Mã phiếu bảo hành *",
              controller: _cartIDCtrl,
              readOnly: true,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: "Người tạo phiếu",
              controller: _fullnameCtrl,
              readOnly: true,
            ),

            const Divider(height: 32),
            Text(
              "Sản phẩm hỏng / khiếu nại",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            _buildDateTile(
              "Ngày Oder",
              _oderTime,
              () =>
                  _pickDate(initial: _oderTime, onPicked: (d) => _oderTime = d),
            ),
            const SizedBox(height: 24),
            Text(
              "Nhà cung cấp / Đối tác",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            CustomDropdownField<Supplier>(
              label: "Nhà cung cấp",
              selectedValue: selectedSupplier,
              items: suppliers,
              getLabel: (s) => s.Name.toString(),
              onChanged: (v) => setState(() => selectedSupplier = v),
              isSearch: true,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 16),

            // ── Ghi chú & Hình ảnh ────────────────────────────────────
            const Divider(height: 32),
            Text(
              "Ghi chú & Minh chứng",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: "Ghi chú",
              controller: _remarkCtrl,
              // maxLines: 4,
              readOnly: widget.readOnly,
            ),

            const SizedBox(height: 40),

            // ── Action buttons ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  onPressed:
                      (widget.isCreate || widget.isUpdate) &&
                          !_isSaving &&
                          !widget.readOnly
                      ? _saveGuarantee
                      : null,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? "Đang lưu..." : "Lưu phiếu"),
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Quay lại"),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cartIDCtrl.dispose();
    _fullnameCtrl.dispose();
    _statusCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }
}
