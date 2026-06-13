import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/file/screen/TreeviewPage.screen.dart';
// import 'package:phuthanh_warehouseapp/service/notification_service.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  // await NotificationService().init(); // 🔥 thêm dòng này

  AppState.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo 2025',
      debugShowCheckedModeBanner: false,
      home: TreeViewPage(),
    );
  }
}