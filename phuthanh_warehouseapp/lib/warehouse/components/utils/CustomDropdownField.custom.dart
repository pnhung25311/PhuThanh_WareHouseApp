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

  // RIGHT ICON
  final IconData? rightIcon;
  final VoidCallback? onRightIconTap;
  final Color? rightIconColor;
  final String? rightIconTooltip;
  final EdgeInsetsGeometry? rightIconPadding;
  final double? rightIconSize;

  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final String? errorText;
  final String? Function(T?)? validator;

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
    this.rightIconPadding,
    this.rightIconSize,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.errorText,
    this.validator,
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
      _searchController.clear();
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
      _filteredItems = q.isEmpty
          ? List<T>.from(widget.items)
          : widget.items
              .where((e) => widget.getLabel(e).toLowerCase().contains(q))
              .toList();
    });
  }

  Future<void> _openSelectDialog(FormFieldState<T> field) async {
    if (!widget.enabled || widget.readOnly) return;

    _filteredItems = List<T>.from(widget.items);
    if (!widget.isSearch) _searchController.clear();

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
                height: 400,
                child: Column(
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
                                .where((e) => widget
                                    .getLabel(e)
                                    .toLowerCase()
                                    .contains(ql))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? const Center(child: Text('Không có dữ liệu'))
                          : ListView.builder(
                              itemCount: _filteredItems.length,
                              itemBuilder: (_, index) {
                                final item = _filteredItems[index];
                                final label = widget.getLabel(item);

                                final isSelected =
                                    widget.selectedValue != null &&
                                        widget.selectedValue == item;

                                return ListTile(
                                  title: Text(label),
                                  trailing: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.blue)
                                      : null,
                                  onTap: () {
                                    field.didChange(item);
                                    widget.onChanged(item);
                                    Navigator.pop(ctx2);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (widget.isCreate && widget.functionCreate != null)
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx2);
                      await widget.functionCreate!();
                    },
                    child: Text(widget.textCreate ?? "Thêm mới"),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx2),
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

    return FormField<T>(
      validator: widget.validator,
      initialValue: widget.selectedValue,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(widget.label!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
            ],

            GestureDetector(
              onTap: (!widget.readOnly && widget.enabled)
                  ? () => _openSelectDialog(field)
                  : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: widget.enabled
                      ? (widget.backgroundColor ?? Colors.white)
                      : (widget.disabledBackgroundColor ??
                          Colors.grey.shade200),
                  errorText: field.errorText ?? widget.errorText,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(display)),

                    const Icon(Icons.arrow_drop_down, size: 28),

                    if (widget.rightIcon != null)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.onRightIconTap,
                        child: Tooltip(
                          message: widget.rightIconTooltip ?? "",
                          child: Padding(
                            padding: widget.rightIconPadding ??
                                const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                            child: Icon(
                              widget.rightIcon,
                              size: widget.rightIconSize ?? 24,
                              color: widget.rightIconColor ?? Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}