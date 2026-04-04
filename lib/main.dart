import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CattleManagerApp());
}

class CattleManagerApp extends StatelessWidget {
  const CattleManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cattle Manager',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.main,
      getPages: AppPages.pages,
    );
  }
}
