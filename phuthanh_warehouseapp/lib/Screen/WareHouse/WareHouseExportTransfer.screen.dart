import 'package:flutter/material.dart';
// import 'package:phuthanh_warehouseapp/Screen/HomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDialogAppendix.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/info/Employee.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Location.model.dart';
import 'package:phuthanh_warehouseapp/model/info/VehicleTypeID.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Unit.model.dart';
import 'package:phuthanh_warehouseapp/service/HistoryService.service.dart';
import 'package:phuthanh_warehouseapp/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/service/WareHouseService.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class WareHouseExportTransfer extends StatefulWidget {
  // final WareHouse item;
  // final History itemHistory;
  // final bool isUpDate;
  // final bool isCreate;
  // final bool isCreateHistory;
  // final bool isReadOnlyHistory;
  // final bool readOnly;

  WareHouseExportTransfer({
    super.key,
    // required this.item,
    // History? itemHistory, // ✅ đổi thành nullable
    // this.isUpDate = false,
    // this.isCreate = false,
    // this.isCreateHistory = false,
    // this.isReadOnlyHistory = false,
    // this.readOnly = false,
  }) ;
  // : itemHistory = itemHistory ?? History.empty(); // ✅ gán mặc định ở đây

  @override
  State<WareHouseExportTransfer> createState() =>
      _WareHouseExportTransferState();
}

class _WareHouseExportTransferState extends State<WareHouseExportTransfer> {
  List<Country> countries = [];
  List<Manufacturer> manufacturers = [];
  List<Supplier> suppliers = [];
  List<Supplier> suppliersHistory = [];
  //1 là nhà cung cấp; 2 là nhập khẩu; 3 là khách hàng
  List<Supplier> supplierActuals = [];
  List<Unit> units = [];
  List<Employee> emps = [];
  List<VehicleType> vehicles = [];

  List<Location> locations = [];
  List<Location> selectedLocation = [];
  List<int> selectedLocationIds = [];

  Country? selectedCountry;
  Manufacturer? selectedManufacturer;
  Supplier? selectedSupplier;
  Supplier? selectedSupplierHistory;
  Supplier? selectedSupplierActual;
  Unit? selectedUnit;
  Employee? selectedEmployee;
  String? selectedTimePicker;
  VehicleType? selectedVehicleType;

  List<VehicleType> selectVehicles = [];
  List<int> selectedVehicelIds = [];

  InfoService infoService = InfoService();
  HistoryService historyService = HistoryService();
  Warehouseservice warehouseservice = Warehouseservice();
  NavigationHelper navigationHelper = NavigationHelper();

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
  final TextEditingController vehicleDetailController = TextEditingController();
  final TextEditingController image1Controller = TextEditingController();
  final TextEditingController image2Controller = TextEditingController();
  final TextEditingController image3Controller = TextEditingController();

  final TextEditingController qtyHistoryController = TextEditingController();
  final TextEditingController idEmployeeController = TextEditingController();
  final TextEditingController partnerController = TextEditingController();
  final TextEditingController remarkOfHistoryController =
      TextEditingController();
  final TextEditingController remarkOfWarehouseController =
      TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController supplierHistoryController =
      TextEditingController();
  final TextEditingController employeeHistoryController =
      TextEditingController();

  bool loading = true;
  bool isSaving = false; // ⚡ trạng thái loading khi lưu
  bool pinned = false;
  Key dropdownKey = UniqueKey();
  Key vehicleDropdownKey = UniqueKey();
  Key locationDropdownKey = UniqueKey();
  Formatdatehelper formatdatehelper = Formatdatehelper();
  MySharedPreferences mySharedPreferences = MySharedPreferences();

  DateTime initialDate = DateTime.now(); // ⚡ biến state

  // bool StatusCreate = AppState.instance.get("CreateAppendix");
  bool StatusCreate = true;
  @override
  void initState() {
    super.initState();
    // remarkController.text = widget.item.remarkOfDataWarehouse.toString();
    // productIDController.text = widget.item.productID.toString();
    // qtyController.text = widget.item.qty.toString();
    // qtyExpectedController.text = widget.item.qtyExpected?.toString() ?? "";
    // keetonController.text = widget.item.idKeeton ?? "";
    // industrialController.text = widget.item.idIndustrial.toString();
    // partNoController.text = widget.item.idPartNo ?? "";
    // replacedPartNoController.text = widget.item.idReplacedPartNo ?? "";
    // nameProductController.text = widget.item.nameProduct.toString();
    // idBillController.text = widget.item.idBill ?? "";
    // parameterController.text = widget.item.parameter.toString();
    // vehicleDetailController.text = widget.item.vehicleDetail.toString();

    // image1Controller.text = widget.item.img1.toString();
    // image2Controller.text = widget.item.img2.toString();
    // image3Controller.text = widget.item.img3.toString();
    _init();
  }

