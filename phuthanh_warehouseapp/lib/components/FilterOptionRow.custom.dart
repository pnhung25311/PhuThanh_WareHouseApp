import 'package:flutter/material.dart';

/// Một dòng lựa chọn (có dấu tích khi đang chọn) dùng trong các bảng lọc.
/// Luôn giữ chỗ cho dấu tích nên dòng không đổi kích thước khi chọn.
class FilterOptionRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const FilterOptionRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? Colors.blue.withValues(alpha: 0.08) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      color: selected ? Colors.blue.shade800 : Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.check,
              size: 20,
              color: selected ? Colors.blue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
