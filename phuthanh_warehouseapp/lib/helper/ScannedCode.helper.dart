/// Kết quả tách mã quét: `item` tìm được theo mã vật tư, `noLot` là mã lô
/// (null nếu mã quét chỉ có mã vật tư).
class ScannedCode<T> {
  final T item;
  final String? noLot;

  const ScannedCode(this.item, this.noLot);
}

/// QR trên tem có dạng `<MaVT>-<MaLot>`, ví dụ `SC00001234-0102T3DL`
/// (mã lô = thời gian hóa đơn + ký hiệu nhân viên). Tách theo dấu `-` và
/// dò bằng chính danh sách vật tư (`find`), nên mã vật tư có chứa `-` hay mã
/// quét chỉ có mã vật tư (không lô) đều vẫn nhận đúng.
///
/// Thử lần lượt: nguyên chuỗi là mã vật tư; rồi cắt tại từng dấu `-` từ phải
/// sang trái (phần trước = mã vật tư, phần sau = mã lô).
ScannedCode<T>? resolveScannedCode<T>(String raw, T? Function(String) find) {
  final code = raw.trim();
  if (code.isEmpty) return null;

  final whole = find(code);
  if (whole != null) return ScannedCode(whole, null);

  var i = code.lastIndexOf('-');
  while (i > 0) {
    final item = find(code.substring(0, i).trim());
    if (item != null) {
      final lot = code.substring(i + 1).trim();
      return ScannedCode(item, lot.isEmpty ? null : lot);
    }
    i = code.lastIndexOf('-', i - 1);
  }
  return null;
}
