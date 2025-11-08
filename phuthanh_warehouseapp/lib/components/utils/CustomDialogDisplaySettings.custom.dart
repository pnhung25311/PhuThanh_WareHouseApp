import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';

class DisplaySettingsDialog extends StatefulWidget {
  const DisplaySettingsDialog({Key? key}) : super(key: key);

  @override
  State<DisplaySettingsDialog> createState() => _DisplaySettingsDialogState();
}

class _DisplaySettingsDialogState extends State<DisplaySettingsDialog> {
  // bool showProductID = true;
  bool showID_Keeton = true;
  bool showIndustrial = true;
  bool showID_PartNo = true;
  bool showID_ReplacedPartNo = true;
  bool showNameProduct = true;
  bool showParameter = true;
  bool showRemark = true;
  bool showVehicleDetails = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await MySharedPreferences.getDataObject("showhideProduct");
    if (settings != null) {
      setState(() {
        // showProductID = settings["showProductID"] ?? true;
        showID_Keeton = settings["showID_Keeton"] ?? true;
        showIndustrial = settings["showIndustrial"] ?? true;
        showID_PartNo = settings["showID_PartNo"] ?? true;
        showID_ReplacedPartNo = settings["showID_ReplacedPartNo"] ?? true;
        showNameProduct = settings["showNameProduct"] ?? true;
        showParameter = settings["showParameter"] ?? true;
        showVehicleDetails = settings["showVehicleDetails"] ?? true;
        showRemark = settings["showRemark"] ?? true;
      });
    }
  }

  void _saveSettings() async{
    await MySharedPreferences.setDataObject("showhideProduct", {
      // "showProductID": showProductID,
      "showID_Keeton": showID_Keeton,
      "showIndustrial": showIndustrial,
      "showID_PartNo": showID_PartNo,
      "showID_ReplacedPartNo": showID_ReplacedPartNo,
      "showNameProduct": showNameProduct,
      "showParameter": showParameter,
      "showVehicleDetails": showVehicleDetails,
      "showRemark": showRemark,
    });
    NavigationHelper.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Lưu cài đặt hiển thị thành công")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cài đặt hiển thị"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CheckboxListTile(
            //   title: const Text("Mã sản phẩm"),
            //   value: showProductID,
            //   onChanged: (val) => setState(() => showProductID = val ?? true),
            // ),
            CheckboxListTile(
              title: const Text("Mã keeton"),
              value: showID_Keeton,
              onChanged: (val) => setState(() => showID_Keeton = val ?? true),
            ),
            CheckboxListTile(
              title: const Text("Mã công nghiệp"),
              value: showIndustrial,
              onChanged: (val) => setState(() => showIndustrial = val ?? true),
            ),
            CheckboxListTile(
              title: const Text("Danh điểm"),
              value: showID_PartNo,
              onChanged: (val) => setState(() => showID_PartNo = val ?? true),
            ),
            CheckboxListTile(
              title: const Text("Danh điểm tương đương"),
              value: showID_ReplacedPartNo,
              onChanged: (val) =>
                  setState(() => showID_ReplacedPartNo = val ?? true),
            ),
            // CheckboxListTile(
            //   title: const Text("Tên sản phẩm"),
            //   value: showNameProduct,
            //   onChanged: (val) => setState(() => showNameProduct = val ?? true),
            // ),
            CheckboxListTile(
              title: const Text("Thông số"),
              value: showParameter,
              onChanged: (val) => setState(() => showParameter = val ?? true),
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
              onChanged: (val) => setState(() => showRemark = val ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(onPressed: _saveSettings, child: const Text("Lưu")),
      ],
    );
  }
}
