import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/cart/CartDetailScreen.screen.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomCartFilter.custom.dart';
import 'package:phuthanh_warehouseapp/business/components/CustomCartItem.custom.dart';
import 'package:phuthanh_warehouseapp/business/service/CartService.service.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/business/Cart.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Country.model.dart';
import 'package:phuthanh_warehouseapp/model/info/Manufacturer.model.dart';
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
  List<Manufacturer> manufacturers = [];
  List<Country> countrys = [];
  List<Account> acc = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  // List<Cart> _filteredCarts = [];

  final CartService _cartService = CartService();
  NavigationHelper navigationHelper = NavigationHelper();
  final InfoService infoService = InfoService();
  final MySharedPreferences prefs = MySharedPreferences();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSuppliers();
    _loadAccount();
    _loadCountry();
    _loadManufacturer();
  }

  Future<int?> _getCurrentUserID() async {
    final acc = await prefs.getDataObject("account");
    return acc?["AccountID"];
  }

  void _startSearch() {
    setState(() => isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      _carts = _allCarts; // reset lại list
    });
  }

  void _onSearchChanged(String value) {
    final keyword = value.toLowerCase().trim();

    final filtered = _allCarts.where((c) {
      return (c.productID ?? "").toLowerCase().contains(keyword) ||
          (c.nameProduct ?? "").toLowerCase().contains(keyword) ||
          (c.idPartNo ?? "").toLowerCase().contains(keyword);
    }).toList();

    setState(() {
      _carts = filtered;
    });
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

  Future<void> _loadManufacturer() async {
    try {
      final manuList = await infoService.LoadDtataManufacturer();

      setState(() {
        manufacturers = manuList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCountry() async {
    try {
      final countryList = await infoService.LoadDtataCountry();

      setState(() {
        countrys = countryList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAccount() async {
    try {
      final accList = await infoService.LoadDtataAccount();

      setState(() {
        acc = accList;
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
        acc: acc,
        manu: manufacturers,
        country: countrys,
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
    if (f.partnerId != null) {
      filtered = filtered.where((c) => c.deliveryID == f.partnerId).toList();
    }
    if (f.accID != null) {
      filtered = filtered.where((c) => c.accountID == f.accID).toList();
    }
    if (f.manufacturerID != null) {
      filtered = filtered
          .where((c) => c.manufacturerID == f.manufacturerID)
          .toList();
    }
    if (f.countryID != null) {
      filtered = filtered.where((c) => c.countryID == f.countryID).toList();
    }

    /// 📌 Status
    if (f.status != null) {
      filtered = filtered.where((c) => c.statusID == f.status).toList();
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSearching
              ? Padding(
                  key: const ValueKey('searchBar'),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Tìm giỏ hàng...",
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                )
              : const Text('Danh sách giỏ hàng'),
        ),
        actions: [
          /// 🔍 SEARCH
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: isSearching ? _stopSearch : _startSearch,
          ),

          /// 🎯 FILTER (giữ nguyên của bạn)
          if (!isSearching)
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
                    onTap: () async {
                      final result = await navigationHelper.push(
                        context,
                        CartDetailScreen(item: cart, typeSave: "UPDATE"),
                      );
                      if (result == true) {
                        _loadData();
                      }
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await navigationHelper.push(
            context,
            CartDetailScreen(item: Cart.empty(), typeSave: "CREATE"),
          );
          if (result == true) _loadData();
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text(''),
      ),
    );
  }
}
