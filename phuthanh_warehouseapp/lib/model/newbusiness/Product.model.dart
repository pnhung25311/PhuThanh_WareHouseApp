import 'package:phuthanh_warehouseapp/helper/SearchTextHelper.helper.dart';

/// 1 dòng dữ liệu từ file đồng bộ sản phẩm (`GET /api/file/download-product-sync`
/// — trả về file `.txt`, dạng CSV phân tách bằng `;`, dòng đầu là tên cột).
/// Lưu nguyên `fields` theo tên cột (không cố định vị trí/số lượng cột) vì
/// file có rất nhiều cột "Tồn VAT ..." theo từng kho/chi nhánh — dễ đổi theo
/// thời gian, không nên hard-code từng field riêng lẻ.
class Product {
  final Map<String, String> fields;

  Product(this.fields);

  String field(String header) => fields[header]?.trim() ?? '';

  String get maVt => field('Mã vật tư');
  String get tenHangHoa => field('Tên hàng hóa');
  String get tenVat => field('Tên VAT');
  String get donViTinh => field('Đơn vị tính');
  String get viTri => field('Vị trí');
  String get hangSanXuat => field('Hãng sản xuất');
  String get nuocSanXuat => field('Nước sản xuất');
  String get nhaCungCap => field('Nhà cung cấp');
  String get hangXe => field('Hãng xe');
  String get dongXe => field('Dòng xe');

  /// Tên hiển thị chính — ưu tiên "Tên hàng hóa", fallback "Tên VAT" rồi mã.
  String get displayName {
    if (tenHangHoa.isNotEmpty) return tenHangHoa;
    if (tenVat.isNotEmpty) return tenVat;
    return maVt;
  }

  List<String> get images => ['Hình ảnh 1', 'Hình ảnh 2', 'Hình ảnh 3']
      .map(field)
      .where((url) => url.isNotEmpty)
      .toList();

  /// Gộp mọi cột (trừ link ảnh) đã chuẩn hóa — bỏ dấu, hoa/thường, ký tự đặc
  /// biệt/khoảng trắng — để tìm kiếm mềm (xem [SearchTextHelper]). Tính 1 lần.
  late final String searchText = SearchTextHelper.normalize(
    fields.entries
        .where((e) => !_imageHeaders.contains(e.key))
        .map((e) => e.value)
        .join(' '),
  );

  static const List<String> _imageHeaders = ['Hình ảnh 1', 'Hình ảnh 2', 'Hình ảnh 3'];

  /// Đường dẫn ảnh dạng text (kèm ảnh trống) — hiển thị riêng ngoài carousel
  /// để vẫn thấy đủ nguyên 78 cột gốc khi xem chi tiết.
  List<MapEntry<String, String>> get hinhAnh =>
      _imageHeaders.map((h) => MapEntry(h, field(h))).toList();

  /// Các cột không thuộc nhóm nào bên dưới — thông tin định danh/mô tả chung.
  /// Giữ nguyên đủ cột kể cả khi rỗng (không lọc bỏ) để tổng số cột hiển thị
  /// luôn khớp đúng 78 cột gốc của file đồng bộ.
  List<MapEntry<String, String>> get thongTinChung => fields.entries.where((e) {
        if (_imageHeaders.contains(e.key)) return false;
        if (e.key.startsWith('Tồn')) return false;
        if (e.key.startsWith('Giá vốn')) return false;
        if (e.key.startsWith('Số lượng bán') || e.key == 'Tổng số lượng bán ra') return false;
        if (e.key.contains('Còn dư')) return false;
        return true;
      }).toList();

  /// Tồn kho theo từng kho/chi nhánh (rất nhiều cột "Tồn VAT ..." khác nhau).
  List<MapEntry<String, String>> get tonKhoTheoKho =>
      fields.entries.where((e) => e.key.startsWith('Tồn')).toList();

  List<MapEntry<String, String>> get giaVon =>
      fields.entries.where((e) => e.key.startsWith('Giá vốn')).toList();

  List<MapEntry<String, String>> get banRa => fields.entries
      .where((e) => e.key.startsWith('Số lượng bán') || e.key == 'Tổng số lượng bán ra' || e.key.contains('Còn dư'))
      .toList();
}
