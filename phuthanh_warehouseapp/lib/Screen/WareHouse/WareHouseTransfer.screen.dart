import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomDropdownField.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextField.custom.dart';

class WareHouseTransfer extends StatefulWidget {
  const WareHouseTransfer({super.key});

  @override
  State<WareHouseTransfer> createState() =>
      _WareHouseTransferScreenState();
}

class _WareHouseTransferScreenState
    extends State<WareHouseTransfer> {
  // ===== TEXT =====
  final qtyFromCtrl = TextEditingController();
  final qtyToCtrl = TextEditingController();
  final remarkFromCtrl = TextEditingController();
  final remarkToCtrl = TextEditingController();

  // ===== DROPDOWN =====
  String? employeeFrom;
  String? partnerFrom;
  String? warehouseFrom;

  // ===== DATA DEMO =====
  final employees = ['NV A', 'NV B', 'NV C'];
  final partners = ['CTY A', 'CTY B'];
  final warehouses = ['Kho 1', 'Kho 2'];

  @override
  void initState() {
    super.initState();

    /// TEXT bên phải ăn theo bên trái
    qtyFromCtrl.addListener(() {
      qtyToCtrl.text = qtyFromCtrl.text;
    });

    remarkFromCtrl.addListener(() {
      remarkToCtrl.text = remarkFromCtrl.text;
    });
  }

  @override
  void dispose() {
    qtyFromCtrl.dispose();
    qtyToCtrl.dispose();
    remarkFromCtrl.dispose();
    remarkToCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử nhập xuất')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ===== SL NHẬP XUẤT =====
            _twoCol(
              left: CustomTextField(
                label: 'SL Nhập xuất',
                controller: qtyFromCtrl,
                keyboardType: TextInputType.number,
              ),
              right: CustomTextField(
                label: 'SL Nhập xuất',
                controller: qtyToCtrl,
                readOnly: true,
                enabled: false,
              ),
            ),

            const SizedBox(height: 15),

            /// ===== KHO =====
            _twoCol(
              left: CustomDropdownField<String>(
                label: 'Kho',
                selectedValue: warehouseFrom,
                items: warehouses,
                getLabel: (e) => e,
                onChanged: (v) {
                  setState(() {
                    warehouseFrom = v;
                  });
                },
              ),
              right: CustomDropdownField<String>(
                label: 'Kho',
                selectedValue: warehouseFrom,
                items: warehouses,
                getLabel: (e) => e,
                onChanged: (_) {},
                readOnly: true,
                enabled: false,
              ),
            ),

            const SizedBox(height: 15),

            /// ===== NHÂN VIÊN =====
            _twoCol(
              left: CustomDropdownField<String>(
                label: 'Nhân viên',
                selectedValue: employeeFrom,
                items: employees,
                isSearch: true,
                getLabel: (e) => e,
                onChanged: (v) {
                  setState(() {
                    employeeFrom = v;
                  });
                },
              ),
              right: CustomDropdownField<String>(
                label: 'Nhân viên',
                selectedValue: employeeFrom,
                items: employees,
                getLabel: (e) => e,
                onChanged: (_) {},
                readOnly: true,
                enabled: false,
              ),
            ),

            const SizedBox(height: 15),

            /// ===== ĐỐI TÁC =====
            _twoCol(
              left: CustomDropdownField<String>(
                label: 'Đối tác',
                selectedValue: partnerFrom,
                items: partners,
                getLabel: (e) => e,
                onChanged: (v) {
                  setState(() {
                    partnerFrom = v;
                  });
                },
              ),
              right: CustomDropdownField<String>(
                label: 'Đối tác',
                selectedValue: partnerFrom,
                items: partners,
                getLabel: (e) => e,
                onChanged: (_) {},
                readOnly: true,
                enabled: false,
              ),
            ),

            const SizedBox(height: 15),

            /// ===== GHI CHÚ =====
            _twoCol(
              left: CustomTextField(
                label: 'Ghi chú',
                controller: remarkFromCtrl,
              ),
              right: CustomTextField(
                label: 'Ghi chú',
                controller: remarkToCtrl,
                readOnly: true,
                enabled: false,
              ),
            ),

            const SizedBox(height: 30),

            /// ===== BUTTON =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Lưu thông tin'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Thoát'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== LAYOUT =====
  Widget _twoCol({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 15),
        Expanded(child: right),
      ],
    );
  }

  void _onSave() {
    /// submit data
  }
}
