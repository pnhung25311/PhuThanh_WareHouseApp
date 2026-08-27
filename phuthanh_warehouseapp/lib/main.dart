// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/Screen/auth/LoginScreen.screen.dart';
// import 'package:phuthanh_warehouseapp/file/screen/TreeviewPage.screen.dart';
// import 'package:phuthanh_warehouseapp/service/notification_service.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("====== 🚀 BẮT ĐẦU KHỞI TẠO APP ======");
    
    // await Firebase.initializeApp();
    print("====== ✅ KHỞI TẠO FIREBASE XONG ======");
    
    AppState.instance.init();
    print("====== ✅ KHỞI TẠO APPSTATE XONG ======");
    
  } catch (e, stack) {
    // Nếu có bất kỳ lỗi gì, dòng này sẽ in ra Terminal bản Release. 
    print("❌❌ LỖI CHÍ MẠNG TẠI HÀM MAIN: $e");
    print(stack);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo 2025',
      debugShowCheckedModeBanner: false,
      home: Loginscreen(),
    );
  }
}
