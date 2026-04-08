import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/service/CartService.service.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class CartItem extends StatelessWidget {
  final Cart cart;
  final bool isEven;
  final VoidCallback? onTap;
  final VoidCallback? onCallBack;

  const CartItem({
    super.key,
    required this.cart,
    required this.isEven,
    this.onTap,
    this.onCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    // final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = cart.statusID == 1 ? Colors.green : Colors.orange;
    final statusText =
        cart.nameStatus ??
        (cart.statusID == 1 ? "ĐÃ XÁC NHẬN" : "CHỜ XÁC NHẬN");

    NavigationHelper nav = NavigationHelper();
    MySharedPreferences prefs = MySharedPreferences();
    CartService cartService = CartService();
    final isAdminOrEditor = AppState.instance.get<bool>("role") == true;

    Future<int?> _getCurrentUserID() async {
      final acc = await prefs.getDataObject("account");
      return acc?["AccountID"];
    }

    return Dismissible(
      key: ValueKey(cart.cartAID),
      direction: DismissDirection.horizontal,
      background: _buildLeftBackground(),
      secondaryBackground: _buildRightBackground(),
      confirmDismiss: (direction) async {
        final accountID = await _getCurrentUserID();
        if (direction == DismissDirection.startToEnd) {
          if (cart.statusID == 1) {
            _showSnack(context, "Đơn đã xác nhận không thể xóa!");
            return false;
          }
          if (cart.accountID != accountID) {
            _showSnack(context, "Bạn không phải người tạo đơn!");
            return false;
          }

          final confirm = await _confirmDialog(
            context,
            "Xác nhận",
            "Bạn có chắc muốn xóa đơn này?",
          );
          if (confirm == true) {
            final response = await cartService.deleteCart(
              "Cart",
              jsonEncode({"CartAID": cart.cartAID}),
            );
            if (response["statusCode"] == 200) {
              onCallBack?.call();
              _showSnack(context, "Xóa đơn hàng thành công!");
            }
          }
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          if (!isAdminOrEditor) {
            _showSnack(context, "Bạn không có quyền xác nhận!");
            return false;
          }
          if (cart.statusID == 1) {
            _showSnack(context, "Đơn đã xác nhận!");
            return false;
          }

          final confirm = await _confirmDialog(
            context,
            "Xác nhận",
            "Bạn có chắc muốn xác nhận đơn này?",
          );
          if (confirm == true) {
            final response = await cartService.confirmCart(
              accountID.toString(),
              cart.cartAID.toString(),
              jsonEncode({"Status": 1}),
            );
            if (response["statusCode"] == 200) {
              onCallBack?.call();
              _showSnack(context, "Cập nhật thành công!");
            } else {
              nav.pushAndRemoveUntil(context, const Loginscreen());
            }
          }
          return false;
        }
        return false;
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEven ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
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
                        cart.productID ?? 'Cart #${cart.cartAID}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _buildStatusBadge(statusColor, statusText),
                  ],
                ),
                const SizedBox(height: 12),

                /// PRODUCT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.inventory_2_outlined, color: statusColor),
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
                          if (cart.idPartNo?.isNotEmpty == true)
                            Text(
                              "Danh điểm: ${cart.idPartNo}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      "${cart.qty ?? 0}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// PRICE GROUP
                Row(
                  children: [
                    Expanded(
                      child: _meta(
                        Icons.attach_money,
                        "Giá: ${_money(cart.price)}",
                      ),
                    ),
                    Expanded(
                      child: _meta(
                        Icons.payments_outlined,
                        "Tổng: ${_money(cart.total)}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _meta(
                        Icons.percent,
                        "VAT: ${_money(cart.priceVAT)}",
                      ),
                    ),
                    Expanded(
                      child: _meta(
                        Icons.account_balance_wallet,
                        "NET: ${_money(cart.priceNET)}",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// SUPPLIER + DELIVERY
                Row(
                  children: [
                    Expanded(
                      child: _meta(
                        Icons.store,
                        cart.nameSource ?? "Chưa có NCC",
                      ),
                    ),
                    Expanded(
                      child: _meta(
                        Icons.local_shipping,
                        cart.nameDelivery ?? "Chưa có nơi giao",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// PAYMENT + BILL
                Row(
                  children: [
                    Expanded(
                      child: _meta(
                        Icons.payment,
                        cart.namePayment ?? "Chưa có thanh toán",
                      ),
                    ),
                    Expanded(
                      child: _meta(
                        Icons.receipt_long,
                        cart.billName ?? "Chưa có hóa đơn",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// MANUFACTURER + COUNTRY
                Row(
                  children: [
                    Expanded(
                      child: _meta(Icons.factory, cart.manufacturerName ?? ""),
                    ),
                    Expanded(
                      child: _meta(Icons.public, cart.countryName ?? ""),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// USER + EMPLOYEE
                Row(
                  children: [
                    Expanded(child: _meta(Icons.person, cart.fullName ?? "")),
                    Expanded(
                      child: _meta(Icons.badge, cart.nameEmployee ?? ""),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// TIME
                _meta(
                  Icons.schedule,
                  cart.deliveryTime != null
                      ? "Ngày giao: ${dateFormat.format(cart.deliveryTime!)}"
                      : "Chưa có ngày giao",
                ),

                // if (cart.lastTime != null)
                //   _meta(Icons.update,
                //       "Cập nhật: ${dateTimeFormat.format(cart.lastTime!)}"),
                if (cart.remark?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(cart.remark!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftBackground() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 24),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: const [
        Icon(Icons.delete, color: Colors.white, size: 28),
        SizedBox(width: 10),
        Text(
          "XÓA ĐƠN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );

  Widget _buildRightBackground() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: const [
        Text(
          "XÁC NHẬN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        SizedBox(width: 10),
        Icon(Icons.check_circle, color: Colors.white, size: 28),
      ],
    ),
  );

  Widget _meta(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
    ],
  );

  Widget _buildStatusBadge(Color color, String text) => Container(
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

  String _money(double? value) =>
      "${NumberFormat("#,###", "vi_VN").format(value ?? 0)} đ";

  void _showSnack(BuildContext c, String msg) =>
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));

  Future<bool?> _confirmDialog(BuildContext c, String title, String msg) =>
      showDialog<bool>(
        context: c,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text("OK"),
            ),
          ],
        ),
      );
}
