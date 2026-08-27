import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/FormatDateHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/ViewHistory.dart';
import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/history/HistoryDetailScreen.screen.dart';

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
        isImport ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    final Color softColor =
        isImport ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    Formatdatehelper formatdatehelper = Formatdatehelper();
    NavigationHelper navigationHelper = NavigationHelper();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
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
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(.05),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [

                /// ICON
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: softColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isImport
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: mainColor,
                  ),
                ),

                const SizedBox(width: 12),

                /// TYPE + PRODUCT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isImport ? "NHẬP KHO" : "XUẤT KHO",
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        warehouse.productID.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                /// QTY
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${history.qty}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// META INFO
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaChip(
                  icon: Icons.schedule,
                  text: formatdatehelper.formatDMY(
                    formatdatehelper.parseDate(history.time.toString()),
                  ),
                ),

                if (history.nameEmployee.isNotEmpty)
                  _MetaChip(
                    icon: Icons.person_outline,
                    text: history.nameEmployee,
                  ),

                if (history.partner.isNotEmpty)
                  _MetaChip(
                    icon: Icons.storefront_outlined,
                    text: history.partner,
                  ),
              ],
            ),

            /// REMARK
            if (history.remark.isNotEmpty) ...[
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        history.remark,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    )
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade700),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}