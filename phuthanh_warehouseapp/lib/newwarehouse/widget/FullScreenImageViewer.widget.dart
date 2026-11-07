import 'package:flutter/material.dart';

/// Xem ảnh toàn màn hình, vuốt ngang giữa nhiều ảnh, pinch/double-tap để zoom
/// qua [InteractiveViewer]. Dùng chung cho danh sách vật tư (long-press) và
/// màn chi tiết vật tư.
class FullScreenImageViewer extends StatelessWidget {
  final List<String> urls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: urls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: Image.network(
                urls[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
