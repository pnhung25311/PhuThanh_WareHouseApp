import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/cart/CartDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/service/CartService.service.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';

class CartItem extends StatelessWidget {
  final Cart cart;
  final bool isEven;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onCallBack;

  const CartItem({
    super.key,
    required this.cart,
    required this.isEven,
    this.onTap,
    this.onDelete,
    this.onCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _getStatusColor(cart.status);
    final statusText = _getStatusText(cart.status);

    NavigationHelper nav = NavigationHelper();
    CartService cartService = CartService();

    return Dismissible(
      key: ValueKey(cart.cartAID),
      direction: DismissDirection.horizontal,
      background: _buildLeftBackground(),
      secondaryBackground: _buildRightBackground(),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          if (cart.status == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đơn hàng đã xác nhận không thể chỉnh sửa!'),
                duration: const Duration(milliseconds: 1500),
              ),
            );
            return false;
          }
          final result = await nav.push(
            context,
            CartDetailScreen(item: cart, isUpdate: true),
          );

          if (result == true && onCallBack != null) {
            onCallBack!();
          }
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          if (cart.status == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đơn hàng đã xác nhận!'),
                duration: const Duration(milliseconds: 1500),
              ),
            );
            return false;
          }
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Xác nhận"),
                content: const Text("Bạn có chắc muốn xác nhận đơn này không?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Hủy"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Đồng ý"),
                  ),
                ],
              );
            },
          );

          if (confirm == true) {
            // 👉 xử lý logic khi confirm
            // if (onDelete != null) {
            //   onDelete!();
            // }
            final response = await cartService.upDateCart(
              "Cart",
              cart.cartAID.toString(),
              jsonEncode({"Status": true}),
            );

            if (response["statusCode"] == 200) {
              if (onCallBack != null) {
                onCallBack!();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Cập nhật thành công'),
                  duration: const Duration(milliseconds: 500),
                ),
              );
              return false;
              // quay lại và báo màn trước refresh
            }
            if (response["statusCode"] == 401 ||
                response["statusCode"] == 403 ||
                response["statusCode"] == 0) {
              nav.pushAndRemoveUntil(context, const Loginscreen());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Lỗi cập nhật: ${response["statusCode"]}'),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            }
            // return true; // cho phép dismiss
          }

          return false; // không dismiss
        }

        return false;
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEven ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cart.cartID ?? 'Cart #${cart.cartAID}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _buildStatusBadge(statusColor, statusText),
                      const SizedBox(width: 6),

                      /// icon DONE
                      if (cart.status == true)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// PRODUCT
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cart.nameProduct ?? "Không có tên sản phẩm",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            /// ✅ chỉ giữ mã sản phẩm
                            if (cart.productID?.trim().isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Mã SP: ${cart.productID}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],

                            /// PartNo (ẩn nếu rỗng)
                            if (cart.idPartNo?.trim().isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Danh điểm: ${cart.idPartNo}",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      /// Qty
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${cart.qty ?? 0}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// USER + SUPPLIER
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeta(
                          icon: Icons.person_outline,
                          text: cart.fullName ?? "Không có tên",
                        ),
                      ),
                      Expanded(
                        child: _buildMeta(
                          icon: Icons.store_outlined,
                          text: cart.supplierName ?? "Không có NCC",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// TIME
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeta(
                          icon: Icons.schedule,
                          text: cart.deliveryTime != null
                              ? dateFormat.format(cart.deliveryTime!)
                              : "Chưa có ngày giao",
                        ),
                      ),
                    ],
                  ),

                  /// REMARK
                  if (cart.remark?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cart.remark!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.grey.withOpacity(0.1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// UI

  Widget _buildStatusBadge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMeta({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Swipe phải (DELETE)
  Widget _buildLeftBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done, color: Colors.white),
          SizedBox(width: 6),
          Text(
            "Xác nhận",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Swipe trái (EDIT)
  Widget _buildRightBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Edit",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 6),
          Icon(Icons.edit, color: Colors.white),
        ],
      ),
    );
  }

  /// LOGIC

  String _getStatusText(bool? status) {
    if (status == null) return "UNKNOWN";
    return status ? "HOÀN THÀNH" : "CHƯA HOÀN THÀNH";
  }

  Color _getStatusColor(bool? status) {
    if (status == null) return Colors.grey;
    return status ? Colors.green : Colors.orange;
  }
}
