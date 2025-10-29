import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/system/StatusSystem.model.dart';
import 'package:phuthanh_warehouseapp/service/StatusSystem.service.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  List<StatusSystem> arrStatus = [];

  @override
  void initState() {
    super.initState();

    _loadSavedInfo();
  }

  Future<void> _loadSavedInfo() async {
    final remember =
        await MySharedPreferences.getDataBool('rememberMe') ?? false;
    print("================================================");
    print(remember);
    if (remember) {
      final savedUsername =
          await MySharedPreferences.getDataString('username') ?? '';
      final savedPassword =
          await MySharedPreferences.getDataString('password') ?? '';

      setState(() {
        _rememberMe = true;
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
      });

      // ✅ Tự động login
      if (savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
        print("Auto login with $savedUsername / $savedPassword");
        _handleLogin(savedUsername, savedPassword);
      }
    }
  }

  Future<void> _handleLogin(String username, String password) async {
    final api = const ApiClient();

    try {
      final response = await api.post('dynamic/login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final account = Account.fromJson(jsonResponse);
        print(account);
        await MySharedPreferences.setDataObject('account', account.toJson());
        // print
        await MySharedPreferences.setDataString('username', username);
        await MySharedPreferences.setDataString('password', password);
        if (_rememberMe) {
          await MySharedPreferences.setDataBool('rememberMe', true);
        }

        arrStatus = await StatusSystemService.GetAllStatusSystem();
        print("<=========>");
        print(arrStatus[0].statusID);
        AppState.instance.set("StatusSystem", arrStatus);
        AppState.instance.set("CreateAppendix", arrStatus[0].getBool(arrStatus[0].typeStatus));
        print(AppState.instance.get("CreateAppendix"));


        // Tự động chuyển sang Home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Nếu tự động login thất bại, người dùng sẽ thấy màn login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tự động đăng nhập thất bại: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print("Lỗi auto login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign In to continue',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 26),

                CustomTextFieldIcon(
                  label: "Tên đăng nhập",
                  controller: _usernameController,
                  prefixIcon: Icons.person,
                  hintText: "Nhập tên đăng nhập",
                ),
                const SizedBox(height: 16),

                CustomTextFieldIcon(
                  label: "Mật khẩu",
                  controller: _passwordController,
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  hintText: "Nhập mật khẩu",
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Remember me', style: TextStyle(fontSize: 15)),
                  ],
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _handleLogin(
                        _usernameController.text,
                        _passwordController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B62FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
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
    );
  }
}
