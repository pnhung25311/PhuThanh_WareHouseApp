import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/formatters/DotToMinusFormatte.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDatePicker.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDialogAppendix.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomSmartDropdown.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextField.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/ImagePickerHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Employee.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Location.model.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/History.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Unit.model.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class WarehouseDetailScreen extends StatefulWidget {
  final WareHouse item;
  final History itemHistory;
  final bool isUpDate;
  final bool isCreate;
  final bool isCreateHistory;
  final bool isReadOnlyHistory;
  final bool readOnly;

  WarehouseDetailScreen({
    super.key,
    required this.item,
    History? itemHistory, // ✅ đổi thành nullable
    this.isUpDate = false,
    this.isCreate = false,
    this.isCreateHistory = false,
    this.isReadOnlyHistory = false,
    this.readOnly = false,
  }) : itemHistory = itemHistory ?? History.empty(); // ✅ gán mặc định ở đây

  @override
  State<WarehouseDetailScreen> createState() => _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends State<WarehouseDetailScreen> {
  List<Country> countries = [];
  List<Manufacturer> manufacturers = [];
  List<Supplier> suppliers = [];
  //1 là nhà cung cấp; 2 là nhập khẩu; 3 là khách hàng
  List<Supplier> suppliers1 = [];
  List<Supplier> suppliers2 = [];
  List<Supplier> suppliers3 = [];
  List<Unit> units = [];
  List<Employee> emps = [];

  List<Location> locations = [];
  List<Location> selectedLocation = [];
  List<int> selectedLocationIds = [];

  Country? selectedCountry;
  Manufacturer? selectedManufacturer;
  Supplier? selectedSupplier;
  Supplier? selectedSupplier2;
  Supplier? selectedSupplier3;
  Unit? selectedUnit;
  Employee? selectedEmployee;
  String? selectedTimePicker;

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
  final TextEditingController timeController = TextEditingController();
  final TextEditingController supplierHistoryController =
      TextEditingController();
  final TextEditingController employeeHistoryController =
      TextEditingController();

  bool loading = true;
  Key dropdownKey = UniqueKey();
  DateTime initialDate = DateTime.now(); // ⚡ biến state

  bool StatusCreate = AppState.instance.get("CreateAppendix");
  final GlobalKey _targetKey = GlobalKey(); // key của ô muốn scroll tới

  @override
  void initState() {
    super.initState();
    remarkController.text = widget.item.remark;
    productIDController.text = widget.item.productID;
    qtyController.text = widget.item.qty.toString();
    qtyExpectedController.text = widget.item.qtyExpected.toString();
    keetonController.text = widget.item.idKeeton ?? "";
    industrialController.text = widget.item.idIndustrial;
    partNoController.text = widget.item.idPartNo ?? "";
    replacedPartNoController.text = widget.item.idReplacedPartNo ?? "";
    nameProductController.text = widget.item.nameProduct;
    idBillController.text = widget.item.idBill;
    parameterController.text = widget.item.parameter;
    image1Controller.text = widget.item.img1;
    image2Controller.text = widget.item.img2;
    image3Controller.text = widget.item.img3;

    if (widget.itemHistory.productID?.isNotEmpty ?? false) {
      qtyHistoryController.text = widget.itemHistory.qty.toString();
      remarkOfHistoryController.text = widget.itemHistory.remark ?? "";
      timeController.text = widget.itemHistory.time.toString();
      supplierHistoryController.text = widget.itemHistory.partner
          .toString(); // ID hoặc tên tùy theo model
      employeeHistoryController.text = widget.itemHistory.idEmployee.toString();
    }
    qtyHistoryController.addListener(() async {
      final api = const ApiClient();

      double query = double.tryParse(qtyHistoryController.text) ?? 0;

      String category;
      if (query > 0) {
        category = "dynamic/find/supplier/category/2";
      } else if (query < 0) {
        category = "dynamic/find/supplier/category/3";
      } else {
        category = "dynamic/get-all/supplier"; // default khi bằng 0 hoặc rỗng
      }

      try {
        final response = await api.get(category);
        if (response.statusCode == 200) {
          final newSuppliers = (jsonDecode(response.body) as List)
              .map((e) => Supplier.fromJson(e))
              .toList();
          if (newSuppliers.isNotEmpty && mounted) {
            setState(() {
              suppliers = newSuppliers;
              selectedSupplier = suppliers.first;
            });
          }
        }
      } catch (e) {
        print("❌ Lỗi load suppliers: $e");
      }
    });
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
    await _loadPinnedDate();
    await _loadPinnedRemarkOfHistory();
  }

  Future<void> loadSuppliers() async {
    suppliers = await InfoService.LoadDtataSupplier();

    if (widget.itemHistory.partner != null && suppliers.isNotEmpty) {
      selectedSupplier = suppliers.firstWhere(
        (s) => s.SupplierID.toString() == widget.itemHistory.partner.toString(),
        orElse: () => suppliers.first,
      );
    }

    setState(() {}); // ⚡️ cập nhật lại dropdown
  }

  Future<void> loadTime() async {
    // 1. Load danh sách suppliers
    suppliers = await InfoService.LoadDtataSupplier();

    // 2. Set selectedSupplier nếu có giá trị trong itemHistory
    if (widget.itemHistory.partner != null && suppliers.isNotEmpty) {
      selectedSupplier = suppliers.firstWhere(
        (s) => s.SupplierID.toString() == widget.itemHistory.partner.toString(),
        orElse: () => suppliers.first,
      );
    }

    // 3. Set initialDate nếu bạn muốn dùng itemHistory.time
    if (widget.itemHistory.time != null &&
        widget.itemHistory.time!.isNotEmpty) {
      initialDate =
          DateTime.tryParse(widget.itemHistory.time!) ?? DateTime.now();
    } else {
      initialDate = DateTime.now();
    }
    print(widget.itemHistory.time);

    setState(() {}); // ⚡ cập nhật lại dropdown và DatePicker
  }

  DateTime parseDateManual(String dateStr) {
    return Formatdatehelper.parseDate(dateStr);
  }

  Future<void> _loadDataLocation() async {
    final callLocation = await InfoService.fetchLocations();
    locations = callLocation;

    // VD: widget.item.locationID = "1,2,3"
    String location = widget.item.locationID;
    selectedLocationIds = location
        .split(',')
        .where((e) => e.isNotEmpty)
        .map((e) => int.parse(e))
        .toList();

    selectedLocation = locations
        .where((loc) => selectedLocationIds.contains(loc.LocationID))
        .toList();
    print(selectedLocation);

    setState(() {
      dropdownKey = UniqueKey();
    });
  }

  Future<void> _loadDataEmployee() async {
    final api = const ApiClient();

    try {
      // 1️⃣ Load danh sách employee từ API
      final empRes = await api.get("dynamic/get-all/Employee");

      if (empRes.statusCode == 200) {
        List<Employee> loadedEmps = (jsonDecode(empRes.body) as List)
            .map((e) => Employee.fromJson(e))
            .toList();

        setState(() {
          emps = loadedEmps;
        });

        // 2️⃣ Xác định employee được chọn theo thứ tự ưu tiên:
        // a) Employee đã ghim (pin)
        final pinnedEmpId = AppState.instance.get("employee")?.toString();
        if (pinnedEmpId != null && pinnedEmpId.isNotEmpty) {
          selectedEmployee = emps.firstWhere(
            (e) => e.EmployeeID.toString() == pinnedEmpId,
            orElse: () => emps.first,
          );
          return; // đã chọn xong, không cần tiếp tục
        }

        // b) Employee từ lịch sử (itemHistory)
        if (widget.itemHistory.idEmployee != null) {
          selectedEmployee = emps.firstWhere(
            (e) => e.EmployeeID == widget.itemHistory.idEmployee,
            orElse: () => emps.first,
          );
          return;
        }

        // c) fallback: chọn employee đầu danh sách
        if (emps.isNotEmpty) {
          selectedEmployee = emps.first;
        }
      }
    } catch (e) {
      print("❌ Lỗi load dữ liệu employee: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadDataSupplier() async {
    final api = const ApiClient();
    try {
      final suppRes = await api.get("dynamic/get-all/Supplier");
      if (suppRes.statusCode == 200) {
        final loadedSuppliers = (jsonDecode(suppRes.body) as List)
            .map((e) => Supplier.fromJson(e))
            .toList();

        if (!mounted) return;
        setState(() {
          suppliers = loadedSuppliers;

          // Ưu tiên giá trị partner pin
          final storedPartnerId = AppState.instance.get("partner")?.toString();
          if (storedPartnerId != null && storedPartnerId.isNotEmpty) {
            selectedSupplier = suppliers.firstWhere(
              (s) => s.SupplierID.toString() == storedPartnerId,
              orElse: () => suppliers.first,
            );
          }
          // Nếu không có pin thì dùng itemHistory
          else if (widget.itemHistory.partner != null) {
            selectedSupplier = suppliers.firstWhere(
              (s) =>
                  s.SupplierID.toString() ==
                  widget.itemHistory.partner.toString(),
              orElse: () => suppliers.first,
            );
          }
          // Fallback: chọn item đầu tiên
          else if (suppliers.isNotEmpty) {
            selectedSupplier = suppliers.first;
          }
        });
      }
    } catch (e) {
      print("❌ Lỗi load dữ liệu: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _loadPinnedDate() async {
    DateTime? pinnedDate = Formatdatehelper.loadPinnedDate();

    setState(() {
      initialDate = pinnedDate ?? DateTime.now();
      selectedTimePicker = Formatdatehelper.formatYMD(initialDate);
    });
  }

  Future<void> _loadPinnedRemarkOfHistory() async {
    String? pinnedRemarkOfHistory = AppState.instance.get("PinRemark");
    if (pinnedRemarkOfHistory != null && pinnedRemarkOfHistory.isNotEmpty) {
      setState(() {
        remarkOfHistoryController.text = pinnedRemarkOfHistory;
      });
    }
  }

  Future<void> _loadAllData() async {
    final api = const ApiClient();

    try {
      final countryRes = await api.get("dynamic/get-all/Country");
      final manuRes = await api.get("dynamic/get-all/Manufacturer");
      final suppRes = await api.get(
        "dynamic/get-all/Supplier",
      ); //1 là nhà cung cấp; 2 là nhập khẩu; 3 là khách hàng
      final unitRes = await api.get("dynamic/get-all/Unit");

      if (countryRes.statusCode == 200 &&
          manuRes.statusCode == 200 &&
          suppRes.statusCode == 200 &&
          unitRes.statusCode == 200) {
        setState(() {
          countries = (jsonDecode(countryRes.body) as List)
              .map((e) => Country.fromJson(e))
              .toList();

          manufacturers = (jsonDecode(manuRes.body) as List)
              .map((e) => Manufacturer.fromJson(e))
              .toList();

          suppliers = (jsonDecode(suppRes.body) as List)
              .map((e) => Supplier.fromJson(e))
              .toList();

          units = (jsonDecode(unitRes.body) as List)
              .map((e) => Unit.fromJson(e))
              .toList();

          selectedCountry = countries.firstWhere(
            (e) => e.CountryID.toString() == widget.item.countryID.toString(),
            orElse: () => countries.first,
          );
          selectedManufacturer = manufacturers.firstWhere(
            (e) =>
                e.ManufacturerID.toString() ==
                widget.item.manufacturerID.toString(),
            orElse: () => manufacturers.first,
          );
          selectedSupplier = suppliers.firstWhere(
            (e) => e.SupplierID.toString() == widget.item.supplierID.toString(),
            orElse: () => suppliers.first,
          );
          selectedUnit = units.firstWhere(
            (e) => e.UnitID.toString() == widget.item.unitID.toString(),
            orElse: () => units.first,
          );
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Lỗi load dữ liệu: $e");
      setState(() => loading = false);
    }
  }

  void _saveChanges() async {
    print("✅ Dữ liệu cập nhật:");
    print(" - Country: ${selectedCountry?.Name}");
    print(" - Manufacturer: ${selectedManufacturer?.Name}");
    print(" - Supplier: ${selectedSupplier?.Name}");
    print(" - Qty: ${qtyController.text}");
    print(" - Remark: ${remarkController.text}");
    print(" - FullName: ${await getFullname()}");
    print(" - Location: ");
    print(selectedLocation);
  }

  Future<String?> getFullname() async {
    Map<String, dynamic>? account = await MySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["FullName"];
    return fullname;
  }

  Future<String> _loadData() async {
    final table = await MySharedPreferences.getDataString("statusWH");
    final safeTable = table ?? "WareHouseA";
    return safeTable;
  }

  void _upDateWareHouse() async {
    _saveChanges();
    try {
      final api = const ApiClient();
      final helper = ImagePickerHelper();
      String? fullName = await getFullname();
      String? warehouse = await _loadData();
      String locaResult = selectedLocationIds.join(",");

      final file1 = AppState.instance.get<File?>('img1');
      final file2 = AppState.instance.get<File?>('img2');
      final file3 = AppState.instance.get<File?>('img3');

      print(file1);
      print(file2);
      print(file3);

      String? linkUpload1;
      String? linkUpload2;
      String? linkUpload3;

      if (file1 != null) {
        linkUpload1 = await helper.uploadImage(file1, productIDController.text);
        AppState.instance.remove('img1');
      }

      if (file2 != null) {
        linkUpload2 = await helper.uploadImage(file2, productIDController.text);
        AppState.instance.remove('img2');
      }

      if (file3 != null) {
        linkUpload3 = await helper.uploadImage(file3, productIDController.text);
        AppState.instance.remove('img3');
      }

      print(linkUpload1);
      print(linkUpload2);
      print(linkUpload3);

      image1Controller.text = linkUpload1 ?? "";
      image2Controller.text = linkUpload2 ?? "";
      image3Controller.text = linkUpload3 ?? "";

      final Map<String, dynamic> bodyupdate = {
        "id_Keeton": keetonController.text,
        "id_Industrial": industrialController.text,
        "id_PartNo": partNoController.text,
        "id_ReplacedPartNo": replacedPartNoController.text,
        "nameProduct": nameProductController.text,
        "qty": double.tryParse(qtyController.text) ?? 0,
        "qty_Expected": double.tryParse(qtyExpectedController.text) ?? 0,
        "id_Bill": idBillController.text,
        "parameter": parameterController.text,
        "remark": remarkController.text,
        "countryID": selectedCountry?.CountryID,
        "manufacturerID": selectedManufacturer?.ManufacturerID,
        "supplierID": selectedSupplier?.SupplierID,
        "unitID": selectedUnit?.UnitID,
        "locationID": locaResult,
        "img1": image1Controller.text,
        "img2": image2Controller.text,
        "img3": image3Controller.text,
        "LastModifiedTime": DateTime.now(),
        "fullName": fullName,
      };
      final Map<String, dynamic> bodyCreate = {
        "productID": productIDController.text,
        "id_Keeton": keetonController.text,
        "id_Industrial": industrialController.text,
        "id_PartNo": partNoController.text,
        "id_ReplacedPartNo": replacedPartNoController.text,
        "nameProduct": nameProductController.text,
        "qty": double.tryParse(qtyController.text) ?? 0,
        "qty_Expected": double.tryParse(qtyExpectedController.text) ?? 0,
        "id_Bill": idBillController.text,
        "parameter": parameterController.text,
        "remark": remarkController.text,
        "countryID": selectedCountry?.CountryID,
        "manufacturerID": selectedManufacturer?.ManufacturerID,
        "supplierID": selectedSupplier?.SupplierID,
        "unitID": selectedUnit?.UnitID,
        "locationID": locaResult,
        "img1": image1Controller.text,
        "img2": image2Controller.text,
        "img3": image3Controller.text,
        "fullName": fullName,
        "LastModifiedTime": DateTime.now(),
      };

      DateTime now = DateTime.now();
      final Map<String, dynamic> bodyHistory = {
        "productID": widget.item.productID,
        "qty": qtyHistoryController.text,
        "id_Employee": selectedEmployee?.EmployeeID,
        "partner": selectedSupplier?.SupplierID,
        "remark": remarkOfHistoryController.text,
        "time_Update": Formatdatehelper.formatYMD(now),
        "time":
            selectedTimePicker ?? Formatdatehelper.formatYMD(DateTime.now()),
        "fullName": fullName,
      };

      // 🔹 Gọi API PUT (sử dụng hàm put bạn đã thêm trong ApiClient)
      final tableName = await _loadData();

      if (widget.isCreate) {
        final response = await api.post(
          "dynamic/insert/" + tableName,
          bodyCreate,
        );
        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Thêm mới thành công')),
          );
          Navigator.pop(context, true); // quay lại và báo màn trước refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi cập nhật: ${response.statusCode}')),
          );
        }
      }

      if (widget.isUpDate) {
        final response = await api.put(
          "dynamic/update/${tableName}/productID/${widget.item.productID}",
          bodyupdate,
        );
        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Cập nhật thành công')),
          );
          Navigator.pop(context, true); // quay lại và báo màn trước refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi cập nhật: ${response.statusCode}')),
          );
        }
      }

      if (widget.isCreateHistory &&
          qtyHistoryController.text.isNotEmpty &&
          qtyHistoryController.text != "0") {
        final response = await api.post(
          "dynamic/insert/history/" + warehouse,
          bodyHistory,
        );
        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Cập nhật thành công')),
          );
          Navigator.pop(context, true); // quay lại và báo màn trước refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi cập nhật: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi kết nối: $e')));
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
          widget.item.nameProduct == ''
              ? "Thêm sản phẩm mới"
              : widget.item.nameProduct,
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
            //SỐ LƯỢNG DỰ KIẾN
            CustomTextField(
              label: "Số lượng dự kiến:",
              controller: qtyExpectedController,
              hintText: "Nhập số dự kiến",
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              readOnly: widget.readOnly,
              inputFormatters: [DotToMinusFormatter()],
            ),
            const SizedBox(height: 10),
            //MÃ HÓA ĐƠN
            CustomTextField(
              label: "Mã số hóa đơn:",
              controller: idBillController,
              hintText: "Mã số hóa đơn",
              readOnly: widget.readOnly,
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
            //NHÀ PHÂN KHỐI
            CustomDropdownField(
              label: "Nhà phân phối",
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

            // ======= LOCATION =======
            const SizedBox(height: 10),
            SmartDropdown<Location>(
              key: dropdownKey,
              labelBuilder: (loc) => loc.NameLocation,
              items: locations,
              hint: "Chọn vị trí",
              isSearch: true,
              isMultiSelect: true,
              readOnly: widget.readOnly,
              initialValues: selectedLocation, // ✅ dùng plural
              onChanged: (values) => setState(() {
                selectedLocation = List<Location>.from(values as List);
                selectedLocationIds = selectedLocation
                    .map((e) => e.LocationID)
                    .toList();
              }),
              functionCreate: () async {
                // 👇 Tắt dropdown tự động, mở dialog thêm mới
                final result = await showAddDialogDynamic(context, model: 3);
                if (result != null) {
                  await _loadDataLocation(); // reload danh sách
                  setState(() {}); // cập nhật lại UI
                }
              },
              dropdownMaxHeight: 300,
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
                  nameImg: "img1",
                  onImageChanged: (url) {
                    // Cập nhật TextField khi upload thành công
                    setState(() {
                      image1Controller.text = url ?? '';
                    });
                  },
                  wh: widget.item,
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
                  productID: productIDController.text,
                  onImageChanged: (url) {
                    // Cập nhật TextField khi upload thành công
                    setState(() {
                      image2Controller.text = url ?? '';
                    });
                  },
                  wh: widget.item,
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
                  onImageChanged: (url) {
                    // Cập nhật TextField khi upload thành công
                    setState(() {
                      image3Controller.text = url ?? '';
                    });
                  },
                  wh: widget.item,
                );
              },
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
                functionCreate: () async {
                  // 👇 Tắt dropdown tự động, mở dialog thêm mới
                  final result = await showAddDialogDynamic(context, model: 2);
                  if (result != null) {
                    await _loadAllData(); // reload danh sách
                    setState(() {}); // cập nhật lại UI
                  }
                },
                rightIcon: AppState.instance.get("isPinEmployee") == true
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                onRightIconTap: () async {
                  final newPinState =
                      !(AppState.instance.get("isPinEmployee") ?? false);
                  await toggleEmployeePin(newPinState);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),
            //ĐỐI TÁC
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomDropdownField(
                label: "Đối tác:",
                selectedValue: selectedSupplier,
                items: suppliers,
                getLabel: (i) => i.Name.toString(),
                onChanged: (v) => setState(() => selectedSupplier = v),
                textCreate: "Thêm mới đối tác",
                isSearch: true,
                isCreate: StatusCreate,
                functionCreate: () async {
                  // 👇 Tắt dropdown tự động, mở dialog thêm mới
                  final result = await showAddDialogDynamic(context, model: 5);
                  if (result != null) {
                    await _loadAllData(); // reload danh sách
                    setState(() {}); // cập nhật lại UI
                  }
                },
                rightIcon: AppState.instance.get("isPinPartner") == true
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                onRightIconTap: () async {
                  final newPinState =
                      !(AppState.instance.get("isPinPartner") ?? false);
                  await togglePartnerPin(newPinState);
                  setState(() {});
                },
              ),
            ),
            //THỜI GIAN
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomDatePicker(
                key: ValueKey(initialDate),
                label: "Chọn ngày nhập/xuất:",
                initialDate: widget.isCreateHistory
                    ? initialDate
                    : parseDateManual(timeController.text),
                onChanged: (value) {
                  setState(() {
                    selectedTimePicker = Formatdatehelper.formatYMD(value);
                    initialDate = value;
                  });
                },
                rightIcon: AppState.instance.get("isPinDate") == true
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                onRightIconTap: () async {
                  await togglePinDate(initialDate);
                  setState(() {});
                },
                readOnly: widget.isReadOnlyHistory,
              ),
            ),
            //GHI CHÚ CỦA NHẬP XUẤT
            Visibility(
              visible: widget.isCreateHistory,
              child: CustomTextFieldIcon(
                label: "Ghi chú của nhập xuất:",
                controller: remarkOfHistoryController,
                hintText: "Ghi chú của nhập xuất",
                readOnly: widget.isReadOnlyHistory,
                suffixIcon: AppState.instance.get("isPinRemark") == true
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                onSuffixIconPressed: () async {
                  final newPinState =
                      (AppState.instance.get("PinRemark") ?? "");
                  await toggleRemarkOfHistory(newPinState);
                  setState(() {});
                },
              ),
            ),

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
                        widget.isUpDate ||
                            widget.isCreate ||
                            widget.isCreateHistory
                        ? _upDateWareHouse
                        : null,
                    icon: const Icon(Icons.save),
                    label: const Text("Lưu thay đổi"),
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

  Future<void> toggleEmployeePin(bool isPinned) async {
    if (isPinned) {
      if (selectedEmployee == null) return;

      // Lưu employee và trạng thái pin
      AppState.instance.set(
        "employee",
        selectedEmployee!.EmployeeID.toString(),
      );
      AppState.instance.set("isPinEmployee", true);
    } else {
      // Bỏ ghim: xóa dữ liệu
      AppState.instance.set("employee", null);
      AppState.instance.set("isPinEmployee", false);

      if (!mounted) return; // đảm bảo widget còn tồn tại

      setState(() {
        selectedEmployee = null;
        employeeHistoryController.clear();
      });
    }
  }

  Future<void> togglePartnerPin(bool isPinned) async {
    if (isPinned) {
      if (selectedSupplier == null) return;

      // Lưu employee và trạng thái pin
      AppState.instance.set("partner", selectedSupplier!.SupplierID.toString());
      AppState.instance.set("isPinPartner", true);
    } else {
      // Bỏ ghim: xóa dữ liệu
      AppState.instance.set("partner", null);
      AppState.instance.set("isPinPartner", false);

      if (!mounted) return; // đảm bảo widget còn tồn tại
      setState(() {
        selectedSupplier = null;
        partnerController.clear();
      });
    }
  }

  Future<void> togglePinDate(DateTime? date) async {
    if (!mounted) return;
    bool isPinned = AppState.instance.get("isPinDate") == true;
    AppState.instance.set("isPinDate", !isPinned);

    if (!isPinned && date != null) {
      AppState.instance.set("pinnedDate", Formatdatehelper.formatYMD(date));
      print("đã pin date");
    } else {
      AppState.instance.set("pinnedDate", null);
    }
  }

  Future<void> toggleRemarkOfHistory(String? remark) async {
    if (!mounted) return;

    // Lấy trạng thái hiện tại
    bool isPinned = AppState.instance.get("isPinRemark") == true;

    // Đảo trạng thái pin
    AppState.instance.set("isPinRemark", !isPinned);

    if (!isPinned && remark != null) {
      // Ghim: lưu ngày hiện tại
      AppState.instance.set("PinRemark", remarkOfHistoryController.text);
      print("đã pin remark " + AppState.instance.get("PinRemark"));
    } else {
      // Bỏ ghim: xóa dữ liệu
      AppState.instance.set("PinRemark", null);
    }
  }
}
