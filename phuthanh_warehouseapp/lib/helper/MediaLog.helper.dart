import 'package:intl/intl.dart';

/// Nhật ký ngắn (trong bộ nhớ, tối đa 100 dòng) ghi lại việc chọn ảnh/video,
/// thêm vào Local và upload, để xem lại được ngay trong app khi gặp lỗi trên
/// máy thật (TestFlight không có log như khi chạy từ máy tính).
class MediaLog {
  MediaLog._();

  static const int _maxLines = 100;
  static final List<String> _lines = [];
  static final DateFormat _time = DateFormat('HH:mm:ss');

  static void add(String message) {
    _lines.add('[${_time.format(DateTime.now())}] $message');
    if (_lines.length > _maxLines) _lines.removeAt(0);
  }

  static bool get isEmpty => _lines.isEmpty;

  static String dump() => _lines.join('\n');

  static void clear() => _lines.clear();
}
