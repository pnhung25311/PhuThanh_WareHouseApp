import 'dart:math';

class CodeHelper {
  //WH là kho, SP là sản phẩm, LS là lịch sử
  static Future<String> generateCodeAID(String prefix) async {
    final now = DateTime.now();

    // Lấy ngày tháng năm ddMMyy
    final datePart =
        '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${(now.year % 100).toString().padLeft(2, '0')}';

    // Lấy giờ phút giây đảo (ssmmHH)
    final timePart =
        '${now.second.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}';

    // Random 6 số
    final random = Random();
    final randomPart = List.generate(6, (_) => random.nextInt(10)).join();

    String result = prefix.toUpperCase() + datePart + timePart + randomPart;
    return result;
  }
}
