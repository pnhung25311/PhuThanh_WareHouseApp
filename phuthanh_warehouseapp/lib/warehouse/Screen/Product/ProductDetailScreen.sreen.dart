import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/HomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
// import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDialogAppendix.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomSmartDropdown.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/ImagePickerHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Employee.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Unit.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';
import 'package:collection/collection.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product item;
  final bool isUpDate;
  final bool isCreate;
  final bool isCreateHistory;
  final bool isReadOnlyHistory;
  final bool readOnly;

  ProductDetailScreen({
    super.key,
    required this.item,
    this.isUpDate = false,
    this.isCreate = false,
    this.isCreateHistory = false,
    this.isReadOnlyHistory = false,
    this.readOnly = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<Country> countries = [];
  List<Manufacturer> manufacturers = [];
  List<Supplier> suppliers = [];
  List<Supplier> supplierActuals = [];
  List<Supplier> suppliersHistory = [];
  //1 là nhà cung cấp; 2 là nhập khẩu; 3 là khách hàng
  List<Unit> units = [];
  List<Employee> emps = [];
  List<VehicleType> vehicles = [];
  List<VehicleType> selectVehicles = [];
  List<int> selectedVehicelIds = [];

  Country? selectedCountry;
  Manufacturer? selectedManufacturer;
  Supplier? selectedSupplier;
  Supplier? selectedSupplierActual;
  Unit? selectedUnit;
  VehicleType? selectedVehicleType;

  final TextEditingController remarkController = TextEditingController();
  final TextEditingController productIDController = TextEditingController();
  final TextEditingController qtyExpectedController = TextEditingController();
  final TextEditingController keetonController = TextEditingController();
  final TextEditingController industrialController = TextEditingController();
  final TextEditingController partNoController = TextEditingController();
  final TextEditingController nameProductController = TextEditingController();
  final TextEditingController idBillController = TextEditingController();
  final TextEditingController parameterController = TextEditingController();
  final TextEditingController vehicleDetailController = TextEditingController();
  final TextEditingController vehicleClusterController =
      TextEditingController();
  final TextEditingController replacedPartNoController =
      TextEditingController();
  final TextEditingController image1Controller = TextEditingController();
  final TextEditingController image2Controller = TextEditingController();
  final TextEditingController image3Controller = TextEditingController();

  bool loading = true;

  bool isSaving = false; // ⚡ trạng thái loading khi lưu
  Key dropdownKey = UniqueKey();
  DateTime initialDate = DateTime.now(); // ⚡ biến state

  // bool StatusCreate = AppState.instance.get("CreateAppendix");
  bool StatusCreate = true;
  InfoService infoService = InfoService();
  Warehouseservice warehouseservice = Warehouseservice();
  Formatdatehelper formatdatehelper = Formatdatehelper();
  NavigationHelper navigationHelper = NavigationHelper();
  MySharedPreferences mySharedPreferences = MySharedPreferences();

  @override
  void initState() {
    super.initState();
    remarkController.text = widget.item.remark ?? "";
    productIDController.text = widget.item.productID.toString();
    // qtyExpectedController.text = widget.item.qtyExpected.toString();
    keetonController.text = widget.item.idKeeton;
    industrialController.text = widget.item.idIndustrial.toString();
    partNoController.text = widget.item.idPartNo;
    replacedPartNoController.text = widget.item.idReplacedPartNo;
    nameProductController.text = widget.item.nameProduct.toString();
    // idBillController.text = widget.item.idBill.toString();
    parameterController.text = widget.item.parameter.toString();
    vehicleDetailController.text = widget.item.vehicleDetail.toString();
    vehicleClusterController.text = widget.item.vehicleCluster.toString();
    image1Controller.text = widget.item.img1 ?? '';
    image2Controller.text = widget.item.img2 ?? '';
    image3Controller.text = widget.item.img3 ?? '';

    _init();
  }

  // thêm helper init để await các load
  Future<void> _init() async {
    await _loadAllData();
    await _loadDataVehicel();
  }

  DateTime parseDateManual(String dateStr) {
    return formatdatehelper.parseDate(dateStr);
  }

  Future<void> _loadAllData() async {
    setState(() => loading = true);
    try {
      // ✅ Chạy tất cả API song song
      final results = await Future.wait([
        infoService.LoadDtataCountry(),
        infoService.LoadDtataManufacturer(),
        infoService.LoadDtataSupplier(),
        infoService.LoadDtataUnit(),
        infoService.LoadDtataVehicleType(),
      ]);

      countries = results[0] as List<Country>;
      manufacturers = results[1] as List<Manufacturer>;
      suppliers = results[2] as List<Supplier>;
      supplierActuals = results[2] as List<Supplier>;
      units = results[3] as List<Unit>;
      vehicles = results[4] as List<VehicleType>;

      setState(() {
        selectedCountry = countries.firstWhereOrNull(
          (e) => e.CountryID.toString() == widget.item.countryID.toString(),
        );
        selectedManufacturer = manufacturers.firstWhereOrNull(
          (e) =>
              e.ManufacturerID.toString() ==
              widget.item.manufacturerID.toString(),
        );
        selectedSupplier = suppliers.firstWhereOrNull(
          (e) => e.SupplierID.toString() == widget.item.supplierID.toString(),
        );
        selectedSupplierActual = supplierActuals.firstWhereOrNull(
          (e) =>
              e.SupplierID.toString() ==
              widget.item.supplierActualID.toString(),
        );
        selectedUnit = units.firstWhereOrNull(
          (e) => e.UnitID.toString() == widget.item.unitID.toString(),
        );
        selectedVehicleType = vehicles.firstWhereOrNull(
          (e) =>
              e.VehicleTypeID.toString() ==
              widget.item.vehicleTypeID.toString(),
        );

        loading = false;
      });
    } catch (e) {
      print("❌ Lỗi load dữ liệu: $e");
      setState(() => loading = false);
    }
  }

  Future<String?> getFullname() async {
    Map<String, dynamic>? account = await mySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["FullName"];
    return fullname;
  }

  Future<void> _loadDataVehicel() async {
    // AppState.instance.set("vehicleAppState", null);
    final vehicleAppState = await AppState.instance.get("vehicleAppState");
    if (vehicleAppState != null) {
      vehicles = vehicleAppState;
      setState(() {
        dropdownKey = UniqueKey();
      });
    } else {
      final callVehicle = await infoService.LoadDtataVehicleType();
      vehicles = callVehicle;
      AppState.instance.set("vehicleAppState", callVehicle);
      setState(() {
        dropdownKey = UniqueKey();
      });
    }
    String vehicle = widget.item.vehicleTypeID.toString();
    selectedVehicelIds = vehicle
        .split(',')
        .map((e) => e.trim())
        .where((e) => int.tryParse(e) != null)
        .map((e) => int.parse(e))
        .toList();

    selectVehicles = vehicles
        .where((loc) => selectedVehicelIds.contains(loc.VehicleTypeID))
        .toList();
  }

  void _upDateWareHouse() async {
    setState(() => isSaving = true);
    try {
      String vehicleResult = selectedVehicelIds.join(",");

      // final api = const ApiClient();
      final helper = ImagePickerHelper();
      final files = [
        AppState.instance.get<File?>('img1'),
        AppState.instance.get<File?>('img2'),
        AppState.instance.get<File?>('img3'),
      ];

      final controllers = [
        image1Controller,
        image2Controller,
        image3Controller,
      ];
      final keys = ['img1', 'img2', 'img3'];

      final uploads = <Future<String?>>[];

      for (var file in files) {
        if (file != null) {
          uploads.add(helper.uploadImage(file, productIDController.text));
        } else {
          uploads.add(Future.value(null)); // giữ vị trí null
        }
      }

      final results = await Future.wait(uploads);

      for (int i = 0; i < results.length; i++) {
        final link = results[i];
        if (link != null) {
          controllers[i].text = link;
          AppState.instance.remove(keys[i]);
        }
      }

      final product = Product.empty();
      final _productCreate = Product.empty();

      final productCreate = _productCreate.copyWith(
        // productAID: null,
        productID: productIDController.text.trim(),
        idKeeton: keetonController.text.trim(),
        idIndustrial: industrialController.text.trim(),
        idPartNo: partNoController.text.trim(),
        idReplacedPartNo: replacedPartNoController.text.trim(),
        nameProduct: nameProductController.text.trim(),
        // qtyExpected: double.tryParse(qtyExpectedController.text.trim()) ?? 0,
        // idBill: idBillController.text.trim(),
        parameter: parameterController.text.trim(),
        vehicleDetail: vehicleDetailController.text.trim(),
        vehicleTypeID: vehicleResult,
        vehicleCluster: vehicleClusterController.text.trim(),
        manufacturerID: selectedManufacturer?.ManufacturerID ?? 0,
        countryID: selectedCountry?.CountryID ?? 0,
        supplierID: selectedSupplier?.SupplierID ?? 0,
        supplierActualID: selectedSupplierActual?.SupplierID ?? 0,
        unitID: selectedUnit?.UnitID ?? 0,
        remark: remarkController.text.trim(),
        img1: image1Controller.text.trim(),
        img2: image2Controller.text.trim(),
        img3: image3Controller.text.trim(),
        lastTime: formatdatehelper.toSqlDateTime(DateTime.now()),
      );

      final productUpdate = product.copyWith(
        productID: productIDController.text.trim(),
        idKeeton: keetonController.text.trim(),
        idIndustrial: industrialController.text.trim(),
        idPartNo: partNoController.text.trim(),
        idReplacedPartNo: replacedPartNoController.text.trim(),
        nameProduct: nameProductController.text.trim(),
        // qtyExpected: double.tryParse(qtyExpectedController.text.trim()) ?? 0,
        // idBill: idBillController.text.trim(),
        parameter: parameterController.text.trim(),
        vehicleDetail: vehicleDetailController.text.trim(),
        vehicleTypeID: vehicleResult,
        manufacturerID: selectedManufacturer?.ManufacturerID ?? 0,
        countryID: selectedCountry?.CountryID ?? 0,
        supplierID: selectedSupplier?.SupplierID ?? 0,
        supplierActualID: selectedSupplierActual?.SupplierID ?? 0,
        unitID: selectedUnit?.UnitID ?? 0,
        remark: remarkController.text.trim(),
        img1: image1Controller.text.trim(),
        img2: image2Controller.text.trim(),
        img3: image3Controller.text.trim(),
        lastTime: formatdatehelper.toSqlDateTime(DateTime.now()),
      );

      final jsonProduct = productCreate.toJson();
      final jsonProductUpdate = productUpdate.toJson();
      final idProductID = jsonEncode({
        "ProductID": productIDController.text.trim(),
      });

      // 🔹 Gọi API PUT (sử dụng hàm put bạn đã thêm trong ApiClient)
      // final tableName = await _loadData();

      if (widget.isCreate) {
        final checkProductID = await infoService.checkProductID(
          "Product",
          idProductID,
        );
        if (checkProductID) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Mã sản phẩm đã tồn tại '),
              duration: const Duration(milliseconds: 500),
            ),
          );
        } else {
          // final response = await api.post("dynamic/insert/Product", bodyCreate);
          final response = await warehouseservice.addWarehouseRow(
            "Product",
            jsonEncode(jsonProduct),
          );

          if (response["statusCode"] == 403 ||
              response["statusCode"] == 401 ||
              response["statusCode"] == 0) {
            navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
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
            AppState.instance.set("ListProduct", null);
            AppState.instance.set("DataWareHouseLimit", null);
            navigationHelper.pushAndRemoveUntil(
              context,
              HomeScreen(),
            ); // quay lại và báo màn trước refresh
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Lỗi thêm mới: '),
                duration: const Duration(milliseconds: 500),
              ),
            );
          }
        }
      }

      if (widget.isUpDate) {
        final response = await infoService.UpdateProduct(
          widget.item.productAID.toString(),
          jsonEncode(jsonProductUpdate),
        );
        if (response["statusCode"] == 403 ||
            response["statusCode"] == 401 ||
            response["statusCode"] == 0) {
          navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
          return;
        }

        if (response["isSuccess"]) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Chỉnh sửa thành công'),
              duration: const Duration(milliseconds: 500),
            ),
          );
          AppState.instance.set("ListProduct", null);
          AppState.instance.set("DataWareHouseLimit", null);
          navigationHelper.pushAndRemoveUntil(
            context,
            HomeScreen(),
          ); // quay lại và báo màn trước refresh
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Lỗi kết nối: $e'),
          duration: const Duration(milliseconds: 500),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  /// ✅ Widget loading
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            "Đang lưu dữ liệu...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isSaving) {
      return Scaffold(body: _buildLoading());
    }

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          widget.item.nameProduct.isEmpty
              ? "Thêm sản phẩm"
              : widget.item.nameProduct,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ===== THÔNG TIN SẢN PHẨM =====
            _section("Thông tin sản phẩm", [
              CustomTextField(
                label: "Mã sản phẩm",
                controller: productIDController,
                readOnly: widget.readOnly,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Tên sản phẩm",
                controller: nameProductController,
                readOnly: widget.readOnly,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Thông số",
                controller: parameterController,
                readOnly: widget.readOnly,
              ),
            ]),

            /// ===== MÃ SẢN PHẨM =====
            _section("Mã sản phẩm", [
              CustomTextField(
                label: "Mã Keeton",
                controller: keetonController,
                readOnly: widget.readOnly,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Mã công nghiệp",
                controller: industrialController,
                readOnly: widget.readOnly,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Danh điểm",
                controller: partNoController,
                readOnly: widget.readOnly,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Danh điểm tương đương",
                controller: replacedPartNoController,
                readOnly: widget.readOnly,
              ),
            ]),

            /// ===== XE =====
            _section("Thông tin xe", [
              SmartDropdown<VehicleType>(
                key: dropdownKey,
                labelBuilder: (loc) => loc.VehicleTypeName,
                items: vehicles,
                hint: "Chọn hãng xe",
                isSearch: true,
                isMultiSelect: true,
                readOnly: widget.readOnly,
                initialValues: selectVehicles,
                dropdownMaxHeight: 300,
                onChanged: (values) => setState(() {
                  selectVehicles = List<VehicleType>.from(values as List);
                  selectedVehicelIds = selectVehicles
                      .map((e) => e.VehicleTypeID)
                      .toList();
                }),
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Dòng xe",
                controller: vehicleDetailController,
                readOnly: widget.readOnly,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Cụm xe",
                controller: vehicleClusterController,
                readOnly: widget.readOnly,
              ),
            ]),

            /// ===== NHÀ CUNG CẤP =====
            _section("Nhà cung cấp", [
              CustomDropdownField(
                label: "Nhà sản xuất",
                selectedValue: selectedManufacturer,
                items: manufacturers,
                getLabel: (i) => i.Name,
                onChanged: (v) => setState(() => selectedManufacturer = v),
                readOnly: widget.readOnly,
                isSearch: true,
              ),

              const SizedBox(height: 12),

              CustomDropdownField(
                label: "Nhà phân phối thực tế",
                selectedValue: selectedSupplierActual,
                items: supplierActuals,
                getLabel: (i) => i.Name,
                onChanged: (v) => setState(() => selectedSupplierActual = v),
                readOnly: widget.readOnly,
                isSearch: true,
              ),

              const SizedBox(height: 12),

              CustomDropdownField(
                label: "Nhà phân phối giấy tờ",
                selectedValue: selectedSupplier,
                items: suppliers,
                getLabel: (i) => i.Name,
                onChanged: (v) => setState(() => selectedSupplier = v),
                readOnly: widget.readOnly,
                isSearch: true,
              ),
            ]),

            /// ===== QUỐC GIA =====
            _section("Thông tin khác", [
              CustomDropdownField(
                label: "Quốc gia",
                selectedValue: selectedCountry,
                items: countries,
                getLabel: (i) => i.Name,
                onChanged: (v) => setState(() => selectedCountry = v),
                readOnly: widget.readOnly,
                isSearch: true,
              ),

              const SizedBox(height: 12),

              CustomDropdownField(
                label: "Đơn vị tính",
                selectedValue: selectedUnit,
                items: units,
                getLabel: (i) => i.Name,
                onChanged: (v) => setState(() => selectedUnit = v),
                readOnly: widget.readOnly,
                isSearch: true,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                label: "Ghi chú",
                controller: remarkController,
                readOnly: widget.readOnly,
              ),
            ]),

            /// ===== ẢNH =====
            _section("Ảnh sản phẩm", [
              _imageField("Ảnh 1", image1Controller, "img1"),
              const SizedBox(height: 16),

              _imageField("Ảnh 2", image2Controller, "img2"),
              const SizedBox(height: 16),

              _imageField("Ảnh 3", image3Controller, "img3"),
            ]),

            const SizedBox(height: 30),

            /// ===== BUTTON =====
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (widget.isUpDate || widget.isCreate) && !isSaving
                        ? _upDateWareHouse
                        : null,
                    icon: const Icon(Icons.save),
                    label: Text(isSaving ? "Đang lưu..." : "Lưu"),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Quay lại"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _imageField(
    String title,
    TextEditingController controller,
    String key,
  ) {
    return CustomTextFieldIcon(
      label: title,
      controller: controller,
      prefixIcon: Icons.image_outlined,
      suffixIcon: Icons.camera_alt,
      readOnly: true,
      onSuffixIconPressed: () async {
        await ImagePickerHelper().showImageOptions(
          context: context,
          currentImageUrl: controller.text,
          productID: productIDController.text,
          nameImg: key,
          isUpdate: widget.isUpDate,
          onImageChanged: (url) {
            setState(() {
              controller.text = url ?? '';
            });
          },
        );
      },
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(.05),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
