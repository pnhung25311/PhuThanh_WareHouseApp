import 'dart:io';

import 'package:flutter/material.dart';

enum ScreenshotAction { saveToServer, saveToDevice, saveBoth, copy }

/// BottomSheet hiển thị ngay sau khi phát hiện người dùng chụp màn hình,
/// cho phép chọn: lưu vào server, lưu vào máy, lưu cả 2, hoặc copy ảnh.
class ScreenshotOptionsSheet extends StatelessWidget {
  final File screenshot;

  const ScreenshotOptionsSheet({super.key, required this.screenshot});

  static Future<ScreenshotAction?> show(
    BuildContext context,
    File screenshot,
  ) {
    return showModalBottomSheet<ScreenshotAction>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ScreenshotOptionsSheet(screenshot: screenshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              screenshot,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 160,
                child: Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Đã chụp màn hình',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.blue),
            title: const Text('Lưu vào server'),
            onTap: () => Navigator.pop(context, ScreenshotAction.saveToServer),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt, color: Colors.green),
            title: const Text('Lưu vào máy'),
            onTap: () => Navigator.pop(context, ScreenshotAction.saveToDevice),
          ),
          ListTile(
            leading: const Icon(Icons.save, color: Colors.orange),
            title: const Text('Lưu cả 2'),
            onTap: () => Navigator.pop(context, ScreenshotAction.saveBoth),
          ),
          ListTile(
            leading: const Icon(Icons.copy, color: Colors.purple),
            title: const Text('Copy ảnh'),
            onTap: () => Navigator.pop(context, ScreenshotAction.copy),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
