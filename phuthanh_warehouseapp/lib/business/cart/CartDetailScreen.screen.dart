import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/service/BusinessService.service.dart';
import 'package:phuthanh_warehouseapp/business/service/CartService.service.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/formatters/DotToMinusFormatte.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/GenerateCodeAID.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/WareHouseService.service.dart';

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
  final _formKey = GlobalKey<FormState>();

  final InfoService infoService = InfoService();
  final Warehouseservice warehouseService = Warehouseservice();
  final CartService cartService = CartService();
  final Businessservice businessservice = Businessservice();
  final Formatdatehelper formatdatehelper = Formatdatehelper();
  final NavigationHelper nav = NavigationHelper();
  final MySharedPreferences prefs = MySharedPreferences();
  final CodeHelper generateCodeAID = CodeHelper();

  final TextEditingController _cartIDCtrl = TextEditingController();
  final TextEditingController _fullnameCtrl = TextEditingController();
  final TextEditingController _productIDCtrl = TextEditingController();
  final TextEditingController _productNameCtrl = TextEditingController();
  final TextEditingController _productPartNoCtrl = TextEditingController();
  final TextEditingController _productManufacturerCtrl =
      TextEditingController();
  final TextEditingController _productCountryCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _remarkCtrl = TextEditingController();

  DateTime? _deliveryTime;

  List<Supplier> suppliers = [];
  Supplier? selectedSupplier;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _cartIDCtrl.text = widget.item.cartID ?? '';
    _fullnameCtrl.text = widget.item.fullName ?? '';
    _productIDCtrl.text = widget.item.productID?.toString() ?? '';
    _productNameCtrl.text = widget.item.nameProduct ?? '';
    _productPartNoCtrl.text = widget.item.idPartNo ?? '';
    _qtyCtrl.text = widget.item.qty?.toString() ?? '';
    _remarkCtrl.text = widget.item.remark ?? '';
    _productManufacturerCtrl.text = widget.item.manufacturerName ?? '';
    _productCountryCtrl.text = widget.item.countryName ?? '';

    _deliveryTime = widget.item.deliveryTime ?? DateTime.now();

    _initAsync();
    _txtListener();
  }

  Future<void> _initAsync() async {
    if (widget.isCreate) {
      _cartIDCtrl.text = generateCodeAID.generateCodeCart();
      _fullnameCtrl.text = await _getCurrentUserFullName() ?? '';
    }
    await _loadData();
  }

  Future<void> _loadData() async {
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
      _showError("Lỗi load supplier");
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _getCurrentUserFullName() async {
    final acc = await prefs.getDataObject("account");
    return acc?["FullName"];
  }

  Future<int?> _getCurrentUserID() async {
    final acc = await prefs.getDataObject("account");
    return acc?["AccountID"];
  }

  // ================= SAVE =================
  Future<void> _saveCart() async {
    if (!_formKey.currentState!.validate()) return;

    if (_productIDCtrl.text.trim().isEmpty) {
      _showError("Nhập mã sản phẩm");
      return;
    }

    if (selectedSupplier == null) {
      _showError("Chọn nhà cung cấp");
      return;
    }

    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final accountID = await _getCurrentUserID();

      int? proAID = await infoService.reTurnAID(
        "Product",
        "ProductAID",
        "ProductID",
        _productIDCtrl.text.trim(),
      );

      final cart = widget.item.copyWith(
        cartID: _cartIDCtrl.text.trim(),
        accountID: accountID,
        productAID: proAID ?? 0,
        qty: double.tryParse(_qtyCtrl.text) ?? 0,
        partner: selectedSupplier!.SupplierID,
        status: widget.isCreate ? false : (widget.item.status ?? false),
        remark: _remarkCtrl.text.trim(),
        deliveryTime: _deliveryTime,
        lastTime: DateTime.now(),
      );

      final body = jsonEncode(cart.toJson());
      print("SEND: $body");

      Map response;

      if (widget.isCreate) {
        response = await cartService.addCart(body);
      } else {
        response = await businessservice.upDateCart(
          "Cart",
          widget.item.cartAID.toString(),
          body,
        );
      }

      if (_isAuthError(response)) return;

      if (response["isSuccess"]) {
        _showSuccess(
          widget.isCreate ? "✅ Thêm thành công" : "✅ Cập nhật thành công",
        );
      } else {
        _showError("❌ Lưu thất bại");
      }
    } catch (e) {
      _showError("Lỗi: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _isAuthError(Map res) {
    if ([0, 401, 403].contains(res["statusCode"])) {
      nav.pushAndRemoveUntil(context, const Loginscreen());
      return true;
    }
    return false;
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(milliseconds: 500)),
    );
    nav.pop(context, true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _txtListener() async {
    _productIDCtrl.addListener(() async {
      final proBroken = await infoService.findProduct(
        _productIDCtrl.text.trim(),
      );
      final Product pro = proBroken["body"];
      _productNameCtrl.text = pro.nameProduct;
      _productPartNoCtrl.text = pro.idPartNo;
      _productCountryCtrl.text = pro.countryName ?? '';
      _productManufacturerCtrl.text = pro.manufacturerName ?? '';
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => _deliveryTime = picked);
    }
  }

  Widget _buildDate() {
    return GestureDetector(
      onTap: widget.readOnly ? null : _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Ngày giao hàng *",
          border: OutlineInputBorder(),
        ),
        child: Text(
          _deliveryTime != null
              ? formatdatehelper.formatDMY(_deliveryTime!)
              : "Chưa chọn",
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveCart,
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(widget.isCreate ? "Lưu" : "Lưu"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreate ? "Thêm đơn hàng" : "Chi tiết đơn hàng"),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                children: [
                  _buildSection(
                    title: "Sản phẩm",
                    children: [
                      CustomTextField(
                        label: "Mã sản phẩm",
                        controller: _productIDCtrl,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Tên sản phẩm",
                        controller: _productNameCtrl,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Danh điểm",
                        controller: _productPartNoCtrl,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Hãng SX",
                        controller: _productManufacturerCtrl,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Nước SX",
                        controller: _productCountryCtrl,
                        readOnly: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildSection(
                    title: "Đơn hàng",
                    children: [
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Người tạo",
                        controller: _fullnameCtrl,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: "Số lượng",
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [DotToMinusFormatter()],
                      ),
                      const SizedBox(height: 12),
                      _buildDate(),
                      const SizedBox(height: 12),

                      CustomDropdownField<Supplier>(
                        label: "Chọn NCC",
                        selectedValue: selectedSupplier,
                        items: suppliers,
                        getLabel: (s) => s.Name.toString(),
                        onChanged: (v) => setState(() => selectedSupplier = v),
                        isSearch: true,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        label: "Ghi chú",
                        controller: _remarkCtrl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cartIDCtrl.dispose();
    _fullnameCtrl.dispose();
    _productIDCtrl.dispose();
    _productNameCtrl.dispose();
    _productPartNoCtrl.dispose();
    _qtyCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }
}
