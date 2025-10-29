import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/router/AppRouter.router.dart';
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/login',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
