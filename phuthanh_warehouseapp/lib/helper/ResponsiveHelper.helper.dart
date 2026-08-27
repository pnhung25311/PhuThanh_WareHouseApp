import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Chiều rộng tối thiểu (logic pixel) để chuyển sang layout desktop.
const double kDesktopBreakpoint = 900;

/// True nếu app đang chạy trên nền tảng desktop (Windows/macOS/Linux),
/// không tính web hay mobile.
bool get isDesktopPlatform =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

/// True nếu vừa chạy trên nền tảng desktop, vừa có chiều rộng cửa sổ
/// đủ lớn (>= [kDesktopBreakpoint]). Cửa sổ Windows thu nhỏ dưới mốc này
/// vẫn dùng layout mobile.
bool isDesktopLayout(BuildContext context) {
  return isDesktopPlatform &&
      MediaQuery.of(context).size.width >= kDesktopBreakpoint;
}
