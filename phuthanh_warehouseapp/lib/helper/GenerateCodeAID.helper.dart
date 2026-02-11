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
}
