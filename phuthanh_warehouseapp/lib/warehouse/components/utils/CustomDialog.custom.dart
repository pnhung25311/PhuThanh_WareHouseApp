import 'package:flutter/material.dart';

class SelectItem<T> {
  final T value;
  final String label;
  SelectItem({required this.value, required this.label});
}

/// Hiển thị dialog chọn 1 hoặc nhiều item, có callback khi nhấn OK
Future<List<T>?> showSelectDialog<T>({
  required BuildContext context,
  required String title,
  required List<SelectItem<T>> items,
  List<T>? initialSelectedValues,
  bool multiSelect = true,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  bool enableSelectAll = true,
  Function(List<T>)? onConfirm, // callback truyền vào
}) {
  return showDialog<List<T>>(
    context: context,
    builder: (context) {
      return _SelectDialog<T>(
        title: title,
        items: items,
        initialSelectedValues: initialSelectedValues ?? <T>[],
        multiSelect: multiSelect,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        enableSelectAll: enableSelectAll,
        onConfirm: onConfirm,
      );
    },
  );
}

class _SelectDialog<T> extends StatefulWidget {
  final String title;
  final List<SelectItem<T>> items;
  final List<T> initialSelectedValues;
  final bool multiSelect;
  final String confirmLabel;
  final String cancelLabel;
  final bool enableSelectAll;
  final Function(List<T>)? onConfirm; // callback

  const _SelectDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.initialSelectedValues,
    required this.multiSelect,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.enableSelectAll,
    this.onConfirm,
  }) : super(key: key);

  @override
  State<_SelectDialog<T>> createState() => _SelectDialogState<T>();
}

class _SelectDialogState<T> extends State<_SelectDialog<T>> {
  late List<T> _selected;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initialSelectedValues);
  }

  void _onItemTap(T value) {
    setState(() {
      if (widget.multiSelect) {
        if (_selected.contains(value)) {
          _selected.remove(value);
        } else {
          _selected.add(value);
        }
      } else {
        _selected = [value];
      }
    });
  }

  List<SelectItem<T>> get _visibleItems {
    if (_filter.trim().isEmpty) return widget.items;
    final q = _filter.toLowerCase();
    return widget.items
        .where((it) => it.label.toLowerCase().contains(q))
        .toList();
  }

  void _selectAllVisible(List<SelectItem<T>> visible) {
    setState(() {
      for (var it in visible) {
        if (!_selected.contains(it.value)) _selected.add(it.value);
      }
    });
  }

  void _clearAll() {
    setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    final isMulti = widget.multiSelect;

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm kiếm...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: 8),
            if (isMulti)
              Row(
                children: [
                  if (widget.enableSelectAll)
                    TextButton.icon(
                      onPressed: () => _selectAllVisible(visible),
                      icon: const Icon(Icons.select_all),
                      label: const Text('Chọn tất cả'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text('Bỏ chọn'),
                  ),
                ],
              ),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final it = visible[index];
                      final checked = _selected.contains(it.value);
                      if (isMulti) {
                        return CheckboxListTile(
                          value: checked,
                          title: Text(it.label),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (_) => _onItemTap(it.value),
                        );
                      } else {
                        return RadioListTile<T>(
                          value: it.value,
                          groupValue: _selected.isNotEmpty
                              ? _selected.first
                              : null,
                          title: Text(it.label),
                          onChanged: (_) => _onItemTap(it.value),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(widget.cancelLabel),
        ),
        ElevatedButton(
          onPressed: () {
            // Gọi callback nếu có
            if (widget.onConfirm != null) widget.onConfirm!(_selected);
            Navigator.of(context).pop(List<T>.from(_selected));
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
