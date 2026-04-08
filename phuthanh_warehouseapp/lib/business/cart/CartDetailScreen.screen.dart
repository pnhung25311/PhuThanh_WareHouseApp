import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/service/BusinessService.service.dart';
import 'package:phuthanh_warehouseapp/business/service/CartService.service.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Bill.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Payment.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Employee.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/formatters/DotToMinusFormatte.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';

const gapH12 = SizedBox(height: 12);

class CartDetailScreen extends StatefulWidget {
  final Cart item;
  final bool readOnly;
  final String typeSave;

  const CartDetailScreen({
    super.key,
    required this.item,
    this.readOnly = false,
    this.typeSave = "",
  });

  @override
  State<CartDetailScreen> createState() => _CartDetailScreenState();
}

class _CartDetailScreenState extends State<CartDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  final InfoService infoService = InfoService();
  final CartService cartService = CartService();
  final Businessservice businessservice = Businessservice();
  final MySharedPreferences prefs = MySharedPreferences();
  final NavigationHelper nav = NavigationHelper();
  final Formatdatehelper formatdatehelper = Formatdatehelper();

  // ================= CONTROLLERS =================

  final _fullnameCtrl = TextEditingController();
  final _productIDCtrl = TextEditingController();
  final _productNameCtrl = TextEditingController();
  final _productPartNoCtrl = TextEditingController();
  final _manufacturerCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();

  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();

  final _qtyCtrlSynthetic = TextEditingController();
  final _priceCtrlSynthetic = TextEditingController();
  final _totalCtrlSynthetic = TextEditingController();
  final _priceVATCtrl = TextEditingController();
  final _priceNETCtrl = TextEditingController();

  final _employeeCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();

  DateTime? _deliveryTime;

  List<Bill> bills = [];
  List<Supplier> sources = [];
  List<Supplier> deliveries = [];
  List<Payment> payments = [];
  List<Employee> employees = [];

  Bill? selectedBill;
  Supplier? selectedSource;
  Supplier? selectedDelivery;
  Payment? selectedPayment;
  Employee? selectedEmployee;

  bool _loading = true;
  bool _saving = false;
  Timer? _productDebounce;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _bindItemToControllers();
    _qtyCtrl.addListener(_calcTotal);
    _priceCtrl.addListener(_calcTotal);
    _qtyCtrlSynthetic.addListener(_calcTotalSynthetic);
    _priceCtrlSynthetic.addListener(_calcTotalSynthetic);
    _productIDCtrl.addListener(_onProductChanged);
    _loadUser();
    _loadAllData();
  }

  void _bindItemToControllers() {
    final i = widget.item;

    _productIDCtrl.text = i.productID ?? '';
    _productNameCtrl.text = i.nameProduct ?? '';
    _productPartNoCtrl.text = i.idPartNo ?? '';
    _manufacturerCtrl.text = i.manufacturerName ?? '';
    _countryCtrl.text = i.countryName ?? '';
    _unitCtrl.text = i.unitName ?? '';
    _priceCtrl.text = (i.price ?? 0).toString();
    _qtyCtrl.text = (i.qty ?? 0).toString();
    _totalCtrl.text = (i.total ?? 0).toString();
    _priceVATCtrl.text = (i.priceVAT ?? 0).toString();
    _priceNETCtrl.text = (i.priceNET ?? 0).toString();
    _employeeCtrl.text = i.nameEmployee ?? '';
    _statusCtrl.text = i.nameStatus ?? '';
    _remarkCtrl.text = i.remark ?? '';
    _deliveryTime = i.deliveryTime;
  }

  Future<void> _loadUser() async {
    final acc = await prefs.getDataObject("account");
    _fullnameCtrl.text = acc?["FullName"] ?? "";
  }

  Future<int?> _getUserID() async {
    final acc = await prefs.getDataObject("account");
    return acc?["AccountID"];
  }

  // ================= LOAD MASTER DATA =================

  Future<void> _loadAllData() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      infoService.LoadDtataBill(),
      infoService.LoadDtataSupplier(),
      infoService.LoadDtataPayment(),
      infoService.LoadDtataEmployee(),
    ]);

    bills = results[0] as List<Bill>;
    sources = results[1] as List<Supplier>;
    deliveries = results[1] as List<Supplier>;
    payments = results[2] as List<Payment>;
    employees = results[3] as List<Employee>;

    selectedBill = bills.firstWhereOrNull(
      (e) => e.BillID.toString() == widget.item.billID.toString(),
    );
    selectedSource = sources.firstWhereOrNull(
      (e) => e.SupplierID.toString() == widget.item.sourceID.toString(),
    );
    selectedDelivery = deliveries.firstWhereOrNull(
      (e) => e.SupplierID.toString() == widget.item.deliveryID.toString(),
    );
    selectedPayment = payments.firstWhereOrNull(
      (e) => e.PaymentID.toString() == widget.item.paymentID.toString(),
    );
    selectedEmployee = employees.firstWhereOrNull(
      (e) => e.EmployeeID.toString() == widget.item.employeeID.toString(),
    );

    setState(() => _loading = false);
  }

  // ================= PRODUCT AUTO LOAD =================

  void _onProductChanged() {
    if (_productDebounce?.isActive ?? false) _productDebounce!.cancel();

    _productDebounce = Timer(const Duration(milliseconds: 600), () async {
      final id = _productIDCtrl.text.trim();
      if (id.isEmpty || id.length <= 9) return;

      final res = await infoService.findProduct(id);
      final Product pro = res["body"];

      setState(() {
        _productNameCtrl.text = pro.nameProduct;
        _productPartNoCtrl.text = pro.idPartNo;
        _manufacturerCtrl.text = pro.manufacturerName ?? '';
        _countryCtrl.text = pro.countryName ?? '';
        _unitCtrl.text = pro.unitName ?? '';
      });
    });
  }

  // ================= CALC TOTAL =================

  void _calcTotal() {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final total = (qty < 0) ? qty * -1 : qty;
    _totalCtrl.text = (total * price).toStringAsFixed(2);
  }

  void _calcTotalSynthetic() {
    final qty = double.tryParse(_qtyCtrlSynthetic.text) ?? 0;
    final price = double.tryParse(_priceCtrlSynthetic.text) ?? 0;
    final total = (qty < 0) ? qty * -1 : qty;
    _totalCtrlSynthetic.text = (total * price).toStringAsFixed(2);
  }

  // ================= SAVE =================

  Future<void> _saveCart() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    setState(() => _saving = true);

    try {
      int? accID = await _getUserID();

      int? productAID = await infoService.reTurnAID(
        "Product",
        "ProductAID",
        "ProductID",
        _productIDCtrl.text,
      );

      final cart = widget.item.copyWith(
        accountID: accID,
        productAID: productAID ?? 0,
        qty: double.tryParse(_qtyCtrl.text),
        price: double.tryParse(_priceCtrl.text),
        total: double.tryParse(_totalCtrl.text),
        priceVAT: double.tryParse(_priceVATCtrl.text),
        priceNET: double.tryParse(_priceNETCtrl.text),
        paymentID: selectedPayment?.PaymentID ?? 0,
        employeeID: selectedEmployee?.EmployeeID ?? 0,
        statusID: 0,
        billID: selectedBill?.BillID ?? 0,
        sourceID: selectedSource?.SupplierID ?? 0,
        deliveryID: selectedDelivery?.SupplierID ?? 0,
        remark: _remarkCtrl.text,
        deliveryTime: _deliveryTime,
        lastTime: DateTime.now(),
      );

      final cartTransferImport = widget.item.copyWith(
        accountID: accID,
        productAID: productAID ?? 0,
        qty: double.tryParse(_qtyCtrl.text),
        price: double.tryParse(_priceCtrl.text),
        total: double.tryParse(_totalCtrl.text),
        priceVAT: double.tryParse(_priceVATCtrl.text),
        priceNET: double.tryParse(_priceNETCtrl.text),
        paymentID: selectedPayment?.PaymentID ?? 0,
        employeeID: selectedEmployee?.EmployeeID ?? 0,
        statusID: 0,
        billID: selectedBill?.BillID ?? 0,
        sourceID: selectedSource?.SupplierID ?? 0,
        deliveryID: 239,
        remark: _remarkCtrl.text,
        deliveryTime: _deliveryTime,
        lastTime: DateTime.now(),
      );

      final cartTransferExport = widget.item.copyWith(
        accountID: accID,
        productAID: productAID ?? 0,
        qty: (double.tryParse(_qtyCtrl.text) ?? 0) * -1,
        price: double.tryParse(_priceCtrl.text),
        total: double.tryParse(_totalCtrl.text),
        priceVAT: double.tryParse(_priceVATCtrl.text),
        priceNET: double.tryParse(_priceNETCtrl.text),
        paymentID: selectedPayment?.PaymentID ?? 0,
        employeeID: selectedEmployee?.EmployeeID ?? 0,
        statusID: 0,
        billID: selectedBill?.BillID ?? 0,
        sourceID: 239,
        deliveryID: selectedDelivery?.SupplierID ?? 0,
        remark: _remarkCtrl.text,
        deliveryTime: _deliveryTime,
        lastTime: DateTime.now(),
      );

      final cartSyntheticImport = widget.item.copyWith(
        accountID: accID,
        productAID: productAID ?? 0,
        qty: double.tryParse(_qtyCtrl.text),
        price: double.tryParse(_priceCtrl.text),
        total: double.tryParse(_totalCtrl.text),
        priceVAT: double.tryParse(_priceVATCtrl.text),
        priceNET: double.tryParse(_priceNETCtrl.text),
        paymentID: selectedPayment?.PaymentID ?? 0,
        employeeID: selectedEmployee?.EmployeeID ?? 0,
        statusID: 0,
        billID: selectedBill?.BillID ?? 0,
        sourceID: selectedSource?.SupplierID ?? 0,
        deliveryID: selectedDelivery?.SupplierID ?? 0,
        remark: _remarkCtrl.text,
        deliveryTime: _deliveryTime,
        lastTime: DateTime.now(),
      );

      final cartSyntheticExport = widget.item.copyWith(
        accountID: accID,
        productAID: productAID ?? 0,
        qty: (double.tryParse(_qtyCtrlSynthetic.text) ?? 0) * -1,
        price: double.tryParse(_priceCtrlSynthetic.text),
        total: double.tryParse(_totalCtrlSynthetic.text),
        priceVAT: double.tryParse(_priceVATCtrl.text),
        priceNET: double.tryParse(_priceNETCtrl.text),
        paymentID: selectedPayment?.PaymentID ?? 0,
        employeeID: selectedEmployee?.EmployeeID ?? 0,
        statusID: 0,
        billID: selectedBill?.BillID ?? 0,
        sourceID: selectedSource?.SupplierID ?? 0,
        deliveryID: selectedDelivery?.SupplierID ?? 0,
        remark: _remarkCtrl.text,
        deliveryTime: _deliveryTime,
        lastTime: DateTime.now(),
      );

      final body = jsonEncode(cart.toJson());
      Map res = {};
      switch (widget.typeSave) {
        case "CREATE":
          res = await cartService.addCart(body);
          break;

        case "UPDATE":
          res = await businessservice.upDateCart(
            "Cart",
            widget.item.cartAID.toString(),
            body,
          );
        case "TRANSFER":
          res = await cartService.addCartBatch(
            jsonEncode([
              cartTransferImport.toJson(),
              cartTransferExport.toJson(),
            ]),
          );
          break;
        case "SYNTHETIC":
          res = await cartService.addCartBatch(
            jsonEncode([
              cart.toJson(),
              cartSyntheticImport.toJson(),
              cartSyntheticExport.toJson(),
            ]),
          );
          break;
        default:
          break;
      }

      if (res["isSuccess"]) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lưu thành công")));
        nav.pop(context, true);
      } else {
        throw Exception("Lưu thất bại");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => _saving = false);
  }

  // ================= UI SECTIONS =================

  Widget _card(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 12);

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.typeSave == "CREATE" ? "Tạo đơn hàng" : "Chi tiết đơn hàng",
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                // USER
                _card("Người tạo", Icons.person, [
                  CustomTextField(
                    label: 'Tên người tạo',
                    controller: _fullnameCtrl,
                    readOnly: true,
                  ),
                  _gap(),
                  CustomDropdownField<Employee>(
                    label: "Nhân viên của đơn hàng",
                    items: employees,
                    selectedValue: selectedEmployee,
                    getLabel: (i) => i.NameEmployee.toString(),
                    onChanged: (v) => setState(() => selectedEmployee = v),
                    isSearch: true,
                  ),
                ]),

                // PRODUCT
                _card("Sản phẩm", Icons.inventory, [
                  CustomTextField(
                    label: "Mã sản phẩm",
                    controller: _productIDCtrl,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Nhập mã sản phẩm" : null,
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Tên sản phẩm",
                    controller: _productNameCtrl,
                    readOnly: true,
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Danh điểm",
                    controller: _productPartNoCtrl,
                    readOnly: true,
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Hãng",
                    controller: _manufacturerCtrl,
                    readOnly: true,
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Nước",
                    controller: _countryCtrl,
                    readOnly: true,
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Đơn vị",
                    controller: _unitCtrl,
                    readOnly: true,
                  ),
                ]),

                // PRICE
                _card("Giá", Icons.payments, [
                  CustomTextField(
                    label: "Số lượng",
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [DotToMinusFormatter()],
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Đơn giá",
                    controller: _priceCtrl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [DotToMinusFormatter()],
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Thành tiền",
                    controller: _totalCtrl,
                    readOnly: true,
                  ),
                  _gap(),
                  if (widget.typeSave == "SYNTHETIC") ...[
                    CustomTextField(
                      label: "Số lượng",
                      controller: _qtyCtrlSynthetic,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [DotToMinusFormatter()],
                    ),
                    _gap(),
                    CustomTextField(
                      label: "Giá tổng hợp",
                      controller: _priceCtrlSynthetic,
                      // readOnly: true,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [DotToMinusFormatter()],
                    ),
                    _gap(),
                    CustomTextField(
                      label: "Thành tiền tổng hợp",
                      controller: _totalCtrlSynthetic,
                      readOnly: true,
                    ),
                  ],

                  _gap(),
                  CustomTextField(
                    label: "Giá VAT",
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    controller: _priceVATCtrl,
                    inputFormatters: [DotToMinusFormatter()],
                  ),
                  _gap(),
                  CustomTextField(
                    label: "Giá NET",
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [DotToMinusFormatter()],
                    controller: _priceNETCtrl,
                  ),
                ]),

                // BILL
                _card("Thanh toán & hóa đơn", Icons.receipt, [
                  CustomDropdownField<Bill>(
                    label: "Hóa đơn",
                    items: bills,
                    selectedValue: selectedBill,
                    getLabel: (i) => i.Name.toString(),
                    onChanged: (v) => setState(() => selectedBill = v),
                    isSearch: true,
                    validator: (v) =>
                        v == null ? "Bắt buộc chọn hóa đơn" : null,
                  ),
                  CustomDropdownField<Payment>(
                    label: "Phương thức thanh toán",
                    items: payments,
                    selectedValue: selectedPayment,
                    getLabel: (i) => i.Name.toString(),
                    onChanged: (v) => setState(() => selectedPayment = v),
                    isSearch: true,
                    validator: (v) => v == null
                        ? "Bắt buộc chọn phương thức thanh toán"
                        : null,
                  ),
                ]),

                // SHIPPING
                _card("Vận chuyển", Icons.local_shipping, [
                  CustomDropdownField<Supplier>(
                    label: "Nguồn",
                    items: sources,
                    selectedValue: selectedSource,
                    getLabel: (i) => i.Name.toString(),
                    onChanged: (v) => setState(() => selectedSource = v),
                    isSearch: true,
                    validator: (v) => v == null ? "Bắt buộc chọn nguồn" : null,
                  ),
                  _gap(),
                  CustomDropdownField<Supplier>(
                    label: "Đơn vị vận chuyển",
                    items: deliveries,
                    selectedValue: selectedDelivery,
                    getLabel: (i) => i.Name.toString(),
                    onChanged: (v) => setState(() => selectedDelivery = v),
                    isSearch: true,
                    validator: (v) =>
                        v == null ? "Bắt buộc chọn vận chuyển" : null,
                  ),
                  _gap(),
                  _buildDateField(),
                ]),

                // NOTE
                _card("Ghi chú", Icons.notes, [
                  CustomTextField(label: "Ghi chú", controller: _remarkCtrl),
                ]),
              ],
            ),
          ),

          // SAVE BUTTON
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black12)],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveCart,
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("LƯU"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(2022),
          lastDate: DateTime(2035),
          initialDate: DateTime.now(),
        );
        if (d != null) setState(() => _deliveryTime = d);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Ngày giao hàng",
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _deliveryTime == null
              ? "Chọn ngày giao hàng"
              : formatdatehelper.formatDMY(_deliveryTime!),
        ),
      ),
    );
  }
}
