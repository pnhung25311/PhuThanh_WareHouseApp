import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/business/test.dart';
import 'package:phuthanh_warehouseapp/model/system/SystemOption.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/Screen/HomeScreen.screen.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/CustomTextFieldIcon.custom.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionScreenHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/model/auth/LoginResponse.model.dart';
import 'package:phuthanh_warehouseapp/model/info/DrawerItem.model.dart';
import 'package:phuthanh_warehouseapp/model/system/DisplaySetting.model.dart';
import 'package:phuthanh_warehouseapp/model/system/StatusSystem.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/StatusSystem.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  // Danh sách các hệ thống
  final List<SystemOption> _systems = [
    SystemOption(name: 'Hệ thống kho', value: 'system1', id: 1),
    SystemOption(name: 'Hệ thống kinh doanh', value: 'system2', id: 2),
  ];

  // Hệ thống được chọn
  SystemOption? _selectedSystem;

  List<StatusSystem> arrStatus = [];
  StatusSystemService statusSystemService = StatusSystemService();
  NavigationHelper navigationHelper = NavigationHelper();
  MySharedPreferences mySharedPreferences = MySharedPreferences();

  @override
  void initState() {
    super.initState();
    _selectedSystem = _systems[0]; // Mặc định chọn hệ thống đầu tiên
    _loadSavedInfo();
  }

  Future<void> _loadSavedInfo() async {
    final remember =
        await mySharedPreferences.getDataBool('rememberMe') ?? false;

    if (remember) {
      final savedUsername =
          await mySharedPreferences.getDataString('username') ?? '';
      final savedPassword =
          await mySharedPreferences.getDataString('password') ?? '';
      final savedSystem =
          await mySharedPreferences.getDataString('selectedSystem') ?? '';

      setState(() {
        _rememberMe = true;
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;

        // Khôi phục hệ thống đã chọn
        if (savedSystem.isNotEmpty) {
          _selectedSystem = _systems.firstWhere(
            (system) => system.value == savedSystem,
            orElse: () => _systems[0],
          );
        }
      });
    }
  }

  Future<void> _saveSetting() async {
    DrawerItem item = DrawerItem(
      wareHouseID: 1,
      nameWareHouse: "Danh mục sản phẩm",
      wareHouseTable: "Product",
      wareHouseHistory: "vwProduct",
      wareHouseCategory: 0,
      wareHouseDataBase: "",
      wareHouseDataBaseHistory: "",
      wareHouseRequest: "vwRequestProduct",
      wareHouseRequestDataBase: "RequestProduct",
      wareHouseUpdateHistoryDataBase: "",
      wareHouseUpdateHistory: "",
    );
    AppState.instance.set("itemDrawer", item);

    final settingsWH = await mySharedPreferences.getDataObject(
      "showhideWareHouse",
    );

    if (settingsWH == null) {
      final displaySetting = DisplaySetting();
      await mySharedPreferences.setDataObject(
        "showhideWareHouse",
        displaySetting.toJson(),
      );
    } else {
      AppState.instance.set("showhideWareHouse", settingsWH);
    }

    final settingsP = await mySharedPreferences.getDataObject(
      "showhideProduct",
    );

    if (settingsP == null) {
      final displaySetting = DisplaySetting();
      await mySharedPreferences.setDataObject(
        "showhideProduct",
        displaySetting.toJson(),
      );
    } else {
      AppState.instance.set("showhideProduct", settingsP);
    }
  }

  Future<void> _loadRole() async {
    final acc = AppState.instance.get("account") as Account?;

    if (!mounted || acc == null) return;

    final roles = acc.Role == "ADMIN" || acc.Role == "WAREHOUSE";
    AppState.instance.set("role", roles);

    debugPrint("Role from account: ${acc.Role}");
    debugPrint("roles bool: $roles");
  }

  Future<void> _handleLogin(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSystem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hệ thống'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Lưu hệ thống được chọn vào AppState để sử dụng trong toàn bộ app
    AppState.instance.set("selectedSystem", _selectedSystem!.value);
    // AppState.instance.set("apiUrl", _selectedSystem!.apiUrl);

    final api = const ApiClient();

    try {
      final response = await api.post(
        'dynamic/login',
        jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thất bại: ${jsonResponse['error']}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final loginResponse = LoginResponse.fromJson(jsonResponse);
        final account = loginResponse.account;
        AppState.instance.set("account", account);
        AppState.instance.set("token", loginResponse.token);
        print(loginResponse.token);

        await mySharedPreferences.setDataObject('account', account.toJson());
        await mySharedPreferences.setDataString('username', username);
        await mySharedPreferences.setDataString('password', password);
        await mySharedPreferences.setDataBool('rememberMe', _rememberMe);
        _loadRole();

        _saveSetting();
        if (_selectedSystem!.id == 1) {
          navigationHelper.pushAndRemoveUntil(context, HomeScreen());
        } else {
          navigationHelper.pushAndRemoveUntil(context, TestScreen());
        }
      } else {
        String message = "Đăng nhập thất bại (${response.statusCode})";

        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey('message')) {
            message = body['message'];
          } else if (body is Map && body.containsKey('error')) {
            message = body['error'];
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Lỗi login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối tới server'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
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

                  // Dropdown chọn hệ thống
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SystemOption>(
                        value: _selectedSystem,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF3B62FF),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1C1C1C),
                        ),
                        hint: const Text('Chọn hệ thống'),
                        items: _systems.map((SystemOption system) {
                          return DropdownMenuItem<SystemOption>(
                            value: system,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 10),
                                Text(system.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (SystemOption? newValue) {
                          setState(() {
                            _selectedSystem = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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

                  // Hiển thị hệ thống đang chọn
                  if (_selectedSystem != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Đang kết nối tới: ${_selectedSystem!.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
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
