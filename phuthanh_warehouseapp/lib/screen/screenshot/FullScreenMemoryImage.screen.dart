import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/ZoomableImage.custom.dart';

/// Xem ảnh (đã có sẵn bytes) toàn màn hình, có phóng to/thu nhỏ.
class FullScreenMemoryImageScreen extends StatelessWidget {
  final Uint8List bytes;
  final String title;

  const FullScreenMemoryImageScreen({
    super.key,
    required this.bytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: SafeArea(top: false, child: ZoomableImage(bytes: bytes, onDark: true)),
    );
  }
}
