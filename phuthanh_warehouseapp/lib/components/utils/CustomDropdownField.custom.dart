import 'package:flutter/material.dart';

typedef LabelBuilder<T> = String Function(T item);

class CustomDropdownField<T> extends StatefulWidget {
  final String? label;
  final T? selectedValue;
  final List<T> items;
  final LabelBuilder<T> getLabel;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final bool isSearch;
  final bool readOnly;
  final String? hintText;
  final bool isCreate;
  final String? textCreate;
  final Future<void> Function()? functionCreate;

  // 🆕 Icon bên phải
  final IconData? rightIcon;
  final VoidCallback? onRightIconTap;
  final Color? rightIconColor;
  final String? rightIconTooltip;

  const CustomDropdownField({
    super.key,
    this.label,
    required this.selectedValue,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    this.enabled = true,
    this.isSearch = false,
    this.isCreate = false,
    this.hintText,
    this.textCreate,
    this.functionCreate,
    this.rightIcon,
    this.onRightIconTap,
    this.rightIconColor,
    this.rightIconTooltip,
    this.readOnly = false,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = List<T>.from(widget.items);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant CustomDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = List<T>.from(widget.items);
      _searchController.text = '';
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredItems = List<T>.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((e) => widget.getLabel(e).toLowerCase().contains(q))
            .toList();
      }
    });
  }

  void closeDropdown(BuildContext ctx) {
    if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
  }

  Future<void> _openSelectDialog() async {
    if (!widget.enabled || widget.readOnly) return;

    _filteredItems = List<T>.from(widget.items);
    if (!widget.isSearch) _searchController.text = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateDialog) {
            return AlertDialog(
              title: Text(widget.label ?? 'Chọn'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isSearch) ...[
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (q) {
                          final ql = q.toLowerCase();
                          setStateDialog(() {
                            _filteredItems = widget.items
                                .where(
                                  (e) => widget
                                      .getLabel(e)
                                      .toLowerCase()
                                      .contains(ql),
                                )
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? const Center(child: Text('Không có dữ liệu'))
                          : Scrollbar(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  final label = widget.getLabel(item);
                                  print("==============================>>>");
                                  print(label.toString());
                                  final isSelected =
                                      widget.selectedValue != null &&
                                      widget.getLabel(widget.selectedValue as T,) == label;
                                  print(isSelected);
                                  return ListTile(
                                    title: Text(
                                      label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.blue,
                                          )
                                        : null,
                                    onTap: () {
                                      widget.onChanged(item);
                                      Navigator.of(ctx2).pop();
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (widget.isCreate && widget.functionCreate != null)
                  TextButton(
                    onPressed: () async {
                      closeDropdown(ctx2);
                      await widget.functionCreate!();
                    },
                    child: Text(widget.textCreate ?? "Thêm mới"),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.selectedValue == null
        ? (widget.hintText ?? 'Chưa chọn')
        : widget.getLabel(widget.selectedValue as T);
    return GestureDetector(
      onTap: widget.readOnly ? null : _openSelectDialog,
      child: AbsorbPointer(
        absorbing: widget.readOnly || !widget.enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.enabled ? Colors.black87 : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
            ],
            InputDecorator(
              decoration: InputDecoration(
                enabled: widget.enabled,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                fillColor: widget.readOnly
                    ? Colors.grey.shade100
                    : Colors.transparent,
                filled: widget.readOnly,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: TextStyle(
                        color: widget.readOnly
                            ? Colors.grey.shade700
                            : (widget.enabled
                                  ? Colors.black87
                                  : Colors.grey.shade600),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.readOnly) const Icon(Icons.arrow_drop_down),
                      if (widget.rightIcon != null)
                        IconButton(
                          icon: Icon(
                            widget.rightIcon,
                            color: widget.rightIconColor ?? Colors.blueGrey,
                          ),
                          tooltip: widget.rightIconTooltip,
                          onPressed: widget.readOnly
                              ? null
                              : widget.onRightIconTap,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
