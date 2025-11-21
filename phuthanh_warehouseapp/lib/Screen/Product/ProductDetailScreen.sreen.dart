import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/HomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDialogAppendix.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/GenerateCodeAID.helper.dart';
import 'package:phuthanh_warehouseapp/helper/ImagePickerHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Employee.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Unit.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';
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
  final TextEditingController replacedPartNoController =
      TextEditingController();
  final TextEditingController image1Controller = TextEditingController();
  final TextEditingController image2Controller = TextEditingController();
  final TextEditingController image3Controller = TextEditingController();

  bool loading = true;

  bool isSaving = false; // ⚡ trạng thái loading khi lưu
  Key dropdownKey = UniqueKey();
  DateTime initialDate = DateTime.now(); // ⚡ biến state

  bool StatusCreate = AppState.instance.get("CreateAppendix");

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
    image1Controller.text = widget.item.img1 ?? '';
    image2Controller.text = widget.item.img2 ?? '';
    image3Controller.text = widget.item.img3 ?? '';

    _init();
  }

  // thêm helper init để await các load
  Future<void> _init() async {
    await _loadAllData();
  }

  DateTime parseDateManual(String dateStr) {
    return Formatdatehelper.parseDate(dateStr);
  }

  Future<void> _loadAllData() async {
    setState(() => loading = true);
    try {
      // ✅ Chạy tất cả API song song
      final results = await Future.wait([
        InfoService.LoadDtataCountry(),
        InfoService.LoadDtataManufacturer(),
        InfoService.LoadDtataSupplier(),
        InfoService.LoadDtataUnit(),
        InfoService.LoadDtataVehicleType(),
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
    Map<String, dynamic>? account = await MySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["FullName"];
    return fullname;
  }

  void _upDateWareHouse() async {
    setState(() => isSaving = true);
    try {
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
      print(DateTime.now());

      final productCreate = Product(
        productAID: await CodeHelper.generateCodeAID("SP"),
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
        vehicleTypeID: selectedVehicleType?.VehicleTypeID ?? 0,
        manufacturerID: selectedManufacturer?.ManufacturerID ?? 0,
        countryID: selectedCountry?.CountryID ?? 0,
        supplierID: selectedSupplier?.SupplierID ?? 0,
        supplierActualID: selectedSupplierActual?.SupplierID ?? 0,
        unitID: selectedUnit?.UnitID ?? 0,
        remark: remarkController.text.trim(),
        img1: image1Controller.text.trim(),
        img2: image2Controller.text.trim(),
        img3: image3Controller.text.trim(),
        lastTime: Formatdatehelper.toSqlDateTime(DateTime.now()),
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
        vehicleTypeID: selectedVehicleType?.VehicleTypeID ?? 0,
        manufacturerID: selectedManufacturer?.ManufacturerID ?? 0,
        countryID: selectedCountry?.CountryID ?? 0,
        supplierID: selectedSupplier?.SupplierID ?? 0,
        supplierActualID: selectedSupplierActual?.SupplierID ?? 0,
        unitID: selectedUnit?.UnitID ?? 0,
        remark: remarkController.text.trim(),
        img1: image1Controller.text.trim(),
        img2: image2Controller.text.trim(),
        img3: image3Controller.text.trim(),
        lastTime: Formatdatehelper.toSqlDateTime(DateTime.now()),
      );

      final jsonProduct = productCreate.toJson();
      final jsonProductUpdate = productUpdate.toJson();
      final idProductID = jsonEncode({
        "ProductID": productIDController.text.trim(),
      });

      // 🔹 Gọi API PUT (sử dụng hàm put bạn đã thêm trong ApiClient)
      // final tableName = await _loadData();

      if (widget.isCreate) {
        final checkProductID = await InfoService.checkProductID(
          "Product",
          idProductID,
        );
        if (checkProductID) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Mã sản phẩm đã tồn tại ')));
        } else {
          // final response = await api.post("dynamic/insert/Product", bodyCreate);
          final response = await Warehouseservice.addWarehouseRow(
            "Product",
            jsonEncode(jsonProduct),
          );

          if (response["isSuccess"]) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Thêm mới thành công')),
            );
            AppState.instance.set("ListProduct", null);
            AppState.instance.set("DataWareHouseLimit", null);
            NavigationHelper.pushAndRemoveUntil(
              context,
              HomeScreen(),
            ); // quay lại và báo màn trước refresh
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('❌ Lỗi thêm mới: ')));
          }
        }
      }

      if (widget.isUpDate) {
        final response = await InfoService.UpdateProduct(
          widget.item.productAID,
          jsonEncode(jsonProductUpdate),
        );
        if (response["isSuccess"]) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Chỉnh sửa thành công')),
          );
          AppState.instance.set("ListProduct", null);
          AppState.instance.set("DataWareHouseLimit", null);
          NavigationHelper.pushAndRemoveUntil(
            context,
            HomeScreen(),
          ); // quay lại và báo màn trước refresh
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Lỗi cập nhật: ')));
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi kết nối: $e')));
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
      appBar: AppBar(
        title: Text(
          widget.item.nameProduct.isEmpty
              ? "Thêm sản phẩm mới"
              : widget.item.nameProduct.toString(),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            //MÃ SẢN PHẨM
            CustomTextField(
              label: "Mã sản phẩm:",
              controller: productIDController,
              hintText: "Nhập mã sản phẩm",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 15),
            //MÃ KEETON
            CustomTextField(
              label: "Mã keeton:",
              controller: keetonController,
              hintText: "Nhập mã keeton",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),
            //MÃ CÔNG NGHIỆP
            CustomTextField(
              label: "Mã công nghiệp:",
              controller: industrialController,
              hintText: "Nhập công nghiệp",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),
            //DANH ĐIỂM
            CustomTextField(
              label: "Danh điểm:",
              controller: partNoController,
              hintText: "Nhập danh điểm",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),
            //DANH ĐIỂM TƯƠNG ĐƯƠNG
            CustomTextField(
              label: "Danh điểm tương đương:",
              controller: replacedPartNoController,
              hintText: "Nhập danh điểm tương đương",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),
            //TÊN SẢN PHẨM
            CustomTextField(
              label: "Tên sản phẩm:",
              controller: nameProductController,
              hintText: "Tên sản phẩm",
              readOnly: widget.readOnly,
            ),
            // const SizedBox(height: 10),
            //SỐ LƯỢNG DỰ KIẾN
            // CustomTextField(
            //   label: "Số lượng dự kiến:",
            //   controller: qtyExpectedController,
            //   hintText: "Nhập số dự kiến",
            //   keyboardType: TextInputType.numberWithOptions(
            //     decimal: true,
            //     signed: true,
            //   ),
            //   readOnly: widget.readOnly,
            //   inputFormatters: [DotToMinusFormatter()],
            // ),
            // const SizedBox(height: 10),
            // //MÃ HÓA ĐƠN
            // CustomTextField(
            //   label: "Mã số hóa đơn:",
            //   controller: idBillController,
            //   hintText: "Mã số hóa đơn",
            //   readOnly: widget.readOnly,
            // ),
            const SizedBox(height: 10),
            //THÔNG SỐ
            CustomTextField(
              label: "Thông số:",
              controller: parameterController,
              hintText: "Thông số",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),

            // ======= DROPDOWN =======
            //LOẠI XE
            CustomDropdownField(
              label: "Hãng xe",
              selectedValue: selectedVehicleType,
              items: vehicles,
              getLabel: (i) => i.VehicleTypeName.toString(),
              onChanged: (v) => setState(() => selectedVehicleType = v),
              readOnly: widget.readOnly,
              isSearch: true,
              isCreate: StatusCreate,
              textCreate: "Thêm mới loại xe",
              functionCreate: () async {
                // 👇 Tắt dropdown tự động, mở dialog thêm mới
                final result = await showAddDialogDynamic(context, model: 4);
                if (result != null) {
                  await _loadAllData(); // reload danh sách
                  setState(() {}); // cập nhật lại UI
                }
              },
            ),
            const SizedBox(height: 10),
            //DÒNG XE
            CustomTextField(
              label: "Dòng xe:",
              controller: vehicleDetailController,
              hintText: "Nhập dòng xe",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),
            //NHÀ SẢN XUẤT
            CustomDropdownField(
              label: "Nhà sản xuất",
              selectedValue: selectedManufacturer,
              items: manufacturers,
              getLabel: (i) => i.Name.toString(),
              onChanged: (v) => setState(() => selectedManufacturer = v),
              readOnly: widget.readOnly,
              isSearch: true,
              isCreate: StatusCreate,
              textCreate: "Thêm mới nhà sản xuất",
              functionCreate: () async {
                // 👇 Tắt dropdown tự động, mở dialog thêm mới
                final result = await showAddDialogDynamic(context, model: 4);
                if (result != null) {
                  await _loadAllData(); // reload danh sách
                  setState(() {}); // cập nhật lại UI
                }
              },
            ),
            const SizedBox(height: 15),
            //QUỐC GIA
            CustomDropdownField(
              label: "Quốc gia",
              selectedValue: selectedCountry,
              items: countries,
              getLabel: (i) => i.Name.toString(),
              onChanged: (v) => setState(() => selectedCountry = v),
              readOnly: widget.readOnly,
              isCreate: StatusCreate,
              isSearch: true,
              textCreate: "Thêm mới quốc gia",
              functionCreate: () async {
                // 👇 Tắt dropdown tự động, mở dialog thêm mới
                final result = await showAddDialogDynamic(context, model: 1);
                if (result != null) {
                  await _loadAllData(); // reload danh sách
                  setState(() {}); // cập nhật lại UI
                }
              },
            ),

            const SizedBox(height: 15),
            //NHÀ PHÂN KHỐI THỰC TẾ
            CustomDropdownField(
              label: "Nhà phân phối thực tế",
              selectedValue: selectedSupplierActual,
              items: supplierActuals,
              getLabel: (i) => i.Name.toString(),
              onChanged: (v) => setState(() => selectedSupplierActual = v),
              readOnly: widget.readOnly,
              isCreate: StatusCreate,
              isSearch: true,
              textCreate: "Thêm mới nhà phân phối",
              functionCreate: () async {
                // 👇 Tắt dropdown tự động, mở dialog thêm mới
                final result = await showAddDialogDynamic(context, model: 5);
                if (result != null) {
                  await _loadAllData(); // reload danh sách
                  setState(() {}); // cập nhật lại UI
                }
              },
            ),
            const SizedBox(height: 15),
            //NHÀ PHÂN KHỐI GIẤY TỜ
            CustomDropdownField(
              label: "Nhà phân phối giấy tờ",
              selectedValue: selectedSupplier,
              items: suppliers,
              getLabel: (i) => i.Name.toString(),
              onChanged: (v) => setState(() => selectedSupplier = v),
              readOnly: widget.readOnly,
              isCreate: StatusCreate,
              isSearch: true,
              textCreate: "Thêm mới nhà phân phối",
              functionCreate: () async {
                // 👇 Tắt dropdown tự động, mở dialog thêm mới
                final result = await showAddDialogDynamic(context, model: 5);
                if (result != null) {
                  await _loadAllData(); // reload danh sách
                  setState(() {}); // cập nhật lại UI
                }
              },
            ),
            const SizedBox(height: 15),
            //ĐƠN VỊ TÍNH
            CustomDropdownField(
              label: "Đơn vị tính:",
              selectedValue: selectedUnit,
              items: units,
              getLabel: (i) => i.Name.toString(),
              onChanged: (v) => setState(() => selectedUnit = v),
              readOnly: widget.readOnly,
              isCreate: StatusCreate,
              isSearch: true,
              textCreate: "Thêm mới đơn vị tính",
              functionCreate: () async {
                // 👇 Tắt dropdown tự động, mở dialog thêm mới
                final result = await showAddDialogDynamic(context, model: 6);
                if (result != null) {
                  await _loadAllData(); // reload danh sách
                  setState(() {}); // cập nhật lại UI
                }
              },
            ),
            const SizedBox(height: 15),
            //GHI CHÚ
            CustomTextField(
              label: "Ghi chú:",
              controller: remarkController,
              hintText: "Ghi chú",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),

            // ======= ẢNH =======
            CustomTextFieldIcon(
              label: "Ảnh 1 sản phẩm",
              controller: image1Controller, // sẽ chứa đường link sau khi upload
              prefixIcon: Icons.image_outlined,
              suffixIcon: Icons.camera_alt,
              readOnly: true,
              onSuffixIconPressed: () async {
                // Gọi helper upload
                await ImagePickerHelper().showImageOptions(
                  context: context,
                  currentImageUrl: image1Controller.text,
                  productID: productIDController.text,
                  isUpdate: widget.isUpDate || widget.isCreate,
                  nameImg: "img1",
                  // wh: ,
                  onImageChanged: (url) {
                    // Cập nhật TextField khi upload thành công
                    setState(() {
                      image1Controller.text = url ?? '';
                    });
                  },
                  // wh: widget.item,
                );
              },
            ),

            const SizedBox(height: 25),
            CustomTextFieldIcon(
              label: "Ảnh 2 sản phẩm: ",
              controller: image2Controller,
              prefixIcon: Icons.image_outlined,
              suffixIcon: Icons.camera_alt,
              readOnly: true,
              onSuffixIconPressed: () async {
                // Gọi helper upload
                await ImagePickerHelper().showImageOptions(
                  context: context,
                  currentImageUrl: image2Controller.text,
                  nameImg: "img2",
                  isUpdate: widget.isUpDate,
                  productID: productIDController.text,
                  onImageChanged: (url) {
                    // Cập nhật TextField khi upload thành công
                    setState(() {
                      image2Controller.text = url ?? '';
                    });
                  },
                  // wh: widget.item,
                );
              },
            ),

            const SizedBox(height: 25),
            CustomTextFieldIcon(
              label: "Ảnh 3 sản phẩm: ",
              controller: image3Controller,
              prefixIcon: Icons.image_outlined,
              suffixIcon: Icons.camera_alt,
              readOnly: true,
              onSuffixIconPressed: () async {
                // Gọi helper upload
                await ImagePickerHelper().showImageOptions(
                  context: context,
                  currentImageUrl: image3Controller.text,
                  productID: productIDController.text,
                  nameImg: "img3",
                  isUpdate: widget.isUpDate,
                  onImageChanged: (url) {
                    // Cập nhật TextField khi upload thành công
                    setState(() {
                      image3Controller.text = url ?? '';
                    });
                  },
                  // wh: widget.item,
                );
              },
            ),

            const Divider(),

            const SizedBox(height: 25),
            Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // căn giữa hàng ngang
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    onPressed:
                        (widget.isUpDate ||
                                widget.isCreate ||
                                widget.isCreateHistory) &&
                            !isSaving
                        ? _upDateWareHouse
                        : null,
                    icon: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            // child: CircularProgressIndicator(
                            //   strokeWidth: 2,
                            //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            // ),
                            // child: _buildLoading(),
                          )
                        : const Icon(Icons.save),
                    label: Text(isSaving ? "Đang lưu..." : "Lưu thay đổi"),
                  ),
                  const SizedBox(width: 20), // khoảng cách giữa 2 nút
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Quay lại"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
