import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/GenerateCodeAID.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/ImagePickerHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/warehouse/model/info/Guaranteet.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';
import 'package:collection/collection.dart';

class GuaranteeDetailScreen extends StatefulWidget {
  final Guarantee item;
  final bool isCreate;
  final bool isUpdate;
  final bool readOnly;

  const GuaranteeDetailScreen({
    super.key,
    required this.item,
    this.isCreate = false,
    this.isUpdate = false,
    this.readOnly = false,
  });

  @override
  State<GuaranteeDetailScreen> createState() => _GuaranteeDetailScreenState();
}

class _GuaranteeDetailScreenState extends State<GuaranteeDetailScreen> {
  // ── Services & Helpers ───────────────────────────────────────────────
  final InfoService infoService = InfoService();
  final Warehouseservice warehouseService = Warehouseservice();
  final Formatdatehelper formatdatehelper = Formatdatehelper();
  final NavigationHelper nav = NavigationHelper();
  final MySharedPreferences prefs = MySharedPreferences();
  final ImagePickerHelper imageHelper = ImagePickerHelper();
  final CodeHelper generateCodeAID = CodeHelper();

  // ── Controllers ──────────────────────────────────────────────────────
  final TextEditingController _guaranteeIdCtrl = TextEditingController();
  final TextEditingController _productIdBrokenCtrl = TextEditingController();
  final TextEditingController _partNoBrokenCtrl = TextEditingController();
  final TextEditingController _nameBrokenCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _productIdGuaranteeCtrl = TextEditingController();
  final TextEditingController _partNoGuaranteeCtrl = TextEditingController();
  final TextEditingController _nameGuaranteeCtrl = TextEditingController();
  final TextEditingController _partnerCtrl = TextEditingController();
  final TextEditingController _remarkCtrl = TextEditingController();
  final TextEditingController _img1Ctrl = TextEditingController();
  final TextEditingController _img2Ctrl = TextEditingController();
  final TextEditingController _img3Ctrl = TextEditingController();

  // ── Date fields ──────────────────────────────────────────────────────
  DateTime? _timeStart;
  DateTime? _timeBroken;
  DateTime? _timeGuarantee;

  int? get daysUsed {
    if (_timeStart == null || _timeBroken == null) return null;
    if (_timeBroken!.isBefore(_timeStart!)) return null;
    return _timeBroken!.difference(_timeStart!).inDays;
  }

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
    _guaranteeIdCtrl.text = widget.item.guaranteeID ?? '';
    _productIdBrokenCtrl.text = widget.item.productIDBroken ?? '';
    _partNoBrokenCtrl.text = widget.item.idPartNoBroken ?? '';
    _nameBrokenCtrl.text = widget.item.nameProductBroken ?? '';
    _reasonCtrl.text = widget.item.reasonBroken ?? '';
    _productIdGuaranteeCtrl.text = widget.item.productIDGuarantee ?? '';
    _partNoGuaranteeCtrl.text = widget.item.idPartNoGuarantee ?? '';
    _nameGuaranteeCtrl.text = widget.item.nameProductGuarantee ?? '';
    _partnerCtrl.text = widget.item.partner ?? '';
    _remarkCtrl.text = widget.item.remark ?? '';
    _img1Ctrl.text = widget.item.img1 ?? '';
    _img2Ctrl.text = widget.item.img2 ?? '';
    _img3Ctrl.text = widget.item.img3 ?? '';

    _timeStart = widget.item.timeStart;
    _timeBroken = widget.item.timeBroken;
    _timeGuarantee = widget.item.timeGuarantee;

    if (widget.isCreate) {
      _guaranteeIdCtrl.text = generateCodeAID.generateCodeBH();
    }

