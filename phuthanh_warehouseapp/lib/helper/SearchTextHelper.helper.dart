/// Chuẩn hóa chuỗi để tìm kiếm "mềm": không phân biệt hoa/thường, dấu tiếng
/// Việt, và bỏ mọi ký tự đặc biệt/khoảng trắng — nên `256876` khớp `256-876`,
/// `ca xoa987` / `ca xoa 987` khớp `ca xoa-987`.
class SearchTextHelper {
  SearchTextHelper._();

  static const String _from =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  static const String _to =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  static final RegExp _nonAlphanumeric = RegExp(
    r'[^\p{L}\p{N}]',
    unicode: true,
  );

  static String normalize(String? input) {
    if (input == null || input.isEmpty) return '';
    final buffer = StringBuffer();
    for (final rune in input.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final index = _from.indexOf(char);
      buffer.write(index >= 0 ? _to[index] : char);
    }
    return buffer.toString().replaceAll(_nonAlphanumeric, '');
  }

  /// `true` nếu [query] (đã chuẩn hóa) xuất hiện trong ghép của các [fields].
  /// [query] rỗng sau chuẩn hóa thì coi như khớp tất cả.
  static bool matches(Iterable<String?> fields, String query) {
    final q = normalize(query);
    if (q.isEmpty) return true;
    return normalize(
      fields.where((f) => f != null && f.isNotEmpty).join(' '),
    ).contains(q);
  }
}
