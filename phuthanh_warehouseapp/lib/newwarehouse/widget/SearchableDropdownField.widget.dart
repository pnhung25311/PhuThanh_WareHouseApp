import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/SearchTextHelper.helper.dart';

/// Trường dạng dropdown nhưng cho tìm kiếm — thay cho `DropdownButtonFormField`
/// (không hỗ trợ tìm kiếm, danh sách dài như NCC/danh mục rất khó chọn).
/// Bấm vào mở bottom sheet có ô tìm kiếm + danh sách lọc theo [searchTextOf].
class SearchableDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) labelOf;
  final String Function(T item)? searchTextOf;
  final ValueChanged<T?> onChanged;
  final bool allowClear;
  final bool enabled;
  final String? errorText;

  /// Khác `null` để hiện nút ghim cạnh dropdown (ví dụ NCC/nhân viên hay chọn
  /// lặp lại khi quét mã nhiều lần) — `null` thì ẩn hẳn, không dùng tính năng
  /// ghim cho field đó.
  final bool? isPinned;
  final VoidCallback? onTogglePin;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    this.searchTextOf,
    required this.onChanged,
    this.allowClear = true,
    this.enabled = true,
    this.errorText,
    this.isPinned,
    this.onTogglePin,
  });

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<_PickResult<T>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SearchableDropdownSheet<T>(
        title: label,
        items: items,
        labelOf: labelOf,
        searchTextOf: searchTextOf ?? labelOf,
        allowClear: allowClear,
      ),
    );

    if (result != null) onChanged(result.value);
  }

  @override
  Widget build(BuildContext context) {
    final displayText = value != null ? labelOf(value as T) : null;

    final field = InkWell(
      onTap: enabled ? () => _openPicker(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          errorText: errorText,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText ?? '— Chạm để chọn —',
                style: TextStyle(
                  color: displayText == null
                      ? Colors.grey.shade500
                      : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade600),
          ],
        ),
      ),
    );

    if (isPinned == null) return field;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton(
            tooltip: isPinned!
                ? 'Bỏ ghim'
                : 'Ghim lựa chọn này (dùng lại cho lần sau)',
            onPressed: onTogglePin,
            icon: Icon(
              isPinned! ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: isPinned! ? const Color(0xFF0E6B6B) : Colors.grey.shade500,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bọc kết quả chọn để phân biệt "người dùng chọn xóa" (value=null) với
/// "người dùng đóng sheet không chọn gì" (result=null hoàn toàn, không đổi).
class _PickResult<T> {
  final T? value;
  const _PickResult(this.value);
}

class _SearchableDropdownSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T item) labelOf;
  final String Function(T item) searchTextOf;
  final bool allowClear;

  const _SearchableDropdownSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.searchTextOf,
    required this.allowClear,
  });

  @override
  State<_SearchableDropdownSheet<T>> createState() =>
      _SearchableDropdownSheetState<T>();
}

class _SearchableDropdownSheetState<T>
    extends State<_SearchableDropdownSheet<T>> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    final query = _searchController.text;
    return widget.items
        .where(
          (item) =>
              SearchTextHelper.matches([widget.searchTextOf(item)], query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final filtered = _filtered;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('Không tìm thấy kết quả phù hợp'),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount:
                              filtered.length + (widget.allowClear ? 1 : 0),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (widget.allowClear && index == 0) {
                              return ListTile(
                                title: const Text(
                                  '— Không chọn —',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onTap: () => Navigator.pop(
                                  context,
                                  const _PickResult(null),
                                ),
                              );
                            }
                            final item =
                                filtered[index - (widget.allowClear ? 1 : 0)];
                            return ListTile(
                              title: Text(
                                widget.labelOf(item),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () =>
                                  Navigator.pop(context, _PickResult(item)),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
