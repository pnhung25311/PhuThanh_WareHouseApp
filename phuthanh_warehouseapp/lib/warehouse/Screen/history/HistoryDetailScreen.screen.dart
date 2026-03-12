import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/formatters/DotToMinusFormatte.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDatePicker.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDialogAppendix.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomSmartDropdown.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Employee.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Location.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
// import 'package:phuthanh_warehouseapp/model/warehouse/History.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/ViewHistory.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Unit.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';
import 'package:collection/collection.dart';

class HistoryDetailScreen extends StatefulWidget {
  final WareHouse item;
  final ViewHistory? itemHistory;
  final bool isUpDate;
  final bool isCreate;
  final bool isCreateHistory;
  final bool isReadOnlyHistory;
  final bool readOnly;

  HistoryDetailScreen({
    super.key,
    required this.item,
    this.itemHistory, // ✅ đổi thành nullable
    this.isUpDate = false,
    this.isCreate = false,
    this.isCreateHistory = false,
    this.isReadOnlyHistory = false,
    this.readOnly = false,
  }); // ✅ gán mặc định ở đây

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  List<Country> countries = [];
  List<Manufacturer> manufacturers = [];
  List<Supplier> suppliers = [];
  List<Supplier> suppliersHistory = [];
  //1 là nhà cung cấp; 2 là nhập khẩu; 3 là khách hàng
  List<Supplier> supplierActuals = [];
  List<Unit> units = [];
  List<Employee> emps = [];

  List<Location> locations = [];
  List<Location> selectedLocation = [];
  List<int> selectedLocationIds = [];
  List<VehicleType> vehicles = [];

  Country? selectedCountry;
  Manufacturer? selectedManufacturer;
  Supplier? selectedSupplier;
  Supplier? selectedSupplierHistory;
  Supplier? selectedSupplierActual;
  Unit? selectedUnit;
  Employee? selectedEmployee;
  String? selectedTimePicker;
  VehicleType? selectedVehicleType;
  InfoService infoService = InfoService();

  final TextEditingController remarkController = TextEditingController();
  final TextEditingController productIDController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController qtyExpectedController = TextEditingController();
  final TextEditingController keetonController = TextEditingController();
  final TextEditingController industrialController = TextEditingController();
  final TextEditingController partNoController = TextEditingController();
  final TextEditingController nameProductController = TextEditingController();
  final TextEditingController idBillController = TextEditingController();
  final TextEditingController parameterController = TextEditingController();
  final TextEditingController replacedPartNoController =
      TextEditingController();
  final TextEditingController image1Controller = TextEditingController();
  final TextEditingController image2Controller = TextEditingController();
  final TextEditingController image3Controller = TextEditingController();

  final TextEditingController qtyHistoryController = TextEditingController();
  final TextEditingController idEmployeeController = TextEditingController();
  final TextEditingController partnerController = TextEditingController();
  final TextEditingController remarkOfHistoryController =
      TextEditingController();
  final TextEditingController vehicleDetailController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController supplierHistoryController =
      TextEditingController();
  final TextEditingController employeeHistoryController =
      TextEditingController();

  bool loading = true;
  Key dropdownKey = UniqueKey();
  DateTime initialDate = DateTime.now(); // ⚡ biến state
    Formatdatehelper formatdatehelper = Formatdatehelper();


  // bool StatusCreate = AppState.instance.get("CreateAppendix");
  bool StatusCreate = true;
  final GlobalKey _targetKey = GlobalKey(); // key của ô muốn scroll tới

