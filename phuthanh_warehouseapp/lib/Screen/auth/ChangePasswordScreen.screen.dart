import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isLoading = false;

  final NavigationHelper _navigationHelper = NavigationHelper();

  // Hàm kiểm tra mật khẩu: chỉ cho phép chữ, số và phải có ít nhất 1 ký tự đặc biệt
  bool _validatePasswordStructure(String value) {
    // 1. Chỉ chấp nhận chữ cái, chữ số và các ký tự đặc biệt chuẩn (không chứa khoảng trắng)
    final allowedCharacters = RegExp(r'^[a-zA-Z0-9!@#\$%^&*()_+\-=\[\]{};\x27:"\\|,.<>\/?]+$');
    if (!allowedCharacters.hasMatch(value)) {
      return false;
    }

    // 2. Phải chứa ít nhất 1 ký tự đặc biệt
    final hasSpecialChar = RegExp(r'[!@#\$%^&*()_+\-=\[\]{};\x27:"\\|,.<>\/?]');
    return hasSpecialChar.hasMatch(value);
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final api = const ApiClient();

    try {
      // Gọi API đổi mật khẩu (đường dẫn này bạn có thể thay đổi tùy thuộc vào Backend của bạn)
      final response = await api.post(
        'dynamic/change-password', 
        jsonEncode({
          'username': _usernameController.text.trim(),
          'oldPassword': _oldPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey('error')) {
          _showSnackBar('Đổi mật khẩu thất bại: ${jsonResponse['error']}', Colors.red);
          return;
        }

        _showSnackBar('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.', Colors.green);

        // Đợi 1.5 giây để người dùng đọc thông báo rồi quay về màn hình đăng nhập
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          // Quay về màn hình trước đó (Màn hình Login)
          Navigator.pop(context);
        }
      } else {
        String message = "Đổi mật khẩu thất bại (${response.statusCode})";
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey('message')) {
            message = body['message'];
          } else if (body is Map && body.containsKey('error')) {
            message = body['error'];
          }
        } catch (_) {}
        _showSnackBar(message, Colors.red);
      }
    } catch (e) {
      debugPrint("Lỗi đổi mật khẩu: $e");
      _showSnackBar('Không thể kết nối tới server', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đổi mật khẩu",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3B62FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tạo mật khẩu mới",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Mật khẩu mới chỉ được chứa chữ, số và bắt buộc có ít nhất 1 ký tự đặc biệt (ví dụ: @, #,  ...)",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Tên đăng nhập
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Tên đăng nhập",
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF3B62FF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập tên đăng nhập";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mật khẩu cũ
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _isOldPasswordObscure,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu hiện tại",
                      prefixIcon: const Icon(Icons.lock_open, color: Color(0xFF3B62FF)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isOldPasswordObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isOldPasswordObscure = !_isOldPasswordObscure;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập mật khẩu hiện tại";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mật khẩu mới
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _isNewPasswordObscure,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu mới",
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3B62FF)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordObscure = !_isNewPasswordObscure;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập mật khẩu mới";
                      }
                      if (!_validatePasswordStructure(value)) {
                        return "Chỉ gồm chữ, số và có ít nhất 1 ký tự đặc biệt";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Xác nhận mật khẩu mới
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordObscure,
                    decoration: InputDecoration(
                      labelText: "Xác nhận mật khẩu mới",
                      prefixIcon: const Icon(Icons.lock_reset, color: Color(0xFF3B62FF)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng xác nhận mật khẩu mới";
                      }
                      if (value != _newPasswordController.text) {
                        return "Mật khẩu xác nhận không trùng khớp";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Nút bấm Đổi mật khẩu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B62FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Đổi mật khẩu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}