import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/auth/auth_service.dart';
import 'app_routes.dart';

class AuthRequiredMiddleware extends GetMiddleware {
  @override
  int? get priority => -100;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (!auth.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.signIn);
    }

    return null;
  }
}

class GuestOnlyMiddleware extends GetMiddleware {
  @override
  int? get priority => -100;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthService>();
    if (auth.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.main);
    }

    return null;
  }
}
