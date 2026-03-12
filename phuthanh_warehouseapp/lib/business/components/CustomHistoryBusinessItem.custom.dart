import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/business/History.model.dart';
import 'package:intl/intl.dart';

class HistoryBusinessItem extends StatelessWidget {
  final HistoryBusiness item;

  const HistoryBusinessItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        /// BORDER + LEFT COLOR BAR
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          /// HEADER (có nền màu)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.maVt,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.ngayCt != null
                      ? DateFormat("dd/MM/yyyy").format(item.ngayCt!.toLocal())
                      : "",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DIEN GIAI
                Text(
                  item.dienGiai ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 10),

                /// KHO + KH
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.warehouse,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.tenKho ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.tenKh ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 18),

                /// SO LUONG - GIA - TIEN
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _info("SL", formatNumber(item.slNhap), Colors.blue, false),
                    _info(
                      "Đơn giá",
                      formatNumber(item.gia),
                      Colors.orange,
                      true,
                    ),
                    _info(
                      "Tổng tiền",
                      formatNumber(item.tienNhap),
                      Colors.green,
                      true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value, Color color, bool isMoney) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 3),
        Text(
          value + " " + (isMoney ? "VND" : ""),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  String formatNumber(num? value) {
    if (value == null) return "0";
    return NumberFormat("#,###").format(value);
  }
}
