import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/HomeBusiness.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/file/screen/TreeviewPage.screen.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/LoginResponse.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/screen/HomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/DesktopContentConstraint.custom.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

/// Mật khẩu mặc định của hệ thống — không được phép giữ lại sau khi đổi mật khẩu.
const String kDefaultPassword = '123';

class ChangePasswordScreen extends StatefulWidget {
  /// Tên đăng nhập điền sẵn (dùng khi bắt buộc đổi mật khẩu ngay sau khi đăng nhập).
  final String? initialUsername;

  /// Nếu true: người dùng bắt buộc phải đổi mật khẩu mặc định trước khi vào app,
  /// không thể back về màn hình trước.
  final bool forceChange;

  /// Hệ thống đích để điều hướng tới sau khi đổi mật khẩu thành công (chỉ dùng khi [forceChange] = true).
  final int? targetSystemId;

  const ChangePasswordScreen({
    super.key,
    this.initialUsername,
    this.forceChange = false,
    this.targetSystemId,
  });

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
  final InfoService _infoService = InfoService();
  final MySharedPreferences _mySharedPreferences = MySharedPreferences();

  @override
  void initState() {
    super.initState();
    if (widget.initialUsername != null) {
      _usernameController.text = widget.initialUsername!;
    }
  }

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
    final username = _usernameController.text.trim();
    final newPassword = _newPasswordController.text;

    try {
      // 1. Xác thực mật khẩu hiện tại bằng chính API đăng nhập (endpoint đã chắc chắn hoạt động)
      final verifyResponse = await api.post(
        'dynamic/login',
        jsonEncode({
          'username': username,
          'password': _oldPasswordController.text,
        }),
      );

      if (verifyResponse.statusCode != 200) {
        _showSnackBar('Mật khẩu hiện tại không đúng', Colors.red);
        return;
      }

      final verifyJson = jsonDecode(verifyResponse.body);
      if (verifyJson is Map && verifyJson.containsKey('error')) {
        _showSnackBar('Mật khẩu hiện tại không đúng', Colors.red);
        return;
      }

      final loginResponse = LoginResponse.fromJson(verifyJson);
      final account = loginResponse.account;

      // 2. Cập nhật mật khẩu mới qua API cập nhật tài khoản
      final updateResult = await _infoService.upDateAccount(
        account.AccountID.toString(),
        jsonEncode({'PassWord': newPassword}),
      );

      if (updateResult['isSuccess'] != true) {
        _showSnackBar('Đổi mật khẩu thất bại, vui lòng thử lại', Colors.red);
        return;
      }

      // 3. Đồng bộ lại thông tin tài khoản/mật khẩu đã lưu cục bộ
      final updatedAccount = account.copyWith(PassWord: newPassword);
      AppState.instance.set('account', updatedAccount);
      AppState.instance.set('token', loginResponse.token);
      await _mySharedPreferences.setDataObject(
        'account',
        updatedAccount.toJson(),
      );
      await _mySharedPreferences.setDataString('username', username);
      await _mySharedPreferences.setDataString('password', newPassword);

      _showSnackBar('Đổi mật khẩu thành công!', Colors.green);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      if (widget.forceChange) {
        _goToTargetSystem();
      } else {
        Navigator.pop(context);
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

  void _goToTargetSystem() {
    switch (widget.targetSystemId) {
      case 2:
        _navigationHelper.pushAndRemoveUntil(context, HomeBusinessScreen());
        break;
      case 3:
        _navigationHelper.pushAndRemoveUntil(context, TreeViewPage());
        break;
      default:
        _navigationHelper.pushAndRemoveUntil(context, HomeScreen());
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
    return WillPopScope(
      onWillPop: () async => !widget.forceChange,
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đổi mật khẩu",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3B62FF),
        automaticallyImplyLeading: !widget.forceChange,
        leading: widget.forceChange
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: DesktopContentConstraint(
        child: Center(
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

                  if (widget.forceChange)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tài khoản của bạn đang dùng mật khẩu mặc định. Vui lòng đổi mật khẩu mới trước khi tiếp tục.',
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Tên đăng nhập
                  TextFormField(
                    controller: _usernameController,
                    readOnly: widget.forceChange,
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
                      if (value.trim() == kDefaultPassword) {
                        return "Không được đặt lại mật khẩu mặc định \"$kDefaultPassword\"";
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
      ),
      ),
    );
  }
}