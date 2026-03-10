import 'package:flutter/services.dart';

/// 🧮 DotToMinusFormatter
/// Khi người dùng nhập dấu "." đầu tiên, formatter sẽ tự động chuyển thành dấu "-".
/// Sau đó, không cho nhập thêm dấu "-" khác và chỉ cho phép một dấu "." trong chuỗi.
class DotToMinusFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Nếu người dùng nhập '.' đầu tiên => thay bằng '-'
    if (oldValue.text.isEmpty && text == '.') {
      text = '-';
    }

    // Nếu chuỗi bắt đầu bằng '.' nhưng không phải lần đầu => cũng đổi
    if (text.startsWith('.') && oldValue.text.isEmpty) {
      text = '-';
    }

    // Không cho nhập thêm dấu '-'
    if (text.length > 1) {
      final first = text[0];
      final rest = text.substring(1).replaceAll('-', '');
      text = first + rest;
    }

    // Giữ lại duy nhất 1 dấu '.'
    final dotIndex = text.indexOf('.');
    if (dotIndex != -1) {
      final firstPart = text.substring(0, dotIndex + 1);
      final rest = text.substring(dotIndex + 1).replaceAll('.', '');
      text = firstPart + rest;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
