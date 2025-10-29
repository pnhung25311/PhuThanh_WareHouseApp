import 'package:flutter/material.dart';

class GenericPickerDialog {
  // Single select -> trả về T (hoặc null nếu hủy)
  static Future<T?> showSingle<T>(
    BuildContext context, {
    required List<T> items,
    String title = 'Chọn',
    String Function(T)? labelBuilder,
    T? initialValue,
  }) {
    final label = labelBuilder ?? (T v) => v.toString();
    int? selectedIndex;
    if (initialValue != null) {
      selectedIndex = items.indexWhere((e) => e == initialValue);
      if (selectedIndex == -1) selectedIndex = null;
    }

    return showDialog<T>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: items.isEmpty
                ? const Text('Không có mục nào')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (_, i) => RadioListTile<int>(
                      value: i,
                      groupValue: selectedIndex,
                      title: Text(label(items[i])),
                      onChanged: (v) => setState(() => selectedIndex = v),
                    ),
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: selectedIndex == null ? null : () => Navigator.of(ctx).pop(items[selectedIndex!]),
              child: const Text('Chọn'),
            ),
          ],
        ),
      ),
    );
  }

  // Multi select -> trả về List<T> (hoặc null nếu hủy)
  static Future<List<T>?> showMulti<T>(
    BuildContext context, {
    required List<T> items,
    String title = 'Chọn nhiều',
    String Function(T)? labelBuilder,
    List<T>? initialValues,
  }) {
    final label = labelBuilder ?? (T v) => v.toString();
    final selectedIndices = <int>{};
    if (initialValues != null && initialValues.isNotEmpty) {
      for (var v in initialValues) {
        final idx = items.indexWhere((e) => e == v);
        if (idx != -1) selectedIndices.add(idx);
      }
    }

    return showDialog<List<T>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: items.isEmpty
                ? const Text('Không có mục nào')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (_, i) => CheckboxListTile(
                      value: selectedIndices.contains(i),
                      title: Text(label(items[i])),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true)
                            selectedIndices.add(i);
                          else
                            selectedIndices.remove(i);
                        });
                      },
                    ),
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: selectedIndices.isEmpty
                  ? null
                  : () => Navigator.of(ctx).pop(selectedIndices.map((i) => items[i]).toList()),
              child: const Text('Chọn'),
            ),
          ],
        ),
      ),
    );
  }
}