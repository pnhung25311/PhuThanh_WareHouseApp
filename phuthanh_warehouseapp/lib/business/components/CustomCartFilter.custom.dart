import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';

class CartFilterResult {
  final String? keyword;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? fullName;
  final int? partnerId;
  final bool? status;

  CartFilterResult({
    this.keyword,
    this.fromDate,
    this.toDate,
    this.fullName,
    this.partnerId,
    this.status,
  });
}

class CartFilterBottomSheet extends StatefulWidget {
  final CartFilterResult? initial;
  final List<Supplier> suppliers;

  const CartFilterBottomSheet({
    super.key,
    this.initial,
    required this.suppliers,
  });

  @override
  State<CartFilterBottomSheet> createState() =>
      _CartFilterBottomSheetState();
}

class _CartFilterBottomSheetState
    extends State<CartFilterBottomSheet> {
  DateTime? fromDate;
  DateTime? toDate;
  bool? status;

  late TextEditingController keywordCtrl;
  late TextEditingController fullNameCtrl;

  List<Supplier> displaySuppliers = [];
  Supplier? selectedSupplier;

  @override
  void initState() {
    super.initState();

    fromDate = widget.initial?.fromDate;
    toDate = widget.initial?.toDate;
    status = widget.initial?.status;

    keywordCtrl =
        TextEditingController(text: widget.initial?.keyword);
    fullNameCtrl =
        TextEditingController(text: widget.initial?.fullName);

    /// 🔥 thêm "Tất cả"
    displaySuppliers = [
      Supplier(SupplierID: -1, Name: "Tất cả"),
      ...widget.suppliers,
    ];

    /// 🔥 set selected ban đầu
    if (widget.initial?.partnerId != null) {
      final found = displaySuppliers.where(
        (s) => s.SupplierID == widget.initial!.partnerId,
      );

      if (found.isNotEmpty) {
        selectedSupplier = found.first;
      } else {
        selectedSupplier = displaySuppliers.first;
      }
    } else {
      selectedSupplier = displaySuppliers.first; // Tất cả
    }
  }

  @override
  void dispose() {
    keywordCtrl.dispose();
    fullNameCtrl.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      left: 16,
      right: 16,
      top: 10,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          /// 🔥 Header
          const Center(
            child: Text(
              "Bộ lọc",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// 🔎 Keyword
          TextField(
            controller: keywordCtrl,
            decoration: InputDecoration(
              labelText: "Mã sản phẩm / Tên sản phẩm / Danh điểm",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),

          const SizedBox(height: 12),

          /// 📅 From
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            title: Text(
              fromDate == null
                  ? "Từ ngày"
                  : fromDate.toString().split(" ")[0],
              style: TextStyle(
                color: fromDate == null ? Colors.grey : Colors.black,
              ),
            ),
            trailing: const Icon(Icons.date_range),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (date != null) setState(() => fromDate = date);
            },
          ),

          const SizedBox(height: 10),

          /// 📅 To
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            title: Text(
              toDate == null
                  ? "Đến ngày"
                  : toDate.toString().split(" ")[0],
              style: TextStyle(
                color: toDate == null ? Colors.grey : Colors.black,
              ),
            ),
            trailing: const Icon(Icons.date_range),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (date != null) setState(() => toDate = date);
            },
          ),

          const SizedBox(height: 12),

          /// 👤 FullName
          TextField(
            controller: fullNameCtrl,
            decoration: InputDecoration(
              labelText: "Tên người đặt hàng",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),

          const SizedBox(height: 12),

          /// 🏢 Supplier
          CustomDropdownField<Supplier>(
            label: "Chọn NCC",
            selectedValue: selectedSupplier,
            items: displaySuppliers,
            getLabel: (s) => s.Name,
            onChanged: (v) => setState(() => selectedSupplier = v),
            isSearch: true,
          ),

          const SizedBox(height: 12),

          /// 📌 Status
          DropdownButtonFormField<bool?>(
            value: status,
            hint: const Text("Trạng thái"),
            items: const [
              DropdownMenuItem(value: null, child: Text("Tất cả")),
              DropdownMenuItem(value: true, child: Text("Hoàn thành")),
              DropdownMenuItem(value: false, child: Text("Chưa hoàn thành")),
            ],
            onChanged: (val) => setState(() => status = val),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context, CartFilterResult());
                  },
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      CartFilterResult(
                        keyword: keywordCtrl.text,
                        fromDate: fromDate,
                        toDate: toDate,
                        fullName: fullNameCtrl.text,
                        partnerId:
                            selectedSupplier?.SupplierID == -1
                                ? null
                                : selectedSupplier?.SupplierID,
                        status: status,
                      ),
                    );
                  },
                  child: const Text("Áp dụng"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

}