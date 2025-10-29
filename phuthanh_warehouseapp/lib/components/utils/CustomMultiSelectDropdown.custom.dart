import 'package:flutter/material.dart';
import 'package:advanced_dropdown/advanced_dropdown.dart';

class CustomMultiSelectDropdown extends StatefulWidget {
  final List<dynamic> items; // danh sách item
  final List<dynamic>? initialValues; // giá trị ban đầu
  final Function(List<dynamic>) onChanged; // callback khi thay đổi
  final String? hintText; // gợi ý
  final bool isSearch; // có cho tìm kiếm hay không
  final int? maxSelection; // giới hạn chọn
  // final bool _isMultiSelect;

  const CustomMultiSelectDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValues,
    this.hintText,
    this.isSearch = true,
    this.maxSelection,
    // this._isMultiSelect= false,
  });

  @override
  State<CustomMultiSelectDropdown> createState() =>
      _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  late List<dynamic> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.initialValues ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdvancedDropdown(
          isSearch: widget.isSearch,
          // isMultiSelect: _isMultiSelect,
          items: widget.items,
          initialValues: _selectedValues,
          maxSelection: widget.maxSelection,
          onChanged: (values) {
            setState(() => _selectedValues = values);
            widget.onChanged(values);
          },
          hintText: widget.hintText ?? "Select items",
          chipColor: Colors.blue.shade100,
          chipTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          chipRemoveIconColor: Colors.black54,
          itemTextStyle: const TextStyle(fontSize: 16),
          selectedTextStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          inputDecoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search, size: 20),
          ),
          icon: const Icon(Icons.arrow_drop_down),
        ),
        const SizedBox(height: 8),
        Text(
          "Selected: ${_selectedValues.join(", ")}",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
