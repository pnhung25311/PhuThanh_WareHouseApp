enum SortField { time, name, size }

enum TimeFilter { all, today, last7Days, last30Days, custom }

enum SizeFilter { all, under1MB, from1To10MB, over10MB }

/// Tùy chọn sắp xếp + lọc (theo thời gian, dung lượng) cho danh sách
/// ảnh/video. Mặc định: mới nhất trước, không lọc.
class ListViewOptions {
  static const int _mb = 1024 * 1024;

  final SortField sortField;
  final bool ascending;
  final TimeFilter timeFilter;
  final DateTime? customStart;
  final DateTime? customEnd;
  final SizeFilter sizeFilter;

  const ListViewOptions({
    this.sortField = SortField.time,
    this.ascending = false,
    this.timeFilter = TimeFilter.all,
    this.customStart,
    this.customEnd,
    this.sizeFilter = SizeFilter.all,
  });

  ListViewOptions copyWith({
    SortField? sortField,
    bool? ascending,
    TimeFilter? timeFilter,
    DateTime? customStart,
    DateTime? customEnd,
    SizeFilter? sizeFilter,
  }) {
    return ListViewOptions(
      sortField: sortField ?? this.sortField,
      ascending: ascending ?? this.ascending,
      timeFilter: timeFilter ?? this.timeFilter,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      sizeFilter: sizeFilter ?? this.sizeFilter,
    );
  }

  /// true nếu khác mặc định (đang sắp xếp khác hoặc đang lọc).
  bool get isActive =>
      sortField != SortField.time ||
      ascending ||
      timeFilter != TimeFilter.all ||
      sizeFilter != SizeFilter.all;

  bool _matchesTime(DateTime time, DateTime now) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    switch (timeFilter) {
      case TimeFilter.all:
        return true;
      case TimeFilter.today:
        return !time.isBefore(startOfToday);
      case TimeFilter.last7Days:
        return !time.isBefore(startOfToday.subtract(const Duration(days: 6)));
      case TimeFilter.last30Days:
        return !time.isBefore(startOfToday.subtract(const Duration(days: 29)));
      case TimeFilter.custom:
        final start = customStart;
        final end = customEnd;
        if (start != null &&
            time.isBefore(DateTime(start.year, start.month, start.day))) {
          return false;
        }
        if (end != null &&
            !time.isBefore(DateTime(end.year, end.month, end.day + 1))) {
          return false;
        }
        return true;
    }
  }

  bool _matchesSize(int size) {
    switch (sizeFilter) {
      case SizeFilter.all:
        return true;
      case SizeFilter.under1MB:
        return size < _mb;
      case SizeFilter.from1To10MB:
        return size >= _mb && size <= 10 * _mb;
      case SizeFilter.over10MB:
        return size > 10 * _mb;
    }
  }

  /// Lọc rồi sắp xếp [items] theo các tùy chọn hiện tại.
  List<T> apply<T>(
    Iterable<T> items, {
    required String Function(T) nameOf,
    required DateTime Function(T) timeOf,
    required int Function(T) sizeOf,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final result = items
        .where(
          (e) => _matchesTime(timeOf(e), current) && _matchesSize(sizeOf(e)),
        )
        .toList();

    int compare(T a, T b) {
      switch (sortField) {
        case SortField.time:
          return timeOf(a).compareTo(timeOf(b));
        case SortField.name:
          return nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase());
        case SortField.size:
          return sizeOf(a).compareTo(sizeOf(b));
      }
    }

    result.sort((a, b) => ascending ? compare(a, b) : compare(b, a));
    return result;
  }
}
