import 'dart:io';

/// Sự kiện chụp màn hình thiết bị do native báo về.
/// [fromBackground] = true nếu chụp lúc app không ở foreground (chụp bên
/// ngoài app) — khi đó chỉ lưu vào "Local", không hiện popup.
class CapturedScreenshot {
  final File file;
  final bool fromBackground;

  CapturedScreenshot({required this.file, required this.fromBackground});
}
