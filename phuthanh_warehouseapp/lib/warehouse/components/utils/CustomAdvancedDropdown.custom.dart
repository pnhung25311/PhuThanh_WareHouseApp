import 'package:flutter/material.dart';
import 'package:advanced_dropdown/advanced_dropdown.dart';

class CustomAdvancedDropdown<T> extends StatefulWidget {
  final List<T> items;
  final bool isMultiSelect;
  final bool isSearch;
  final dynamic initialValue; // single select
  final List<dynamic>? initialValues; // multi select
  final String hintText;
  final ValueChanged<dynamic> onChanged; // single: value, multi: list
  final TextStyle? selectedTextStyle;
  final TextStyle? itemTextStyle;
  final BoxDecoration? decoration;
  final BoxDecoration? dropdownDecoration;
  final String? label;
  final bool enabled;

  final String Function(T item)? labelBuilder;
  final dynamic Function(T item)? valueBuilder;

  const CustomAdvancedDropdown({
    super.key,
    required this.items,
    this.isMultiSelect = false,
    this.isSearch = false,
    this.initialValue,
    this.initialValues,
    required this.hintText,
    required this.onChanged,
    this.selectedTextStyle,
    this.itemTextStyle,
    this.decoration,
    this.dropdownDecoration,
    this.label,
    this.enabled = true,
    this.labelBuilder,
    this.valueBuilder,
  });

  @override
  State<CustomAdvancedDropdown<T>> createState() =>
      _CustomAdvancedDropdownState<T>();
}

class _CustomAdvancedDropdownState<T> extends State<CustomAdvancedDropdown<T>> {
  dynamic _selectedValue;
  List<T> _selectedValues = [];

  @override
  void initState() {
    super.initState();

    if (widget.isMultiSelect) {
      if (widget.initialValues != null && widget.initialValues!.isNotEmpty) {
        final firstElem = widget.initialValues!.first;
        if (firstElem is T) {
          _selectedValues = widget.initialValues!.cast<T>();
        } else if (widget.valueBuilder != null) {
          _selectedValues = widget.items
              .where((item) =>
                  widget.initialValues!.contains(widget.valueBuilder!(item)))
              .toList();
        } else {
          _selectedValues = widget.items
              .where((item) => widget.initialValues!.contains(item))
              .toList();
        }
      } else {
        _selectedValues = [];
      }
    } else {
      if (widget.initialValue != null) {
        final v = widget.initialValue;
        if (v is T) {
          _selectedValue = v;
        } else if (widget.valueBuilder != null) {
          final matchedItems = widget.items
              .where((item) => widget.valueBuilder!(item) == v)
              .toList();
          _selectedValue = matchedItems.isNotEmpty ? matchedItems.first : null;
        } else {
          final matchedItems =
              widget.items.where((item) => item == v).toList();
          _selectedValue = matchedItems.isNotEmpty ? matchedItems.first : null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Bỏ SingleChildScrollView đi để không bị lướt
    // ✅ Dùng Align + Padding để canh giữa + tránh bị che bàn phím
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min, // chỉ chiếm đúng chiều cao cần thiết
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  widget.label!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            AbsorbPointer(
              absorbing: !widget.enabled,
              child: Opacity(
                opacity: widget.enabled ? 1.0 : 0.5,
                child: AdvancedDropdown(
                  items: widget.items.cast<dynamic>(),
                  isMultiSelect: widget.isMultiSelect,
                  isSearch: widget.isSearch,
                  initialValue: widget.isMultiSelect ? null : _selectedValue,
                  initialValues: widget.isMultiSelect
                      ? _selectedValues.cast<dynamic>()
                      : null,
                  labelBuilder: widget.labelBuilder != null
                      ? (item) => widget.labelBuilder!(item as T)
                      : null,
                  valueBuilder: widget.valueBuilder != null
                      ? (item) => widget.valueBuilder!(item as T)
                      : null,
                  onChanged: (value) {
                    setState(() {
                      if (widget.isMultiSelect) {
                        _selectedValues = List<T>.from(value as List);
                        widget.onChanged(_selectedValues);
                      } else {
                        _selectedValue = value;
                        widget.onChanged(_selectedValue);
                      }
                    });
                  },
                  hintText: widget.hintText,
                  selectedTextStyle: widget.selectedTextStyle,
                  itemTextStyle: widget.itemTextStyle,
                  decoration: widget.decoration,
                  dropdownDecoration: widget.dropdownDecoration,
                  chipColor: Colors.blue.shade100,
                  chipTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
