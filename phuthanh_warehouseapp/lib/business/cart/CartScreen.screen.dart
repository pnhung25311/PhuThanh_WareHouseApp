import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/cart/CartDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomCartItem.custom.dart';
import 'package:phuthanh_warehouseapp/business/service/CartService.service.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';

class CartListScreen extends StatefulWidget {
  const CartListScreen({super.key});

  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  List<Cart> _carts = []; // list lưu dữ liệu Cart
  bool _isLoading = false; // trạng thái loading
  final CartService _cartService = CartService();
  NavigationHelper navigationHelper = NavigationHelper();

  @override
  void initState() {
    super.initState();
    _loadData(); // load ngay khi màn hình mở
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final result = await _cartService.getAllCarts();

      // Kiểm tra mã lỗi tương tự như code của bạn
      final statusCode = result["statusCode"] as int? ?? 0;

      if (statusCode == 403 || statusCode == 401 || statusCode == 0) {
        // Đẩy về màn Login (giả sử bạn có navigationHelper giống code cũ)
        navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
        return; // dừng tiếp tục xử lý
      }

      // Thành công → cập nhật list
      final List<Cart> newCarts = result["body"] as List<Cart>;

      setState(() {
        _carts.clear();
        _carts.addAll(newCarts);
      });

      print("Load thành công: ${_carts.length} giỏ hàng");
    } catch (e) {
      print("Lỗi load giỏ hàng: $e");
      // Có thể thêm SnackBar thông báo lỗi cho người dùng
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giỏ hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách giỏ hàng...'),
                ],
              ),
            )
          : _carts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có giỏ hàng nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: _carts.length,
                itemBuilder: (context, index) {
                  final cart = _carts[index];
                  return CartItem(
                    cart: cart,
                    onTap: () {
                      // TODO: mở chi tiết
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chi tiết giỏ #${cart.cartAID}'),
                        ),
                      );
                    },
                    onSwipeLeft: () {
                      // TODO: mở chi tiết
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Chạy hàm #${cart.cartAID}')),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Tạo giỏ mới
          navigationHelper.push(
            context,
            CartDetailScreen(item: Cart.empty(), isCreate: true),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm phiếu'),
      ),
    );
  }
}
