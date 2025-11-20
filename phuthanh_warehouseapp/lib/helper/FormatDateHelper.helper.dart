import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class Formatdatehelper {
  // ========================
  // 1️⃣ Parse ISO 8601 hoặc yyyy-MM-dd -> DateTime local
  // ========================
  static DateTime parseDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateTime(dt.year, dt.month, dt.day);
    } catch (e) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
  }

  // ========================
  // 2️⃣ Parse dd/MM/yyyy -> DateTime
  // ========================
  static DateTime parseDateDMY(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = int.tryParse(parts[1]) ?? 1;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;
        return DateTime(year, month, day);
      }
      return DateTime.now();
    } catch (e) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
  }

  // ========================
  // 3️⃣ Format DateTime -> yyyy-MM-dd
  // ========================
  static String formatYMD(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')}";
  }

  // ========================
  // 4️⃣ Format DateTime -> dd/MM/yyyy
  // ========================
  static String formatDMY(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year.toString().padLeft(4, '0')}";
  }

  // ========================
  // 🕓 5️⃣ Format DateTime -> dd/MM/yyyy HH:mm
  // ========================
  static String formatDMYHM(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year.toString().padLeft(4, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  // ========================
  // 🕓 6️⃣ Format DateTime -> yyyy-MM-dd HH:mm:ss
  // ========================
  static String formatYMDHMS(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:"
        "${dt.second.toString().padLeft(2, '0')}";
  }

  // ========================
  // 🕓 7️⃣ Parse dd/MM/yyyy HH:mm -> DateTime
  // ========================
  static DateTime parseDateTimeDMYHM(String dateTimeStr) {
    try {
      final parts = dateTimeStr.split(' ');
      if (parts.length == 2) {
        final dateParts = parts[0].split('/');
        final timeParts = parts[1].split(':');

        final day = int.tryParse(dateParts[0]) ?? 1;
        final month = int.tryParse(dateParts[1]) ?? 1;
        final year = int.tryParse(dateParts[2]) ?? DateTime.now().year;
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;

        return DateTime(year, month, day, hour, minute);
      }
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  static DateTime toSqlDateTime(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  // ========================
  // 8️⃣ Load pinned date từ AppState
  // ========================
  static DateTime? loadPinnedDate() {
    final pinnedDateStr = AppState.instance.get("pinnedDate");
    if (pinnedDateStr != null && pinnedDateStr.isNotEmpty) {
      try {
        // Hỗ trợ cả yyyy-MM-dd và yyyy-MM-dd HH:mm:ss
        if (pinnedDateStr.contains(' ')) {
          return DateTime.parse(pinnedDateStr);
        } else {
          final parts = pinnedDateStr.split('-');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        }
      } catch (_) {}
    }
    return null;
  }

  // ========================
  // 9️⃣ Toggle pin date vào AppState (có cả giờ)
  // ========================
  static Future<void> togglePinDate(DateTime dateTime) async {
    bool isPinned = AppState.instance.get("isPinDate") == true;

    AppState.instance.set("isPinDate", !isPinned);

    if (!isPinned) {
      // Ghim ngày kèm giờ
      AppState.instance.set("pinnedDate", formatYMDHMS(dateTime));
    } else {
      // Bỏ ghim
      AppState.instance.set("pinnedDate", null);
    }
  }
}
