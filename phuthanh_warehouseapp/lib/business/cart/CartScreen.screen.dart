import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/cart/CartDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomCartFilter.custom.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomCartItem.custom.dart';
import 'package:phuthanh_warehouseapp/business/service/CartService.service.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Supplier.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';

class CartListScreen extends StatefulWidget {
  final bool isBusiness;
  const CartListScreen({super.key, required this.isBusiness});

  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {
  List<Cart> _allCarts = []; // dữ liệu gốc
  List<Cart> _carts = []; // dữ liệu hiển thị
  bool _isLoading = false;
  CartFilterResult? _currentFilter;
  List<Supplier> suppliers = [];

  final CartService _cartService = CartService();
  NavigationHelper navigationHelper = NavigationHelper();
  final InfoService infoService = InfoService();
  final MySharedPreferences prefs = MySharedPreferences();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSuppliers();
  }

  Future<int?> _getCurrentUserID() async {
    final acc = await prefs.getDataObject("account");
    return acc?["AccountID"];
  }

  /// ================= LOAD DATA =================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final accountID = await _getCurrentUserID();
      final result;
      if (widget.isBusiness == true) {
        result = await _cartService.getCartsToEmployee(
          jsonEncode({"AccountID": accountID}),
        );
      } else {
        result = await _cartService.getAllCarts();
      }
      final statusCode = result["statusCode"] as int? ?? 0;

      if (statusCode == 403 || statusCode == 401 || statusCode == 0) {
        navigationHelper.pushAndRemoveUntil(context, const Loginscreen());
        return;
      }

      final List<Cart> newCarts = result["body"] as List<Cart>;

      setState(() {
        _allCarts = newCarts;
        _carts = newCarts; // reset filter khi load
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSuppliers() async {
    try {
      final suppList = await infoService.LoadDtataSupplier();

      setState(() {
        suppliers = suppList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// ================= UI FILTER =================
  Future<void> _openFilter() async {
    final result = await showModalBottomSheet<CartFilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CartFilterBottomSheet(
        initial: _currentFilter, // 🔥 giữ state
        suppliers: suppliers,
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilter = result;
      });

      _applyFilterFromResult(result);
    }
  }

  void _applyFilterFromResult(CartFilterResult f) {
    List<Cart> filtered = _allCarts;

    /// 🔎 Keyword
    if (f.keyword != null && f.keyword!.isNotEmpty) {
      filtered = filtered.where((c) {
        return (c.productID ?? "").contains(f.keyword!) ||
            (c.nameProduct ?? "").toLowerCase().contains(
              f.keyword!.toLowerCase(),
            ) ||
            (c.idPartNo ?? "").contains(f.keyword!);
      }).toList();
    }

    /// 📅 Date FIX
    if (f.fromDate != null || f.toDate != null) {
      filtered = filtered.where((c) {
        if (c.deliveryTime == null) return false;

        final d = _onlyDate(c.deliveryTime!);

        if (f.fromDate != null && d.isBefore(_onlyDate(f.fromDate!)))
          return false;

        if (f.toDate != null && d.isAfter(_onlyDate(f.toDate!))) return false;

        return true;
      }).toList();
    }

    /// 👤 FullName
    if (f.fullName != null && f.fullName!.isNotEmpty) {
      filtered = filtered.where((c) {
        return (c.fullName ?? "").toLowerCase().contains(
          f.fullName!.toLowerCase(),
        );
      }).toList();
    }

    /// 🏢 Partner
    if (f.partnerId != null) {
      filtered = filtered.where((c) => c.partner == f.partnerId).toList();
    }

    /// 📌 Status
    if (f.status != null) {
      filtered = filtered.where((c) => c.status == f.status).toList();
    }

    setState(() {
      _carts = filtered;
    });
  }

  DateTime _onlyDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giỏ hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            onPressed: _openFilter,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _carts.isEmpty
          ? const Center(child: Text("Không có dữ liệu"))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                itemCount: _carts.length,
                itemBuilder: (context, index) {
                  final cart = _carts[index];
                  return CartItem(
                    cart: cart,
                    isEven: index % 2 == 0,
                    onCallBack: _loadData,
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await navigationHelper.push(
            context,
            CartDetailScreen(item: Cart.empty(), isCreate: true),
          );
          if (result == true) _loadData();
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Thêm phiếu'),
      ),
    );
  }
}
