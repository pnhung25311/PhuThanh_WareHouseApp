import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';

class CartItem extends StatelessWidget {
  final Cart cart;
  final VoidCallback? onTap;          // click để xem chi tiết
  final VoidCallback? onDelete;       // hành động khi swipe left hoặc nhấn nút xóa
  final VoidCallback? onSwipeLeft;    // hàm riêng khi trượt sang trái (nếu khác onDelete)

  const CartItem({
    super.key,
    required this.cart,
    this.onTap,
    this.onDelete,
    this.onSwipeLeft,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _getStatusColor(cart.status ?? 'UNKNOWN');
    final partnerColor = _getPartnerColor(cart.partner);

    return Dismissible(
      key: ValueKey(cart.cartAID), // key duy nhất để Flutter nhận diện item
      direction: DismissDirection.endToStart, // chỉ cho phép swipe từ phải sang trái
      background: _buildSwipeBackground(), // nền đỏ khi swipe
      confirmDismiss: (direction) async {
        // Có thể thêm dialog xác nhận trước khi xóa
        if (onDelete != null || onSwipeLeft != null) {
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận'),
              content: Text('Bạn có chắc muốn xóa giỏ hàng #${cart.cartAID}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          return confirm ?? false;
        }
        return false;
      },
      onDismissed: (direction) {
        // Gọi hàm khi swipe hoàn tất
        if (onSwipeLeft != null) {
          onSwipeLeft!();
        } else if (onDelete != null) {
          onDelete!();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Partner
                CircleAvatar(
                  radius: 32,
                  backgroundColor: partnerColor.withOpacity(0.2),
                  child: Icon(
                    _getPartnerIcon(cart.partner),
                    color: partnerColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mã giỏ + Trạng thái
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              cart.cartID ?? 'Giỏ #${cart.cartAID}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildStatusBadge(statusColor, cart.status ?? 'UNKNOWN'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Người đặt hàng
                      if (cart.fullName != null || cart.accountID != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cart.fullName?.isNotEmpty == true
                                      ? cart.fullName!
                                      : 'Tài khoản #${cart.accountID ?? '?'}',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Nhà cung cấp
                      if (cart.supplierName != null || cart.supplierID != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.store, size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 6),
                              Text(
                                'Đối tác: ${cart.supplierName}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                      // Thời gian
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            cart.orderTime != null
                                ? dateFormat.format(cart.orderTime!)
                                : 'Chưa có TG tạo',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.update, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            cart.lastTime != null
                                ? dateFormat.format(cart.lastTime!)
                                : 'Chưa cập nhật',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),

                      // Ghi chú
                      if (cart.remark != null && cart.remark!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Text(
                            cart.remark!,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Color color, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      color: Colors.redAccent,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.delete_forever_rounded,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Color _getStatusColor(String status) {
    final upper = status.toUpperCase();
    if (upper.contains('ACTIVE') || upper.contains('PENDING')) return Colors.blue;
    if (upper.contains('COMPLETE') || upper.contains('PAID') || upper.contains('DONE')) return Colors.green;
    if (upper.contains('CANCEL') || upper.contains('REJECT')) return Colors.red;
    if (upper.contains('PROCESS') || upper.contains('SHIPPING') || upper.contains('DELIVER')) return Colors.orange;
    return Colors.grey[700]!;
  }

  Color _getPartnerColor(int? partner) {
    switch (partner) {
      case 1: return Colors.blue;
      case 2: return Colors.orangeAccent;
      case 3: return Colors.purple;
      case 4: return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getPartnerIcon(int? partner) {
    switch (partner) {
      case 1: return Icons.home_work_rounded;
      case 2: return Icons.shopping_cart_rounded;
      case 3: return Icons.local_mall_rounded;
      default: return Icons.business_center_rounded;
    }
  }
}