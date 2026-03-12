import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/ViewHistory.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/history/HistoryDetailScreen.screen.dart';

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

    final Color mainColor =
        isImport ? const Color(0xFF1B8F3A) : const Color(0xFFD32F2F);

    final Color softColor =
        isImport ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    Formatdatehelper formatdatehelper = Formatdatehelper();
    NavigationHelper navigationHelper = NavigationHelper();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          /// gradient nhẹ
          gradient: LinearGradient(
            colors: [
              Colors.white,
              softColor.withOpacity(.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          border: Border.all(color: softColor),

          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.04),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ===== HEADER =====
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: softColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isImport
                        ? Icons.south_rounded
                        : Icons.north_rounded,
                    color: mainColor,
                  ),
                ),

                const SizedBox(width: 10),

                /// TYPE LABEL
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: softColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isImport ? "NHẬP KHO" : "XUẤT KHO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                /// QTY BADGE
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${history.qty}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// ===== PRODUCT =====
            Text(
              warehouse.productID.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            /// ===== META ROW =====
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.access_time,
                  text: formatdatehelper.formatDMY(
                    formatdatehelper.parseDate(history.time.toString()),
                  ),
                ),

                if (history.nameEmployee.isNotEmpty)
                  _MetaChip(
                    icon: Icons.person,
                    text: history.nameEmployee,
                  ),

                if (history.partner.isNotEmpty)
                  _MetaChip(
                    icon: Icons.store,
                    text: history.partner,
                  ),
              ],
            ),

            /// ===== REMARK =====
            if (history.remark.isNotEmpty) ...[
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        history.remark,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          )
        ],
      ),
    );
  }
}