    _initData();
    _txtListener();
  }

  Product pro = Product.empty();
  Product proGu = Product.empty();

  Future<void> _txtListener() async {
    _productIdBrokenCtrl.addListener(() async {
      final proBroken = await infoService.findProduct(
        _productIdBrokenCtrl.text.trim(),
      );
      pro = proBroken["body"];
      _nameBrokenCtrl.text = pro.nameProduct;
      _partNoBrokenCtrl.text = pro.idPartNo;
    });
    //=====
    _productIdGuaranteeCtrl.addListener(() async {
      final proG = await infoService.findProduct(
        _productIdGuaranteeCtrl.text.trim(),
      );
      proGu = proG["body"];
      _nameGuaranteeCtrl.text = proGu.nameProduct;
      _partNoGuaranteeCtrl.text = proGu.idPartNo;
    });
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    try {
      final suppList = await infoService.LoadDtataSupplier();
      setState(() {
        suppliers = suppList;
        selectedSupplier = suppliers.firstWhereOrNull(
          (s) => s.SupplierID == widget.item.supplierGuarantee,
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
    return account?["UserName"] as String?;
  }

  Future<void> _saveGuarantee() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Upload ảnh nếu có file mới
      final files = [
        AppState.instance.get<File?>('img1'),
        AppState.instance.get<File?>('img2'),
        AppState.instance.get<File?>('img3'),
      ];

      final ctrls = [_img1Ctrl, _img2Ctrl, _img3Ctrl];
      final keys = ['img1', 'img2', 'img3'];

      final uploadFutures = <Future<String?>>[];
      for (var file in files) {
        if (file != null && file.path.isNotEmpty) {
          // Có thể dùng guaranteeID hoặc một mã tạm để đặt tên file
          uploadFutures.add(
            imageHelper.uploadImageGuarantee(
              file,
              _guaranteeIdCtrl.text.trim().isNotEmpty
                  ? _guaranteeIdCtrl.text.trim()
                  : 'temp_${DateTime.now().millisecondsSinceEpoch}',
            ),
          );
        } else {
          uploadFutures.add(Future.value(null));
        }
      }

      final uploadedUrls = await Future.wait(uploadFutures);

      for (int i = 0; i < uploadedUrls.length; i++) {
        if (uploadedUrls[i] != null) {
          ctrls[i].text = uploadedUrls[i]!;
          AppState.instance.remove(keys[i]);
        }
      }

      // Chuẩn bị object Guarantee
      final guaranteeCreate = widget.item.copyWith(
        guaranteeID: _guaranteeIdCtrl.text.trim(),
        productBroken: pro.productAID,
        timeStart: _timeStart,
        timeBroken: _timeBroken,
        timeUsage: daysUsed,
        reasonBroken: _reasonCtrl.text.trim(),
        productGuarantee: proGu.productAID,
        timeGuarantee: _timeGuarantee,
        supplierGuarantee: selectedSupplier?.SupplierID,
        partner: _partnerCtrl.text.trim(),
        img1: _img1Ctrl.text.trim(),
        img2: _img2Ctrl.text.trim(),
        img3: _img3Ctrl.text.trim(),
        remark: _remarkCtrl.text.trim(),
        lastUser: await _getCurrentUserFullName(),
        lastTime: formatdatehelper.toSqlDateTime(DateTime.now()),
      );
      print(pro.productAID);
      print(proGu.productAID);
      final guaranteeUpdate = widget.item.copyWith(
        productBroken: pro.productAID == 0
            ? widget.item.productBroken
            : pro.productAID,
        timeStart: _timeStart,
        timeBroken: _timeBroken,
        timeUsage: daysUsed,
        reasonBroken: _reasonCtrl.text.trim(),
        productGuarantee: proGu.productAID == 0
            ? widget.item.productGuarantee
            : proGu.productAID,
        timeGuarantee: _timeGuarantee,
        supplierGuarantee: selectedSupplier?.SupplierID,
        partner: _partnerCtrl.text.trim(),
        img1: _img1Ctrl.text.trim(),
        img2: _img2Ctrl.text.trim(),
        img3: _img3Ctrl.text.trim(),
        remark: _remarkCtrl.text.trim(),
        lastUser: await _getCurrentUserFullName(),
        lastTime: formatdatehelper.toSqlDateTime(DateTime.now()),
      );

      if (widget.isCreate) {
        // Kiểm tra mã trùng (nếu backend hỗ trợ)
        final checkPayload = jsonEncode({
          "GuaranteeID": guaranteeCreate.guaranteeID,
        });
        final exists = await infoService.checkProductID(
          "Guarantee",
          checkPayload,
        ); // giả định hàm này dùng chung
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mã phiếu bảo hành đã tồn tại!")),
          );
          return;
        } else {
          final response = await warehouseService.addWarehouseRow(
            "Guarantee",
            jsonEncode(guaranteeCreate),
          );
          if (response["statusCode"] == 403 ||
              response["statusCode"] == 401 ||
              response["statusCode"] == 0) {
            nav.pushAndRemoveUntil(context, const Loginscreen());

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
      if (widget.isUpdate) {
        print(jsonEncode(guaranteeUpdate));

        final response = await warehouseService.upDateGuarantee(
          "Guarantee",
          widget.item.guaranteeAID.toString(),
          jsonEncode(guaranteeUpdate),
        );
        if (response["statusCode"] == 403 ||
            response["statusCode"] == 401 ||
            response["statusCode"] == 0) {
          nav.pushAndRemoveUntil(context, const Loginscreen());

          return;
        }

        if (response["isSuccess"]) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cập nhật thành công'),
              duration: const Duration(milliseconds: 500),
            ),
          );
          nav.pop(context, true); // quay lại và báo màn trước refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi cập nhật: '),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }
      
      }
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
    final days = daysUsed;
    final daysText = days == null
        ? "Chưa đủ thông tin ngày"
        : days == 0
        ? "0 ngày (cùng ngày)"
        : "$days ngày";

    final daysColor = days == null || days == 0
        ? Colors.grey
        : days > 0
        ? Colors.blue.shade800
        : Colors.red;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCreate
              ? "Thêm phiếu bảo hành mới"
              : widget.item.guaranteeID?.isNotEmpty == true
              ? "Phiếu ${widget.item.guaranteeID}"
              : "Chi tiết bảo hành",
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
              controller: _guaranteeIdCtrl,
              hintText: "VD: BH2025-001",
              readOnly: true,
            ),
            const SizedBox(height: 16),

            const Divider(height: 32),
            Text(
              "Sản phẩm hỏng / khiếu nại",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: "Mã sản phẩm hỏng",
              controller: _productIdBrokenCtrl,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Part No hỏng",
              controller: _partNoBrokenCtrl,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Tên sản phẩm hỏng",
              controller: _nameBrokenCtrl,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDateTile(
                    "Ngày bắt đầu sử dụng",
                    _timeStart,
                    () => _pickDate(
                      initial: _timeStart,
                      onPicked: (d) => _timeStart = d,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTile(
                    "Ngày hỏng / khiếu nại",
                    _timeBroken,
                    () => _pickDate(
                      initial: _timeBroken,
                      onPicked: (d) => _timeBroken = d,
                    ),
                  ),
                ),
              ],
            ), // ── Hiển thị số ngày sử dụng ──────────────────────────────
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Số ngày đã sử dụng:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    daysText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: daysColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: "Lý do hỏng / khiếu nại",
              controller: _reasonCtrl,
              // maxLines: 3,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 24),

            // ── Sản phẩm bảo hành / thay thế ──────────────────────────
            const Divider(height: 32),
            Text(
              "Sản phẩm bảo hành / thay thế",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: "Mã sản phẩm bảo hành",
              controller: _productIdGuaranteeCtrl,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Part No bảo hành",
              controller: _partNoGuaranteeCtrl,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Tên sản phẩm bảo hành",
              controller: _nameGuaranteeCtrl,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 16),

            _buildDateTile(
              "Ngày bảo hành / thay thế",
              _timeGuarantee,
              () => _pickDate(
                initial: _timeGuarantee,
                onPicked: (d) => _timeGuarantee = d,
              ),
            ),
            const SizedBox(height: 24),

            // ── Nhà cung cấp / Đối tác ────────────────────────────────
            const Divider(height: 32),
            Text(
              "Nhà cung cấp / Đối tác",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            CustomDropdownField<Supplier>(
              label: "Nhà cung cấp bảo hành",
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
            const SizedBox(height: 24),

            CustomTextFieldIcon(
              label: "Ảnh minh chứng 1",
              controller: _img1Ctrl,
              readOnly: true,
              prefixIcon: Icons.image,
              suffixIcon: Icons.camera_alt,
              onSuffixIconPressed: () async {
                // Gọi helper upload
                await ImagePickerHelper().showImageOptions(
                  context: context,
                  isUpdate: true,
                  currentImageUrl: _img1Ctrl.text,
                  productID: _guaranteeIdCtrl.text.trim().isNotEmpty
                      ? _guaranteeIdCtrl.text.trim()
                      : '',
                  nameImg: "img1",
                  // wh: ,
                  onImageChanged: (url) {
                    // Cập nhật TextField khi upload thành công
                    setState(() {
                      _img1Ctrl.text = url ?? '';
                    });
                  },
                  // wh: widget.item,
                );
              },
            ),
            const SizedBox(height: 16),

            CustomTextFieldIcon(
              label: "Ảnh minh chứng 2",
              controller: _img2Ctrl,
              readOnly: true,
              prefixIcon: Icons.image,
              suffixIcon: Icons.camera_alt,
              onSuffixIconPressed: () => imageHelper.showImageOptions(
                context: context,
                currentImageUrl: _img2Ctrl.text,
                nameImg: "img2",
                productID: _guaranteeIdCtrl.text.trim().isNotEmpty
                    ? _guaranteeIdCtrl.text.trim()
                    : '',
                isUpdate: true,
                onImageChanged: (url) {
                  setState(() => _img2Ctrl.text = url ?? '');
                },
              ),
            ),
            const SizedBox(height: 16),

            CustomTextFieldIcon(
              label: "Ảnh minh chứng 3",
              controller: _img3Ctrl,
              readOnly: true,
              prefixIcon: Icons.image,
              suffixIcon: Icons.camera_alt,
              onSuffixIconPressed: () => imageHelper.showImageOptions(
                context: context,
                currentImageUrl: _img3Ctrl.text,
                nameImg: "img3",
                productID: _guaranteeIdCtrl.text.trim().isNotEmpty
                    ? _guaranteeIdCtrl.text.trim()
                    : '',
                isUpdate: true,
                onImageChanged: (url) {
                  setState(() => _img3Ctrl.text = url ?? '');
                },
              ),
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
    _guaranteeIdCtrl.dispose();
    _productIdBrokenCtrl.dispose();
    _partNoBrokenCtrl.dispose();
    _nameBrokenCtrl.dispose();
    _reasonCtrl.dispose();
    _productIdGuaranteeCtrl.dispose();
    _partNoGuaranteeCtrl.dispose();
    _nameGuaranteeCtrl.dispose();
    _partnerCtrl.dispose();
    _remarkCtrl.dispose();
    _img1Ctrl.dispose();
    _img2Ctrl.dispose();
    _img3Ctrl.dispose();
    super.dispose();
  }
}
