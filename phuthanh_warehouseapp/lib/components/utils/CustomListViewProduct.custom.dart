import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductItem.custom.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomProductLongClick.custom.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';

class ProductListView extends StatefulWidget {
  final List<Product> products;
  final Future<void> Function() onRefresh;

  const ProductListView({
    super.key,
    required this.products,
    required this.onRefresh,
  });

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final ScrollController _controller = ScrollController();
  ProductLongClick productLongClick = ProductLongClick();
  // @override
  // void initState() {
  //   super.initState();
  //   _controller = ScrollController();
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const Center(child: Text("Không có sản phẩm."));
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          return ProductItem(
            key: ValueKey('${product.productAID ?? ''}-$index'),
            item: product,
            onLongPress: () {
              productLongClick.show(context, product);
            },
          );
        },
      ),
    );
  }
}
