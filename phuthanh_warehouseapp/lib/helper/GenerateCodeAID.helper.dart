import 'dart:math';

class CodeHelper {
  //WH là kho, SP là sản phẩm, LS là lịch sử

  String generateTransferGroupID(String conditionFrom, String conditionTo) {
    final now = DateTime.now();

    // ddMMyy
    final datePart =
        '${now.day.toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${(now.year % 100).toString().padLeft(2, '0')}';

    // ssmmHH
    final timePart =
        '${now.second.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}';

    // random 6 số
    final random = Random();
    final randomPart = List.generate(6, (_) => random.nextInt(10)).join();

    // return giống Java
    return '$conditionFrom$datePart$timePart$randomPart$conditionTo';
  }

  String generateCodeBH() {
    final now = DateTime.now();

    // Cách 1: Dùng padding thủ công (giống Java nhất)
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    String year = now.year.toString();
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    String second = now.second.toString().padLeft(2, '0');

    return "BH-$day$month$year$second$minute$hour";
  }
}
