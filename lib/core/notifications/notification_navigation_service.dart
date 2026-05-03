import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../modules/cows/models/cow.dart';
import '../../modules/cows/repository/cow_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_scaffold.dart';
import 'notification_route_resolver.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final CowRepository _cowRepository = CowRepository();

  static Future<void> handleData(Map<String, dynamic> data) async {
    final intent = NotificationRouteResolver.resolve(data);
    if (intent == null) {
      debugPrint('No notification route for payload: $data');
      return;
    }

    switch (intent.type) {
      case NotificationRouteIntentType.mainTab:
        await _openMainTab(intent.tabIndex ?? 0);
      case NotificationRouteIntentType.cowProfile:
        await _openCowProfile(intent.cowId);
    }
  }

  static Future<void> _openMainTab(int tabIndex) async {
    _ensureMainRoute();
    _changeMainTabWhenReady(tabIndex);
  }

  static Future<void> _openCowProfile(String? cowId) async {
    if (cowId == null || cowId.isEmpty) {
      await _openMainTab(1);
      return;
    }

    final cow = await _findCowByServerId(cowId);
    if (cow == null) {
      await _openMainTab(1);
      return;
    }

    _ensureMainRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(AppRoutes.cowProfile, arguments: cow);
    });
  }

  static void _ensureMainRoute() {
    if (Get.currentRoute != AppRoutes.main) {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  static void _changeMainTabWhenReady(int tabIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AppScaffoldController>()) {
        Get.find<AppScaffoldController>().changePage(tabIndex);
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<AppScaffoldController>()) {
          Get.find<AppScaffoldController>().changePage(tabIndex);
        }
      });
    });
  }

  static Future<Cow?> _findCowByServerId(String cowId) async {
    try {
      final cows = await _cowRepository.getAll();
      for (final cow in cows) {
        if (cow.serverId == cowId) {
          return cow;
        }
      }
    } catch (error) {
      debugPrint('Failed to resolve notification cowId $cowId: $error');
    }

    return null;
  }
}
