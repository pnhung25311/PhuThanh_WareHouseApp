import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/info/DataCheck.model.dart';

class CustomDataCheckItem extends StatelessWidget {
  final DataCheck item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CustomDataCheckItem({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final double diff = item.qtyDifferent ?? 0;
    final bool isDiff = diff != 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 MÃ SP + PART NO
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${item.productID ?? ''} - ${item.idPartNo ?? ''}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isDiff)
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: diff > 0 ? Colors.orange : Colors.red,
                    ),
                ],
              ),

              const SizedBox(height: 6),

              /// 🔹 TÊN SẢN PHẨM
              Text(
                item.nameProduct ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              /// 🔹 THÔNG TIN PHỤ
              Text(
                "Xuất xứ: ${item.nameCountry ?? '-'} | NCC: ${item.nameSupplier ?? '-'}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 4),

              Text(
                "Đơn vị: ${item.nameUnit ?? '-'}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 4),

              Text(
                "Người kiểm kê: ${item.lastUser ?? '-'}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const Divider(height: 18),

              /// 🔹 SỐ LƯỢNG
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _qtyItem("Kho", item.qtyWareHouse),
                  _qtyItem("Kiểm", item.qtyCheck),
                  _qtyItem(
                    "Chênh lệch",
                    item.qtyDifferent,
                    color: diff == 0
                        ? Colors.green
                        : diff > 0
                            ? Colors.orange
                            : Colors.red,
                  ),
                ],
              ),

              if ((item.remark ?? '').isNotEmpty) ...[
                const Divider(height: 18),
                Text(
                  "Ghi chú: ${item.remark}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyItem(String label, double? value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value?.toStringAsFixed(2) ?? '0',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
