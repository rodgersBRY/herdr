import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/network/network_status_service.dart';
import 'core/sync/sync_service.dart';
import 'config/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => NetworkStatusService().init(), permanent: true);
  await Get.putAsync(() => ApiClient().init(), permanent: true);
  await Get.putAsync(() => SyncService().init(), permanent: true);
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