  @override
  void initState() {
    super.initState();
    remarkController.text = widget.item.remarkOfDataWarehouse.toString();
    productIDController.text = widget.item.productID.toString();
    qtyController.text = widget.item.qty.toString();
    qtyExpectedController.text = widget.item.qtyExpected?.toString() ?? "";
    keetonController.text = widget.item.idKeeton ?? "";
    industrialController.text = widget.item.idIndustrial.toString();
    partNoController.text = widget.item.idPartNo ?? "";
    replacedPartNoController.text = widget.item.idReplacedPartNo ?? "";
    nameProductController.text = widget.item.nameProduct.toString();
    idBillController.text = widget.item.idBill ?? "";
    parameterController.text = widget.item.parameter.toString();
    vehicleDetailController.text = widget.item.vehicleDetail.toString();

    image1Controller.text = widget.item.img1.toString();
    image2Controller.text = widget.item.img2.toString();
    image3Controller.text = widget.item.img3.toString();

    if (widget.itemHistory?.dataWareHouseAID!=null) {
      qtyHistoryController.text = widget.itemHistory?.qty.toString() ?? '';
      remarkOfHistoryController.text = widget.itemHistory?.remark ?? '';
      timeController.text = widget.itemHistory?.time.toString() ?? '';
      supplierHistoryController.text =
          widget.itemHistory?.partner.toString() ?? '';
      employeeHistoryController.text =
          widget.itemHistory?.employeeId.toString() ?? '';
    }

    _init().then((_) {
      // 💡 Chỉ cuộn khi đang ở chế độ tạo mới
      if (widget.isCreateHistory) {
        // Dùng Future.microtask để đảm bảo widget đã được render xong
        Future.microtask(() {
          Scrollable.ensureVisible(
            _targetKey.currentContext!,
            duration: const Duration(milliseconds: 100), // Thời gian cuộn
            alignment: 0.0, // Cuộn để widget nằm ở đầu màn hình
          );
        });
      }
    });
  }

  // thêm helper init để await các load
  Future<void> _init() async {
    await _loadAllData();
    await _loadDataLocation();
    await loadSuppliers();
    await loadTime();
    await _loadDataEmployee();
    await _loadDataSupplier();
  }

  Future<void> loadSuppliers() async {
    // final supplierAppState = await AppState.instance.get(
    //   "supplierAppStateHistory",
    // );
    // if (supplierAppState != null) {
    //   suppliersHistory = supplierAppState;
    // } else {
    //   suppliersHistory = await InfoService.LoadDtataSupplier();
    //   AppState.instance.set("supplierAppStateHistory", suppliersHistory);
    // }

    if ((widget.itemHistory?.partner.toString().isNotEmpty ?? false) &&
        suppliersHistory.isNotEmpty) {
      selectedSupplierHistory = suppliersHistory.firstWhereOrNull(
        (s) =>
            s.SupplierID.toString() ==
            (widget.itemHistory?.partner.toString() ?? ''),
      );
    }

    setState(() {}); // ⚡️ cập nhật lại dropdown
  }

  Future<void> loadTime() async {
    // 1. Load danh sách suppliers
    suppliersHistory = await infoService.LoadDtataSupplier();

    // 2. Set selectedSupplier nếu có giá trị trong itemHistory
    if ((widget.itemHistory?.partner.toString().isNotEmpty ?? false) &&
        suppliersHistory.isNotEmpty) {
      selectedSupplierHistory = suppliersHistory.firstWhereOrNull(
        (s) =>
            s.SupplierID.toString() == widget.itemHistory?.partner.toString(),
        // orElse: () => suppliersHistory.first,
      );
    }

    // 3. Set initialDate nếu bạn muốn dùng itemHistory.time
    final timeString = widget.itemHistory?.time ?? '';

    if (timeString.isNotEmpty) {
      initialDate = DateTime.tryParse(timeString) ?? DateTime.now();
    } else {
      initialDate = DateTime.now();
    }

    setState(() {}); // ⚡ cập nhật lại dropdown và DatePicker
  }

  DateTime parseDateManual(String dateStr) {
    return formatdatehelper.parseDate(dateStr);
  }

  Future<void> _loadDataLocation() async {
    AppState.instance.set("locationAppState", null);
    final locationAppState = await AppState.instance.get("locationAppState");
    if (locationAppState != null) {
      locations = locationAppState;
      setState(() {
        dropdownKey = UniqueKey();
      });
    } else {
      final callLocation = await infoService.fetchLocations();
      locations = callLocation;
      AppState.instance.set("locationAppState", callLocation);
      setState(() {
        dropdownKey = UniqueKey();
      });
    }
    String location = widget.item.locationID.toString();
    selectedLocationIds = location
        .split(',')
        .map((e) => e.trim())
        .where((e) => int.tryParse(e) != null)
        .map((e) => int.parse(e))
        .toList();

    selectedLocation = locations
        .where((loc) => selectedLocationIds.contains(loc.LocationID))
        .toList();
  }

