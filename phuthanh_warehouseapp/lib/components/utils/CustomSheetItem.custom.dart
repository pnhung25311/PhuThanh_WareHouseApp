import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/info/Sheet.model.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class CustomSheetItem extends StatelessWidget {
  final Sheet item;
  final bool showCheckbox;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onChecked;

  const CustomSheetItem({
    super.key,
    required this.item,
    required this.showCheckbox,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
    this.onChecked,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReadonly = item.status == true;
    Formatdatehelper formatdatehelper = Formatdatehelper();

    return Opacity(
      opacity: isReadonly ? 0.8 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: item.sheetAID == AppState.instance.get("SheetAID")
            ? Colors.blue
            : Colors.white,

        /// 👉 GestureDetector chỉ xử lý LONG PRESS
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: isReadonly ? null : onLongPress,

          /// 👉 InkWell chỉ xử lý TAP – tắt toàn bộ hiệu ứng màu
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,

            // splashColor: Colors.transparent,
            // highlightColor: Colors.transparent,
            // hoverColor: Colors.transparent,
            // focusColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 📄 ICON
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isReadonly
                          ? Colors.grey.shade200
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: isReadonly ? Colors.grey : Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// 📋 CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Mã phiếu: ${item.sheetID}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            /// 🔖 STATUS CHIP
                            _StatusChip(isReadonly: isReadonly),
                          ],
                        ),

                        const SizedBox(height: 6),

                        /// 📝 REMARK
                        if ((item.remark ?? '').isNotEmpty)
                          Text(
                            "Ghi chú: ${item.remark}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        if (item.lastUser != null)
                          Text(
                            "Người tạo phiếu: ${item.lastUser}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        if (item.lastTime != null)
                          Text(
                            "Ngày tạo phiếu: ${formatdatehelper.formatDMY(item.lastTime!)}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// ✅ CHECKBOX
                  if (!isReadonly && showCheckbox)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (v) => onChecked?.call(v ?? false),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔖 STATUS CHIP
class _StatusChip extends StatelessWidget {
  final bool isReadonly;

  const _StatusChip({required this.isReadonly});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isReadonly ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            isReadonly ? Icons.lock : Icons.pending_actions,
            size: 14,
            color: isReadonly ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isReadonly ? 'Hoàn thành' : 'Chưa xong',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isReadonly ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
