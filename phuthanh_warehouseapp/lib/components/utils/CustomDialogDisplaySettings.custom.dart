import 'package:flutter/material.dart';
// import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class DisplaySettingsDialog extends StatefulWidget {
  final String condition;
  const DisplaySettingsDialog({Key? key, required this.condition})
    : super(key: key);

  @override
  State<DisplaySettingsDialog> createState() => _DisplaySettingsDialogState();
}

class _DisplaySettingsDialogState extends State<DisplaySettingsDialog> {
  bool showID_Keeton = true;
  bool showIndustrial = true;
  bool showID_PartNo = true;
  bool showID_ReplacedPartNo = true;
  bool showNameProduct = true;
  bool showParameter = true;
  bool showRemark = true;
  bool showVehicleDetails = true;

  bool showVehicleTypeName = true;
  bool showUnitName = true;
  bool showCountryName = true;
  bool showManufacturerName = true;
  bool showSupplierName = true;
  bool showSupplierActualName = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await MySharedPreferences.getDataObject(widget.condition);
    if (settings != null) {
      setState(() {
        showID_Keeton = settings["showID_Keeton"] ?? true;
        showIndustrial = settings["showIndustrial"] ?? true;
        showID_PartNo = settings["showID_PartNo"] ?? true;
        showID_ReplacedPartNo = settings["showID_ReplacedPartNo"] ?? true;
        showNameProduct = settings["showNameProduct"] ?? true;
        showParameter = settings["showParameter"] ?? true;
        showVehicleDetails = settings["showVehicleDetails"] ?? true;
        showRemark = settings["showRemark"] ?? true;
        showUnitName = settings["showUnitName"] ?? true;
        showVehicleTypeName = settings["showVehicleTypeName"] ?? true;
        showCountryName = settings["showCountryName"] ?? true;
        showManufacturerName = settings["showManufacturerName"] ?? true;
        showSupplierName = settings["showSupplierName"] ?? true;
        showSupplierActualName = settings["showSupplierActualName"] ?? true;
      });
    }
  }

  Future<void> _saveSettings() async {
    await MySharedPreferences.setDataObject(widget.condition, {
      "showID_Keeton": showID_Keeton,
      "showIndustrial": showIndustrial,
      "showID_PartNo": showID_PartNo,
      "showID_ReplacedPartNo": showID_ReplacedPartNo,
      "showNameProduct": showNameProduct,
      "showParameter": showParameter,
      "showVehicleDetails": showVehicleDetails,
      "showRemark": showRemark,
      "showUnitName": showUnitName,
      "showVehicleTypeName": showVehicleTypeName,
      "showCountryName": showCountryName,
      "showManufacturerName": showManufacturerName,
      "showSupplierName": showSupplierName,
      "showSupplierActualName": showSupplierActualName,
    });

    if (widget.condition == "showhideProduct") {
      AppState.instance.set("showID_KeetonP", showID_Keeton);
      AppState.instance.set("showIndustrialP", showIndustrial);
      AppState.instance.set("showID_PartNoP", showID_PartNo);
      AppState.instance.set("showID_ReplacedPartNoP", showID_ReplacedPartNo);
      AppState.instance.set("showParameterP", showParameter);
      AppState.instance.set("showVehicleDetailsP", showVehicleDetails);
      AppState.instance.set("showRemarkP", showRemark);
      AppState.instance.set("showUnitNameP", showUnitName);
      AppState.instance.set("showVehicleTypeNameP", showVehicleTypeName);
      AppState.instance.set("showCountryNameP", showCountryName);
      AppState.instance.set("showManufacturerNameP", showManufacturerName);
      AppState.instance.set("showSupplierNameP", showSupplierName);
      AppState.instance.set("showSupplierActualNameP", showSupplierActualName);
    } else {
      AppState.instance.set("showID_KeetonWH", showID_Keeton);
      AppState.instance.set("showIndustrialWH", showIndustrial);
      AppState.instance.set("showID_PartNoWH", showID_PartNo);
      AppState.instance.set("showID_ReplacedPartNoWH", showID_ReplacedPartNo);
      AppState.instance.set("showParameterWH", showParameter);
      AppState.instance.set("showVehicleDetailsWH", showVehicleDetails);
      AppState.instance.set("showRemarkWH", showRemark);
      AppState.instance.set("showUnitNameWH", showUnitName);
      AppState.instance.set("showVehicleTypeNameWH", showVehicleTypeName);
      AppState.instance.set("showCountryNameWH", showCountryName);
      AppState.instance.set("showManufacturerNameWH", showManufacturerName);
      AppState.instance.set("showSupplierNameWH", showSupplierName);
      AppState.instance.set("showSupplierActualNameWH", showSupplierActualName);
    }
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Lưu cài đặt hiển thị thành công")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Material(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    "⚙️ Cài đặt hiển thị",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        CheckboxListTile(
                          title: const Text("Mã keeton"),
                          value: showID_Keeton,
                          onChanged: (val) =>
                              setState(() => showID_Keeton = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Mã công nghiệp"),
                          value: showIndustrial,
                          onChanged: (val) =>
                              setState(() => showIndustrial = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Danh điểm"),
                          value: showID_PartNo,
                          onChanged: (val) =>
                              setState(() => showID_PartNo = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Danh điểm tương đương"),
                          value: showID_ReplacedPartNo,
                          onChanged: (val) => setState(
                            () => showID_ReplacedPartNo = val ?? true,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text("Thông số"),
                          value: showParameter,
                          onChanged: (val) =>
                              setState(() => showParameter = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Dòng xe"),
                          value: showVehicleDetails,
                          onChanged: (val) =>
                              setState(() => showVehicleDetails = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Ghi chú"),
                          value: showRemark,
                          onChanged: (val) =>
                              setState(() => showRemark = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Nhà cung cấp thực tế"),
                          value: showSupplierActualName,
                          onChanged: (val) => setState(
                            () => showSupplierActualName = val ?? true,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text("Nhà cung cấp giấy tờ"),
                          value: showSupplierName,
                          onChanged: (val) =>
                              setState(() => showSupplierName = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("ĐVT"),
                          value: showUnitName,
                          onChanged: (val) =>
                              setState(() => showUnitName = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Nước sản xuất"),
                          value: showCountryName,
                          onChanged: (val) =>
                              setState(() => showCountryName = val ?? true),
                        ),
                        CheckboxListTile(
                          title: const Text("Nhà sản xuất"),
                          value: showManufacturerName,
                          onChanged: (val) => setState(
                            () => showManufacturerName = val ?? true,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text("Loại xe"),
                          value: showVehicleTypeName,
                          onChanged: (val) =>
                              setState(() => showVehicleTypeName = val ?? true),
                        ),
                        // CheckboxListTile(
                        //   title: const Text("Loại xe"),
                        //   value: showVehicleTypeName,
                        //   onChanged: (val) =>
                        //       setState(() => showVehicleTypeName = val ?? true),
                        // ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Hủy"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saveSettings,
                          child: const Text("Lưu"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