  Future<void> _loadDataEmployee() async {
    try {
      // 1️⃣ Load danh sách employee từ API
      AppState.instance.set("employeeAppState", null);
      final employeeAppState = await AppState.instance.get("employeeAppState");
      if (employeeAppState != null) {
        emps = employeeAppState;
        setState(() {});
      } else {
        final empRes = await infoService.LoadDtataEmployee();
        AppState.instance.set("employeeAppState", empRes);
        emps = empRes;
        if (emps.isNotEmpty) {
          selectedEmployee = emps.first;
        }
        setState(() {});
      }
      // 2️⃣ Xác định employee được chọn theo thứ tự ưu tiên:
      // a) Employee đã ghim (pin)
      // final pinnedEmpId = AppState.instance.get("employee")?.toString();
      // if (pinnedEmpId != null && pinnedEmpId.isNotEmpty) {
      //   selectedEmployee = emps.firstWhereOrNull(
      //     (e) => e.EmployeeID.toString() == pinnedEmpId,
      //     // orElse: () => emps.first,
      //   );
      //   return; // đã chọn xong, không cần tiếp tục
      // }

      // b) Employee từ lịch sử (itemHistory)
      if (widget.itemHistory?.employeeId.toString().isNotEmpty??false) {
        selectedEmployee = emps.firstWhereOrNull(
          (e) => e.EmployeeID == widget.itemHistory?.employeeId,
          // orElse: () => emps.first,
        );
        return;
      }

      // c) fallback: chọn employee đầu danh sách
    } catch (e) {
      print("❌ Lỗi load dữ liệu employee: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadDataSupplier() async {
    try {
      AppState.instance.set("suppliersHistory", null);
      final supplierAppState = await AppState.instance.get("suppliersHistory");
      if (supplierAppState != null) {
        suppliersHistory = supplierAppState;
      }
      // else {
      //   suppliersHistory = await InfoService.LoadDtataSupplier();
      //   AppState.instance.set("suppliersHistory", suppliersHistory);
      // }
      if (!mounted) return;
      setState(() {
        // Ưu tiên giá trị partner pin
        final storedPartnerId = AppState.instance.get("partner")?.toString();
        if (storedPartnerId != null && storedPartnerId.isNotEmpty) {
          selectedSupplierHistory = suppliersHistory.firstWhereOrNull(
            (s) => s.SupplierID.toString() == storedPartnerId,
            // orElse: () => suppliersHistory.first,
          );
        }
        // Nếu không có pin thì dùng itemHistory
        else if (widget.itemHistory?.partner.toString().isNotEmpty??false) {
          selectedSupplierHistory = suppliersHistory.firstWhereOrNull(
            (s) =>
                s.SupplierID.toString() ==
                widget.itemHistory?.partner.toString(),
            // orElse: () => suppliersHistory.first,
          );
        }
        // Fallback: chọn item đầu tiên
      });
    } catch (e) {
      print("❌ Lỗi load dữ liệu: $e");
      setState(() => loading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item.nameProduct?.isEmpty ?? true
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
            const SizedBox(height: 10),
            //SỐ LƯỢNG
            CustomTextField(
              label: "Số lượng:",
              controller: qtyController,
              hintText: "Nhập số lượng mới",
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            //THÔNG SỐ
            CustomTextField(
              label: "Thông số:",
              controller: parameterController,
              hintText: "Thông số",
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 10),
            //LOẠI XE
            CustomDropdownField(
              label: "Loại xe",
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
            // ======= DROPDOWN =======
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
            //NHÀ CUNG CẤP
            CustomDropdownField(
              label: "Nhà cung cấp: ",
              selectedValue: selectedSupplier,
              items: suppliers,
              getLabel: (i) => i.Name.toString(),
              onChanged: (v) => setState(() => selectedSupplier = v),
              readOnly: widget.readOnly,
              isCreate: StatusCreate,
              isSearch: true,
              textCreate: "Thêm mới nhà cung cấp",
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
            //SỐ LƯỢNG DỰ KIẾN
            CustomTextField(
              label: "Số lượng dự kiến:",
              controller: qtyExpectedController,
              hintText: "Nhập số dự kiến",
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              readOnly: widget.isReadOnlyHistory,
              inputFormatters: [DotToMinusFormatter()],
            ),
            const SizedBox(height: 10),
            //MÃ HÓA ĐƠN
            CustomTextField(
              label: "Mã số hóa đơn:",
              controller: idBillController,
              hintText: "Mã số hóa đơn",
              readOnly: widget.isReadOnlyHistory,
            ),
            const SizedBox(height: 10),

            // ======= LOCATION =======
            SmartDropdown<Location>(
              key: dropdownKey,
              labelBuilder: (loc) => loc.NameLocation,
              items: locations,
              hint: "Chọn vị trí",
              isSearch: true,
              isMultiSelect: true,
              readOnly: widget.isReadOnlyHistory,
              initialValues: selectedLocation, // ✅ dùng plural
              onChanged: (values) => setState(() {
                selectedLocation = List<Location>.from(values as List);
                selectedLocationIds = selectedLocation
                    .map((e) => e.LocationID)
                    .toList();
              }),
            ),
            const Divider(),
            // ======= HISTORY =======
            //SỐ LƯỢNG NHẬP/XUẤT
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomTextFieldIcon(
                key: widget.isCreateHistory ? _targetKey : null,
                label: "Nhập số lượng nhập/xuất: ",
                controller: qtyHistoryController,
                hintText: "Nhập số lượng nhập/xuất",
                readOnly: widget.isReadOnlyHistory,
                keyboardType: TextInputType.numberWithOptions(
                  signed: true, // cho phép dấu âm
                  decimal: true, // cho phép dấu thập phân
                ),
                inputFormatters: [DotToMinusFormatter()],
              ),
            ),
            const SizedBox(height: 10),
            //NHÂN VIÊN
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomDropdownField(
                label: "Nhân viên:",
                selectedValue: selectedEmployee,
                items: emps,
                getLabel: (i) => i.NameEmployee.toString(),
                onChanged: (v) => setState(() => selectedEmployee = v),
                isSearch: true,
                isCreate: StatusCreate,
                textCreate: "Thêm mới nhân viên",
                readOnly: widget.isReadOnlyHistory,
              ),
            ),
            const SizedBox(height: 10),
            //ĐỐI TÁC
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomDropdownField(
                label: "Đối tác:",
                selectedValue: selectedSupplierHistory,
                items: suppliersHistory,
                getLabel: (i) => i.Name.toString(),
                onChanged: (v) => setState(() => selectedSupplierHistory = v),
                textCreate: "Thêm mới đối tác",
                isSearch: true,
                isCreate: StatusCreate,
                readOnly: widget.isReadOnlyHistory,
              ),
            ),
            //THỜI GIAN
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomDateTimePicker(
                key: ValueKey(initialDate),
                label: "Chọn ngày nhập/xuất:",
                initialDate: widget.isCreateHistory
                    ? initialDate
                    : parseDateManual(timeController.text),
                onChanged: (value) {
                  setState(() {
                    selectedTimePicker = formatdatehelper.formatYMDHMS(value);
                    initialDate = value;
                  });
                },
                readOnly: widget.isReadOnlyHistory,
              ),
            ),
            //GHI CHÚ CỦA NHẬP XUẤT
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomTextFieldIcon(
                label: "Diễn giải: ",
                controller: remarkOfHistoryController,
                hintText: "Nhập diễn giải ",
                readOnly: widget.isReadOnlyHistory,
              ),
            ),

            const SizedBox(height: 25),
            Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // căn giữa hàng ngang
                children: [
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
