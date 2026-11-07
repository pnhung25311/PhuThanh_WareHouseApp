import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/FilterOptionRow.custom.dart';
import 'package:phuthanh_warehouseapp/helper/FilterLabels.helper.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/ListViewOptions.model.dart';

/// Thanh sắp xếp & lọc nhanh luôn hiện trên danh sách: 3 nút dạng viên thuốc
/// (Sắp xếp / Thời gian / Dung lượng); bấm nút mở bảng chọn nhỏ, chọn xong
/// áp dụng ngay. Nút nào đang lọc được tô xanh, hiện giá trị và có dấu X để
/// xóa riêng nhóm đó; nút "Xóa lọc" xóa toàn bộ.
class QuickFilterBar extends StatelessWidget {
  final ListViewOptions options;
  final ValueChanged<ListViewOptions> onChanged;

  /// Nút phụ cố định ở cuối thanh (ví dụ "Chọn nhiều").
  final Widget? trailing;

  const QuickFilterBar({
    super.key,
    required this.options,
    required this.onChanged,
    this.trailing,
  });

  Future<T?> _pick<T>(
    BuildContext context,
    String title,
    List<({String label, String? subtitle, bool selected, T value})> rows,
  ) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (final row in rows)
                FilterOptionRow(
                  label: row.label,
                  subtitle: row.subtitle,
                  selected: row.selected,
                  onTap: () => Navigator.pop(ctx, row.value),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSort(BuildContext context) async {
    final picked = await _pick<(SortField, bool)>(context, 'Sắp xếp theo', [
      for (final c in FilterLabels.sortChoices)
        (
          label: c.$3,
          subtitle: null,
          selected: options.sortField == c.$1 && options.ascending == c.$2,
          value: (c.$1, c.$2),
        ),
    ]);
    if (picked == null) return;
    onChanged(options.copyWith(sortField: picked.$1, ascending: picked.$2));
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await _pick<TimeFilter>(context, 'Lọc theo thời gian', [
      for (final f in TimeFilter.values)
        (
          label: f == TimeFilter.custom
              ? 'Chọn khoảng ngày...'
              : FilterLabels.timeLabel(options, f),
          subtitle: f == TimeFilter.custom && FilterLabels.hasRange(options)
              ? FilterLabels.timeLabel(options, f)
              : null,
          selected: f == TimeFilter.custom
              ? FilterLabels.hasRange(options)
              : options.timeFilter == f,
          value: f,
        ),
    ]);
    if (picked == null || !context.mounted) return;

    if (picked != TimeFilter.custom) {
      onChanged(options.copyWith(timeFilter: picked));
      return;
    }
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day + 1),
      initialDateRange: FilterLabels.hasRange(options)
          ? DateTimeRange(start: options.customStart!, end: options.customEnd!)
          : null,
    );
    if (range == null) return;
    onChanged(
      options.copyWith(
        timeFilter: TimeFilter.custom,
        customStart: range.start,
        customEnd: range.end,
      ),
    );
  }

  Future<void> _pickSize(BuildContext context) async {
    final picked = await _pick<SizeFilter>(context, 'Lọc theo dung lượng', [
      for (final f in SizeFilter.values)
        (
          label: FilterLabels.sizeLabel(f),
          subtitle: null,
          selected: options.sizeFilter == f,
          value: f,
        ),
    ]);
    if (picked == null) return;
    onChanged(options.copyWith(sizeFilter: picked));
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final color = active ? Colors.blue.shade800 : Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Center(
        child: Material(
          color: active
              ? Colors.blue.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          shape: StadiumBorder(
            side: BorderSide(
              color: active ? Colors.blue : Colors.grey.shade300,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 4, 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 4),
                  Text(label, style: TextStyle(fontSize: 12.5, color: color)),
                  if (active)
                    // Dấu X xóa riêng nhóm này (vùng bấm riêng, không mở bảng chọn).
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onClear,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 14, color: color),
                      ),
                    )
                  else
                    Icon(Icons.arrow_drop_down, size: 18, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortActive = options.sortField != SortField.time || options.ascending;
    return Container(
      color: Colors.white,
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 12, right: 4),
              children: [
                _pill(
                  icon: Icons.sort,
                  label: FilterLabels.sortLabel(options),
                  active: sortActive,
                  onTap: () => _pickSort(context),
                  onClear: () => onChanged(
                    options.copyWith(sortField: SortField.time, ascending: false),
                  ),
                ),
                _pill(
                  icon: Icons.schedule,
                  label: options.timeFilter == TimeFilter.all
                      ? 'Thời gian'
                      : FilterLabels.timeLabel(options),
                  active: options.timeFilter != TimeFilter.all,
                  onTap: () => _pickTime(context),
                  onClear: () =>
                      onChanged(options.copyWith(timeFilter: TimeFilter.all)),
                ),
                _pill(
                  icon: Icons.data_usage,
                  label: options.sizeFilter == SizeFilter.all
                      ? 'Dung lượng'
                      : FilterLabels.sizeLabel(options.sizeFilter),
                  active: options.sizeFilter != SizeFilter.all,
                  onTap: () => _pickSize(context),
                  onClear: () =>
                      onChanged(options.copyWith(sizeFilter: SizeFilter.all)),
                ),
              ],
            ),
          ),
          // Cố định bên phải (không nằm trong vùng cuộn) để luôn thấy nút xóa.
          if (options.isActive)
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => onChanged(const ListViewOptions()),
              icon: const Icon(Icons.filter_alt_off, size: 16),
              label: const Text('Xóa lọc'),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
