import 'package:flutter/material.dart';

class SmartDropdown<T> extends StatefulWidget {
  final List<T> items;
  final bool isMultiSelect;
  final List<T>? initialValues;
  final T? initialValue;
  final String? hint;
  final String? label;
  final bool isSearch;
  final int? maxSelection;
  final String Function(T)? labelBuilder;
  final Function(dynamic) onChanged;
  final bool enabled;
  final bool readOnly; // 🆕 Thêm chế độ chỉ đọc
  final VoidCallback? onClose;
  final VoidCallback? functionCreate;

  const SmartDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.isMultiSelect = false,
    this.initialValues,
    this.initialValue,
    this.hint,
    this.label,
    this.isSearch = false,
    this.maxSelection,
    this.labelBuilder,
    this.enabled = true,
    this.readOnly = false, // 🆕
    this.onClose,
    this.functionCreate,
  });

  @override
  State<SmartDropdown<T>> createState() => _SmartDropdownState<T>();
}

class _SmartDropdownState<T> extends State<SmartDropdown<T>> {
  late List<T> _selected;
  T? _selectedSingle;
  String _search = "";
  final ExpansionTileController _controller = ExpansionTileController();

  @override
  void initState() {
    super.initState();
    if (widget.isMultiSelect) {
      _selected = List.from(widget.initialValues ?? []);
    } else {
      _selectedSingle = widget.initialValue;
      _selected = [];
    }
  }

  String _getLabel(T item) {
    if (widget.labelBuilder != null) return widget.labelBuilder!(item);
    return item.toString();
  }

  void _onItemTap(T item) {
    if (!widget.enabled || widget.readOnly) return; // 🆕 Chặn thao tác
    setState(() {
      if (widget.isMultiSelect) {
        if (_selected.contains(item)) {
          _selected.remove(item);
        } else {
          if (widget.maxSelection != null &&
              _selected.length >= widget.maxSelection!) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Chỉ được chọn tối đa ${widget.maxSelection} mục",
                ),
              ),
            );
            return;
          }
          _selected.add(item);
        }
        widget.onChanged(List.from(_selected));
      } else {
        _selectedSingle = item;
        widget.onChanged(item);
      }
    });
  }

  List<T> get _filteredItems {
    if (_search.isEmpty) return widget.items;
    return widget.items
        .where(
          (e) => _getLabel(e).toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.enabled && !widget.readOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),

        Opacity(
          opacity: widget.enabled ? 1.0 : 0.6,
          child: AbsorbPointer(
            absorbing: !isInteractive, // 🆕 Không cho tương tác khi readOnly
            child: Card(
              color: widget.readOnly
                  ? Colors.grey.shade100
                  : Colors.white, // 🆕 Nền xám khi readonly
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ExpansionTile(
                controller: _controller,
                maintainState: true,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                // 🆕 Nếu readOnly thì không cho mở rộng
                initiallyExpanded: false,
                onExpansionChanged: (expanded) {
                  if (widget.readOnly && expanded) {
                    _controller.collapse();
                  }
                },
                title: widget.isMultiSelect
                    ? _selected.isEmpty
                          ? Text(
                              widget.hint ?? "Chọn mục",
                              style: const TextStyle(color: Colors.grey),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: -6,
                              children: _selected.map((item) {
                                return Chip(
                                  label: Text(_getLabel(item)),
                                  onDeleted: isInteractive
                                      ? () {
                                          setState(() {
                                            _selected.remove(item);
                                            widget.onChanged(
                                              List.from(_selected),
                                            );
                                          });
                                        }
                                      : null, // 🆕 Không xóa khi readonly
                                );
                              }).toList(),
                            )
                    : Text(
                        _selectedSingle != null
                            ? _getLabel(_selectedSingle as T)
                            : (widget.hint ?? "Chọn mục"),
                        style: TextStyle(
                          color: _selectedSingle == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),

                children: [
                  if (widget.isSearch)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: TextField(
                        enabled:
                            isInteractive, // 🆕 Không cho nhập khi readonly
                        decoration: const InputDecoration(
                          hintText: "Tìm kiếm...",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _search = val),
                      ),
                    ),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final label = _getLabel(item);
                      final selected = widget.isMultiSelect
                          ? _selected.contains(item)
                          : _selectedSingle == item;
                      return ListTile(
                        title: Text(label),
                        trailing: widget.isMultiSelect
                            ? Checkbox(
                                value: selected,
                                onChanged: isInteractive
                                    ? (_) => _onItemTap(item)
                                    : null,
                              )
                            : selected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: isInteractive ? () => _onItemTap(item) : null,
                      );
                    },
                  ),

                  const Divider(),

                  // 🔘 Nút “Thêm mới” + “Đóng”
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text("Thêm mới"),
                          onPressed: isInteractive
                              ? widget.functionCreate
                              : null,
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Đóng"),
                          onPressed: isInteractive
                              ? () {
                                  _controller.collapse();
                                  widget.onClose?.call();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
