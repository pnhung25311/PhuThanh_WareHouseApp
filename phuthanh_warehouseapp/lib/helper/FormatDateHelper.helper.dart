import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class Formatdatehelper {
  // ========================
  // 1️⃣ Parse chuỗi ISO 8601 hoặc yyyy-MM-dd -> DateTime local
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
  // 2️⃣ Parse chuỗi dd/MM/yyyy -> DateTime
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
  // 3️⃣ Format DateTime -> String yyyy-MM-dd
  // ========================
  static String formatYMD(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-"
           "${dt.month.toString().padLeft(2, '0')}-"
           "${dt.day.toString().padLeft(2, '0')}";
  }

  // ========================
  // 4️⃣ Format DateTime -> String dd/MM/yyyy
  // ========================
  static String formatDMY(DateTime dt) {
    return "${dt.day.toString().padLeft(2,'0')}/"
           "${dt.month.toString().padLeft(2,'0')}/"
           "${dt.year.toString().padLeft(4,'0')}";
  }

  // ========================
  // 5️⃣ Load pinned date từ AppState
  // ========================
  static DateTime? loadPinnedDate() {
    final pinnedDateStr = AppState.instance.get("pinnedDate");
    if (pinnedDateStr != null && pinnedDateStr.isNotEmpty) {
      try {
        final parts = pinnedDateStr.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (_) {}
    }
    return null;
  }

  // ========================
  // 6️⃣ Toggle pin date vào AppState
  // ========================
  static Future<void> togglePinDate(DateTime date) async {
    bool isPinned = AppState.instance.get("isPinDate") == true;

    AppState.instance.set("isPinDate", !isPinned);

    if (!isPinned) {
      // ghim ngày
      AppState.instance.set("pinnedDate", formatYMD(date));
    } else {
      // bỏ ghim
      AppState.instance.set("pinnedDate", null);
    }
  }
}
