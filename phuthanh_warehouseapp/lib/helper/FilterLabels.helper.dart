import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/ListViewOptions.model.dart';

/// Nhãn hiển thị dùng chung cho các kiểu giao diện sắp xếp & lọc.
class FilterLabels {
  FilterLabels._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Các lựa chọn sắp xếp gộp sẵn (trường, tăng dần?, nhãn).
  static const List<(SortField, bool, String)> sortChoices = [
    (SortField.time, false, 'Mới nhất'),
    (SortField.time, true, 'Cũ nhất'),
    (SortField.name, true, 'Tên A → Z'),
    (SortField.name, false, 'Tên Z → A'),
    (SortField.size, false, 'Dung lượng lớn → nhỏ'),
    (SortField.size, true, 'Dung lượng nhỏ → lớn'),
  ];

  static String sortLabel(ListViewOptions o) => sortChoices
      .firstWhere(
        (c) => c.$1 == o.sortField && c.$2 == o.ascending,
        orElse: () => sortChoices.first,
      )
      .$3;

  static bool hasRange(ListViewOptions o) =>
      o.timeFilter == TimeFilter.custom &&
      o.customStart != null &&
      o.customEnd != null;

  static String rangeText(DateTime start, DateTime end) =>
      '${_dateFormat.format(start)} - ${_dateFormat.format(end)}';

  static String timeLabel(ListViewOptions o, [TimeFilter? filter]) {
    switch (filter ?? o.timeFilter) {
      case TimeFilter.all:
        return 'Tất cả';
      case TimeFilter.today:
        return 'Hôm nay';
      case TimeFilter.last7Days:
        return '7 ngày qua';
      case TimeFilter.last30Days:
        return '30 ngày qua';
      case TimeFilter.custom:
        return hasRange(o)
            ? rangeText(o.customStart!, o.customEnd!)
            : 'Chọn khoảng ngày...';
    }
  }

  static String sizeLabel(SizeFilter filter) {
    switch (filter) {
      case SizeFilter.all:
        return 'Tất cả';
      case SizeFilter.under1MB:
        return 'Dưới 1 MB';
      case SizeFilter.from1To10MB:
        return '1 - 10 MB';
      case SizeFilter.over10MB:
        return 'Trên 10 MB';
    }
  }
}
