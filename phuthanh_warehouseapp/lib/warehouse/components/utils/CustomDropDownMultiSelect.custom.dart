import 'package:flutter/material.dart';
import 'package:advanced_dropdown/advanced_dropdown.dart';

class CustomDropDownMultiSelect<T> extends StatefulWidget {
  /// Dữ liệu để hiển thị
  final List<T> items;

  /// Cách lấy label hiển thị từ item
  final String Function(T item) labelBuilder;

  /// Cách lấy value từ item
  final dynamic Function(T item) valueBuilder;

  /// Giá trị được chọn
  final List<dynamic> selectedValues;

  /// Callback khi giá trị thay đổi
  final ValueChanged<List<dynamic>> onChanged;

  /// Enable/disable dropdown
  final bool enabled;

  /// Placeholder khi chưa chọn
  final String hintText;

  const CustomDropDownMultiSelect({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.valueBuilder,
    required this.selectedValues,
    required this.onChanged,
    this.enabled = true,
    this.hintText = "Select",
  });

  @override
  State<CustomDropDownMultiSelect<T>> createState() =>
      _CustomDropDownMultiSelectState<T>();
}

class _CustomDropDownMultiSelectState<T>
    extends State<CustomDropDownMultiSelect<T>> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        child: AdvancedDropdown(
          items: widget.items
              .map((item) => {
                    'label': widget.labelBuilder(item),
                    'value': widget.valueBuilder(item),
                  })
              .toList(),
          isSearch: true,
          isMultiSelect: true,
          labelBuilder: (item) => item['label'],
          valueBuilder: (item) => item['value'],
          initialValues: widget.selectedValues,
          onChanged: (values) {
            widget.onChanged(values);
          },
          hintText: widget.hintText,
          chipColor: Colors.teal.shade100,
          chipTextStyle: const TextStyle(color: Colors.teal),
        ),
      ),
    );
  }
}
