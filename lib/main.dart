import 'package:cattle_manager/core/notifications/notification_service.dart';
import 'package:cattle_manager/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'core/auth/auth_service.dart';
import 'core/network/api_client.dart';
import 'core/network/network_status_service.dart';
import 'core/sync/sync_service.dart';
import 'config/app_theme.dart';
import 'modules/auth/controller/auth_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background message received');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.initialize();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    if (kDebugMode) {
      print('Failed to load env variables');
    }
  }

  await Get.putAsync(() => NetworkStatusService().init(), permanent: true);

  final authService = await Get.putAsync(
    () => AuthService().init(),
    permanent: true,
  );

  await authService.restoreSession();

  await Get.putAsync(() => ApiClient().init(), permanent: true);

  await Get.putAsync(() => SyncService().init(), permanent: true);

  await NotificationService.registerCurrentToken();

  Get.put(AuthController(), permanent: true);

  runApp(
    CattleManagerApp(
      initialRoute:
          authService.isAuthenticated.value ? AppRoutes.main : AppRoutes.signIn,
    ),
  );
}

class CattleManagerApp extends StatelessWidget {
  final String initialRoute;

  const CattleManagerApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cattle Manager',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