  // thêm helper init để await các load
  Future<void> _init() async {
    await _loadAllData();
  }

  Future<String?> getFullname() async {
    Map<String, dynamic>? account = await mySharedPreferences.getDataObject(
      "account",
    );
    // Kiểm tra null và lấy fullname
    String? fullname = account?["UserName"];
    return fullname;
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
        loading = false;
      });
    } catch (e) {
      print("❌ Lỗi load dữ liệu: $e");
      setState(() => loading = false);
    }
  }

  // void _upDateWareHouse() async {
  //   setState(() => isSaving = true);
  //   try {
  //     // String locaResult = selectedLocationIds.join(",");
  //     // String? fullName = await getFullname();

  //     // String convertTime =
  //     //     selectedTimePicker ?? formatdatehelper.formatYMDHMS(DateTime.now());
  //     // final DrawerItem item = AppState.instance.get("itemDrawer");

  //     // if (widget.isCreate) {
  //     //   final response = await warehouseservice.addWarehouseRow(
  //     //     item.wareHouseDataBase.toString(),
  //     //     jsonEncode({
  //     //       // "dataWareHouseAID": widget.item.dataWareHouseAID.toString().trim(),
  //     //       "productAID": widget.item.productAID,
  //     //       "LocationID": locaResult.trim(),
  //     //       "Qty_Expected":
  //     //           double.tryParse(qtyExpectedController.text.trim()) ?? 0,
  //     //       "ID_Bill": idBillController.text.trim(),
  //     //       "Remark": remarkOfWarehouseController.text.trim(),
  //     //       "LastTime": formatdatehelper.formatYMDHMS(DateTime.now()),
  //     //       "LastUser": await fullName.toString().trim(),
  //     //     }),
  //     //   );

  //     //   if (response["isSuccess"]) {
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //       const SnackBar(content: Text('Thêm sản phẩm thành công')),
  //     //     );
  //     //     // NavigationHelper.pushAndRemoveUntil(context, const HomeScreen());
  //     //   }
  //     // }

  //     // if (widget.isUpDate) {
  //     //   final response = await warehouseservice.upDateWareHouse(
  //     //     item.wareHouseDataBase.toString(),
  //     //     widget.item.dataWareHouseAID.toString(),
  //     //     jsonEncode({
  //     //       "productAID": widget.item.productAID,
  //     //       "LocationID": locaResult.trim(),
  //     //       "Qty_Expected":
  //     //           double.tryParse(qtyExpectedController.text.trim()) ?? 0,
  //     //       "ID_Bill": idBillController.text.trim(),
  //     //       "LastTime": formatdatehelper.formatYMDHMS(DateTime.now()),
  //     //       "LastUser": await fullName.toString().trim(),
  //     //     }),
  //     //   );

  //     //   if (response["isSuccess"]) {
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //       const SnackBar(content: Text('Cập nhật sản phẩm thành công')),
  //     //     );
  //     //     navigationHelper.pushAndRemoveUntil(context, const HomeScreen());
  //     //   } else {
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //       const SnackBar(content: Text('Cập nhật sản phẩm thất bại')),
  //     //     );
  //     //   }
  //     // }

  //     // if (widget.isCreateHistory == true &&
  //     //     qtyHistoryController.text.isNotEmpty &&
  //     //     qtyHistoryController.text != "0") {
  //     //   final whAID = await infoService.reTurnAIDWhToAddHistory(
  //     //     item.wareHouseDataBase.toString(),
  //     //     "ProductAID",
  //     //     widget.item.productAID.toString(),
  //     //   );

  //     //   final historyCreate = History(
  //     //     // historyAID: await CodeHelper.generateCodeAID("LS"),
  //     //     dataWareHouseAID: whAID,
  //     //     qty: double.tryParse(qtyHistoryController.text.trim()) ?? 0,
  //     //     employeeId: selectedEmployee?.EmployeeID ?? 0,
  //     //     partner: selectedSupplierHistory?.SupplierID ?? 0,
  //     //     remark: remarkOfHistoryController.text.trim(),
  //     //     time: formatdatehelper.formatDateTimeString(convertTime),
  //     //     lastUser: await fullName.toString().trim(),
  //     //     lastTime: formatdatehelper.formatYMDHMS(DateTime.now()),
  //     //   );

  //     //   final response = await historyService.AddHistory(
  //     //     item.wareHouseDataBaseHistory.toString(),
  //     //     item.wareHouseDataBase.toString(),
  //     //     jsonEncode(historyCreate.toJson()),
  //     //   );
  //     //   final double QtyWh = await infoService.reTurnQtyWhToAddHistory(
  //     //     item.wareHouseDataBaseHistory.toString(),
  //     //     whAID,
  //     //   );
  //     //   await warehouseservice.upDateWareHouse(
  //     //     item.wareHouseDataBase.toString(),
  //     //     whAID.toString(),
  //     //     jsonEncode({
  //     //       "Qty": QtyWh,
  //     //       "LastTime": formatdatehelper.formatYMDHMS(DateTime.now()),
  //     //     }),
  //     //   );
  //     //   if (response["isSuccess"]) {
  //     //     if (!mounted) return;
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //       const SnackBar(content: Text('✅ Cập nhật thành công')),
  //     //     );

  //     //     // quay lại và báo màn trước refresh
  //     //   } else {
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //       SnackBar(
  //     //         content: Text('❌ Lỗi cập nhật: ${response["statusCode"]}'),
  //     //       ),
  //     //     );
  //     //   }
  //     // }
  //     navigationHelper.pushAndRemoveUntil(context, const HomeScreen());
  //   } catch (e) {
  //     print(e);
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('⚠️ Lỗi kết nối: $e')));
  //   } finally {
  //     if (mounted) {
  //       setState(() => isSaving = false);
  //     }
  //   }
  // }

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
        title: Text(""
          // widget.item.nameProduct?.isEmpty ?? true
          //     ? "Thêm sản phẩm mới"
          //     : widget.item.nameProduct.toString(),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdownField(
              label: "Đối tác:",
              selectedValue: selectedSupplierHistory,
              items: suppliersHistory,
              getLabel: (i) => i.Name.toString(),
              onChanged: (v) => setState(() => selectedSupplierHistory = v),
              textCreate: "Thêm mới đối tác",
              isSearch: true,
              isCreate: StatusCreate,
              // readOnly: widget.isReadOnlyHistory,
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
                    onPressed:(){}
                        // (widget.isUpDate ||
                        //         widget.isCreate ||
                        //         widget.isCreateHistory) &&
                        //     !isSaving
                        // ? _upDateWareHouse
                        // : null
                        ,
                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            // child: CircularProgressIndicator(
                            //   strokeWidth: 2,
                            //   valueColor: AlwaysStoppedAnimation<Color>(
                            //     Colors.white,
                            //   ),
                            // ),
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
      if (selectedSupplierHistory == null) return;

      // Lưu employee và trạng thái pin
      AppState.instance.set(
        "partner",
        selectedSupplierHistory!.SupplierID.toString(),
      );
      AppState.instance.set("isPinPartner", true);
    } else {
      // Bỏ ghim: xóa dữ liệu
      AppState.instance.set("partner", null);
      AppState.instance.set("isPinPartner", false);

      if (!mounted) return; // đảm bảo widget còn tồn tại
      setState(() {
        selectedSupplierHistory = null;
        partnerController.clear();
      });
    }
  }

  Future<void> togglePinDate(DateTime? date) async {
    if (!mounted) return;
    bool isPinned = AppState.instance.get("isPinDate") == true;
    AppState.instance.set("isPinDate", !isPinned);

    if (!isPinned && date != null) {
      AppState.instance.set("pinnedDate", formatdatehelper.formatYMD(date));
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
    } else {
      // Bỏ ghim: xóa dữ liệu
      AppState.instance.set("PinRemark", null);
    }
  }

  Future<void> toggleLocationPin() async {
    if (!mounted) return;

    bool isPinned = AppState.instance.get("isPinLocation") == true;

    if (!isPinned) {
      // 📌 PIN
      if (selectedLocationIds.isEmpty) return;

      AppState.instance.set("pinnedLocationIds", selectedLocationIds.join(","));
      AppState.instance.set("isPinLocation", true);
    } else {
      // 📍 UNPIN
      AppState.instance.set("pinnedLocationIds", null);
      AppState.instance.set("isPinLocation", false);
    }

    setState(() {
      locationDropdownKey = UniqueKey();
    });
  }
}
