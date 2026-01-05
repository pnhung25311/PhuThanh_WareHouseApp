import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/ViewHistory.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/Screen/history/HistoryDetailScreen.screen.dart';

class HistoryItem extends StatelessWidget {
  final ViewHistory history;
  final WareHouse warehouse;

  const HistoryItem({
    super.key,
    required this.history,
    required this.warehouse,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImport = history.qty > 0;
    Formatdatehelper formatdatehelper = Formatdatehelper();
    NavigationHelper navigationHelper = NavigationHelper();

    /// 🎨 MÀU ĐẬM HƠN – RÕ RÀNG
    final Color mainColor = isImport
        ? const Color(0xFF0F7A2E)
        : const Color(0xFFB71C1C);
    final Color bgColor = isImport
        ? const Color(0xFFE3F2E5)
        : const Color(0xFFFCE4E4);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          navigationHelper.push(
            context,
            HistoryDetailScreen(
              item: warehouse,
              itemHistory: history,
              isReadOnlyHistory: true,
              isCreateHistory: true,
              readOnly: true,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: mainColor,
                width: 7, // 👈 dày + đậm hơn
              ),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================
              Row(
                children: [
                  _StatusIcon(isImport: isImport, color: mainColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${isImport ? "NHẬP" : "XUẤT"} • ${warehouse.productID}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                  _QtyBadge(qty: history.qty, color: mainColor),
                ],
              ),

              const SizedBox(height: 10),

              /// ================= MAIN INFO =================
              _InfoLine(
                icon: Icons.access_time,
                label: "Thời gian",
                value: formatdatehelper.formatDMY(
                  formatdatehelper.parseDate(history.time.toString()),
                ),
              ),
              _InfoLine(
                icon: Icons.person,
                label: "Nhân viên",
                value: history.nameEmployee,
              ),
              _InfoLine(
                icon: Icons.store,
                label: "Đối tác",
                value: history.partner,
              ),
              if (history.lastUser.isNotEmpty)
                _InfoLine(
                  icon: Icons.verified_user,
                  label: "Người thao tác",
                  value: history.lastUser,
                ),

              if (history.remark.isNotEmpty) const SizedBox(height: 8),

              /// ================= REMARK =================
              if (history.remark.isNotEmpty)
                _NoteLine(icon: Icons.note, text: history.remark),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= STATUS ICON =================
class _StatusIcon extends StatelessWidget {
  final bool isImport;
  final Color color;

  const _StatusIcon({required this.isImport, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isImport ? Icons.arrow_downward : Icons.arrow_upward,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

/// ================= QTY BADGE =================
class _QtyBadge extends StatelessWidget {
  final num qty;
  final Color color;

  const _QtyBadge({required this.qty, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 1.8),
      ),
      child: Text(
        qty.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// ================= INFO LINE =================
class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= NOTE LINE =================
class _NoteLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NoteLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.black87),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
