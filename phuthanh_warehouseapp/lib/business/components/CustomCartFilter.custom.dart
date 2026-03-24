import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomDropdownField.custom.dart';

class CartFilterResult {
  final String? keyword;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? fullName;
  final int? partnerId;
  final int? manufacturerID;
  final int? countryID;

  final int? accID;
  final bool? status;

  CartFilterResult({
    this.keyword,
    this.fromDate,
    this.toDate,
    this.fullName,
    this.partnerId,
    this.manufacturerID,
    this.countryID,
    this.accID,
    this.status,
  });
}

class CartFilterBottomSheet extends StatefulWidget {
  final CartFilterResult? initial;
  final List<Supplier> suppliers;
  final List<Account> acc;
  final List<Manufacturer> manu;
  final List<Country> country;

  const CartFilterBottomSheet({
    super.key,
    this.initial,
    required this.suppliers,
    required this.acc,
    required this.manu,
    required this.country,
  });

  @override
  State<CartFilterBottomSheet> createState() => _CartFilterBottomSheetState();
}

class _CartFilterBottomSheetState extends State<CartFilterBottomSheet> {
  DateTime? fromDate;
  DateTime? toDate;
  bool? status;

  late TextEditingController keywordCtrl;
  late TextEditingController fullNameCtrl;

  List<Supplier> displaySuppliers = [];
  List<Account> displayAccounts = [];
  List<Manufacturer> displayManufacturers = [];
  List<Country> displayCountrys = [];
  Supplier? selectedSupplier;
  Account? selectedAccount;
  Manufacturer? selectedManufacturer;
  Country? selectedCountry;

  @override
  void initState() {
    super.initState();

    fromDate = widget.initial?.fromDate;
    toDate = widget.initial?.toDate;
    status = widget.initial?.status;

    keywordCtrl = TextEditingController(text: widget.initial?.keyword);
    fullNameCtrl = TextEditingController(text: widget.initial?.fullName);

    /// 🔥 thêm "Tất cả"
    displaySuppliers = [
      Supplier(SupplierID: -1, Name: "Tất cả"),
      ...widget.suppliers,
    ];
    displayAccounts = [
      Account(
        AccountID: -1,
        UserName: "",
        PassWord: "",
        FullName: "Tất cả",
        Role: "",
        Status: "",
        Avatar: ""
      ),
      ...widget.acc,
    ];

    displayManufacturers = [
      Manufacturer(ManufacturerID: -1, Name: "Tất cả"),
      ...widget.manu,
    ];

    displayCountrys = [
      Country(CountryID: -1, Name: "Tất cả"),
      ...widget.country,
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

    if (widget.initial?.accID != null) {
      final foundAcc = displayAccounts.where(
        (s) => s.AccountID == widget.initial!.accID,
      );

      if (foundAcc.isNotEmpty) {
        selectedAccount = foundAcc.first;
      } else {
        selectedAccount = displayAccounts.first;
      }
    } else {
      selectedAccount = displayAccounts.first; // Tất cả
    }

    if (widget.initial?.manufacturerID != null) {
      final foundManu = displayManufacturers.where(
        (s) => s.ManufacturerID == widget.initial!.manufacturerID,
      );

      if (foundManu.isNotEmpty) {
        selectedManufacturer = foundManu.first;
      } else {
        selectedManufacturer = displayManufacturers.first;
      }
    } else {
      selectedManufacturer = displayManufacturers.first; // Tất cả
    }

    if (widget.initial?.countryID != null) {
      final foundCountry = displayCountrys.where(
        (s) => s.CountryID == widget.initial!.countryID,
      );

      if (foundCountry.isNotEmpty) {
        selectedCountry = foundCountry.first;
      } else {
        selectedCountry = displayCountrys.first;
      }
    } else {
      selectedCountry = displayCountrys.first; // Tất cả
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

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
                toDate == null ? "Đến ngày" : toDate.toString().split(" ")[0],
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

            CustomDropdownField<Account>(
              label: "Chọn người tạo đơn hàng",
              selectedValue: selectedAccount,
              items: displayAccounts,
              getLabel: (s) => s.FullName,
              onChanged: (v) => setState(() => selectedAccount = v),
              isSearch: true,
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
            CustomDropdownField<Manufacturer>(
              label: "Chọn Hãng SX",
              selectedValue: selectedManufacturer,
              items: displayManufacturers,
              getLabel: (s) => s.Name,
              onChanged: (v) => setState(() => selectedManufacturer = v),
              isSearch: true,
            ),

            const SizedBox(height: 12),
            CustomDropdownField<Country>(
              label: "Chọn Nước SX",
              selectedValue: selectedCountry,
              items: displayCountrys,
              getLabel: (s) => s.Name,
              onChanged: (v) => setState(() => selectedCountry = v),
              isSearch: true,
            ),
            const SizedBox(height: 12),

            /// 📌 Status
            Text(
              "Trạng thái",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            DropdownButtonFormField<bool?>(
              value: status,
              hint: const Text("Trạng thái"),
              items: const [
                DropdownMenuItem(value: null, child: Text("Tất cả")),
                DropdownMenuItem(value: true, child: Text("HOÀN THÀNH")),
                DropdownMenuItem(value: false, child: Text("CHỜ XÁC NHẬN")),
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
                          partnerId: selectedSupplier?.SupplierID == -1
                              ? null
                              : selectedSupplier?.SupplierID,
                          accID: selectedAccount?.AccountID == -1
                              ? null
                              : selectedAccount?.AccountID,
                          manufacturerID: selectedManufacturer?.ManufacturerID == -1
                              ? null
                              : selectedManufacturer?.ManufacturerID,
                          countryID: selectedCountry?.CountryID == -1
                              ? null
                              : selectedCountry?.CountryID,
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
