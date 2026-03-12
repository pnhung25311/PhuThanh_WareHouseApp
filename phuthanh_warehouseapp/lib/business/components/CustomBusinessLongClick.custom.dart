import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/history/HistoryBusinessScreen.screen.dart';
import 'package:phuthanh_warehouseapp/model/info/Business.model.dart';
import 'package:flutter/services.dart';

class BusinessLongClick {
  void show(BuildContext context, Business item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              item.barcode.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //XEM ẢNH
          // ListTile(
          //   leading: const Icon(Icons.image, color: Colors.blue),
          //   title: const Text('Xem ảnh'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => ViewImageScreen(item: item)),
          //     );
          //   },
          // ),
          //SAO CHÉP
          ListTile(
            leading: const Icon(Icons.copy, color: Colors.green),
            title: const Text('Sao chép'),
            onTap: () async {
              String formatNumber(double? value) {
                if (value == null) return '-';
                return value
                    .toStringAsFixed(0)
                    .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    );
              }

              String textToCopy =
                  '''
========== THÔNG TIN HÀNG HÓA ==========

Barcode: ${item.barcode}
Mã Keeton: ${item.maKeeton}
Mã Công Nghiệp: ${item.maCongNghiep}
Danh điểm: ${item.danhDiem}
Bộ danh điểm tương đương: ${item.boDanhDiemTuongDuong}

Tên hàng hóa: ${item.tenHangHoa}
Thông số kỹ thuật: ${item.thongSoKyThuat}

===== XE =====
Hãng xe: ${item.hangXe}
Dòng xe: ${item.dongXe}
Cụm xe: ${item.cumXe}

===== SẢN XUẤT =====
Hãng sản xuất: ${item.hangSanXuat}
Nước sản xuất: ${item.nuocSanXuat}

===== NHÀ CUNG CẤP =====
Nhà cung cấp thực tế: ${item.nhaCungCapThucTe}
Nhà cung cấp hợp đồng: ${item.nhaCungCapHopDong}

Đơn vị tính: ${item.donViTinh}

===== GIÁ =====
Giá vốn 1: ${formatNumber(item.giaVon1)}
Giá vốn 2: ${formatNumber(item.giaVon2)}
VAT Việt Ý: ${formatNumber(item.vatVietY)}
VAT Phú Thành: ${formatNumber(item.vatPhuThanh)}

===== TỒN KHO =====
Kho chính: ${formatNumber(item.khoChinh)}
Kho 397: ${formatNumber(item.kho397)}
Kho Khe Dây: ${formatNumber(item.khoKheDay)}
Kho Khoáng Sản: ${formatNumber(item.khoKhoangSan)}
Kho Làng Khánh: ${formatNumber(item.khoLangKhanh)}

===== BÁN RA =====
Tổng số lượng bán ra: ${formatNumber(item.tongSoLuongBanRa)}
Số lượng bán ra gần nhất: ${formatNumber(item.soLuongBanRaGanNhat)}
Thời gian bán ra gần nhất: ${item.thoiGianBanRaGanNhat}

===== VAT =====
Ghi chú VAT: ${item.ghiChuVat}
Tên hàng hóa theo VAT: ${item.tenHangHoaTheoVat}
CoCQ Việt Ý: ${item.coCqVietY}
CoCQ Phú Thành: ${item.coCqPhuThanh}

===== KHÁC =====
Số lượng dự kiến: ${item.soLuongDuKien}
Mã số hóa đơn: ${item.maSoHoaDon}
Vị trí: ${item.viTri}

===== HÌNH ẢNH =====
Hình ảnh 1: ${item.hinhAnh1 ?? '-'}
Hình ảnh 2: ${item.hinhAnh2 ?? '-'}
Hình ảnh 3: ${item.hinhAnh3 ?? '-'}

===== GHI CHÚ =====
${item.ghiChu}
''';

              await Clipboard.setData(ClipboardData(text: textToCopy));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Đã copy thông tin")),
              );

              Navigator.pop(context);
            },
          ),
          //XEM LỊCH SỬ NHẬP XUẤT
          ListTile(
            leading: const Icon(Icons.history, color: Colors.green),
            title: const Text('Xem lịch sử bán hàng'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryBusinessScreen(item: item, isExIm: true,),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.green),
            title: const Text('Xem lịch sử nhập hàng'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryBusinessScreen(item: item, isExIm: false,),
                ),
              );
            },
          ),
          //THÊM NHẬP XUẤT
          // if (role)
          // ListTile(
          //   leading: const Icon(Icons.update, color: Colors.green),
          //   title: const Text('Thêm nhập/xuất'),
          //   onTap: () async {
          //     Navigator.pop(context);
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(
          //     //     builder: (_) => WarehouseDetailScreen(
          //     //       item: item,
          //     //       readOnly: true,
          //     //       isCreateHistory: true,
          //     //     ),
          //     //   ),
          //     // );
          //   },
          // ),
          //XUẤT ĐIỀU CHUYỂN
          // if (1==2)
          //   ListTile(
          //     leading: const Icon(Icons.update, color: Colors.green),
          //     title: const Text('Xuất điều chuyển'),
          //     onTap: () async {
          //       Navigator.pop(context);
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (_) => WareHouseTransfer(
          //             item: item,
          //             readOnly: role,
          //             isCreateHistory: role,
          //             isReadOnlyHistory: !role,
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          //CHỈNH SỬA THÔNG TIN
          // ListTile(
          //   leading: const Icon(Icons.update, color: Colors.green),
          //   title: const Text('Chỉnh sửa thông tin '),
          //   onTap: () async {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) =>
          //             WarehouseDetailScreen(item: item, isUpDate: true, isReadOnlyHistory: false, readOnly: true,),
          //       ),
          //     );
          //   },
          // ),
          //NHÂN BẢN
          // ListTile(
          //   leading: const Icon(Icons.update, color: Colors.green),
          //   title: const Text('Nhân bản'),
          //   onTap: () async {
          //     // showDialog(context, item);
          //   },
          // ),
        ],
      ),
    );
  }
}
