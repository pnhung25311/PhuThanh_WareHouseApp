import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/info/Product.model.dart';

class ViewImageScreen extends StatelessWidget {
  final Product item;

  const ViewImageScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Danh sách ảnh từ item
    final images = [
      item.img1,
      item.img2,
      item.img3,
    ].whereType<String>().where((url) => url.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ảnh: ${item.nameProduct}'),
        centerTitle: true,
      ),
      body: images.isEmpty
          ? const Center(child: Text('Không có ảnh để hiển thị'))
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imageUrl = images[index];
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Hình ảnh có zoom + loader
                    InteractiveViewer(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,

                          // ✅ Loading indicator khi tải ảnh
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(), // xoay vô hạn
                            );
                          },

                          // ✅ Hiển thị lỗi nếu load ảnh fail
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Text('Không tải được ảnh')),
                        ),
                      ),
                    ),

                    // Tiêu đề "Ảnh 1", "Ảnh 2", ...
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 100),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Ảnh ${index + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
