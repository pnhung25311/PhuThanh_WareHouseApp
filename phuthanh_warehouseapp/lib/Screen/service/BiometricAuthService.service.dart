import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  // 1. Kiểm tra xem thiết bị phần cứng có hỗ trợ sinh trắc học không
  Future<bool> isDeviceSupported() async {
    return await _auth.isDeviceSupported();
  }

  // 2. Kích hoạt quét FaceID / Vân tay
  Future<bool> authenticate() async {
    try {
      // Kiểm tra xem user đã cài đặt vân tay/khuôn mặt trong máy chưa
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return false;

      // CẬP NHẬT CÚ PHÁP MỚI CHO V3.0.0+ TẠI ĐÂY:
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Vui lòng xác thực để tiếp tục vào ứng dụng',
        biometricOnly: true,              // Truyền trực tiếp, không bọc trong AuthenticationOptions nữa
        persistAcrossBackgrounding: true, // Thay thế cho 'stickyAuth: true' của phiên bản cũ
      );
      
      return didAuthenticate;
    } catch (e) {
      print("Lỗi xác thực: $e");
      return false;
    }
  }
}