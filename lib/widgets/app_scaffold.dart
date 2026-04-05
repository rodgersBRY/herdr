import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';
import '../core/network/network_status_service.dart';
import '../core/sync/sync_service.dart';
import '../modules/home/view/home_view.dart';
import '../modules/cows/view/cows_view.dart';
import '../modules/milk/view/milk_entry_view.dart';
import '../modules/sales/view/sales_view.dart';
import '../modules/dashboard/view/dashboard_view.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppScaffoldController>(
      init: AppScaffoldController(),
      builder:
          (ctrl) => Scaffold(
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: const _ConnectivityStrip(),
                ),
                Expanded(
                  child: IndexedStack(
                    index: ctrl.currentIndex,
                    children: const [
                      HomeView(),
                      CowsView(),
                      MilkEntryView(),
                      SalesView(),
                      DashboardView(),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: ctrl.currentIndex,
                onTap: ctrl.changePage,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppTheme.primary,
                unselectedItemColor: AppTheme.textSecondary,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.pets_outlined),
                    activeIcon: Icon(Icons.pets),
                    label: 'Cows',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.water_drop_outlined),
                    activeIcon: Icon(Icons.water_drop),
                    label: 'Milk',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sell_outlined),
                    activeIcon: Icon(Icons.sell),
                    label: 'Sales',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.query_stats_outlined),
                    activeIcon: Icon(Icons.query_stats),
                    label: 'Dashboard',
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class AppScaffoldController extends GetxController {
  int currentIndex = 0;

  void changePage(int index) {
    currentIndex = index;
    update();
  }
}

class _ConnectivityStrip extends StatelessWidget {
  const _ConnectivityStrip();

  @override
  Widget build(BuildContext context) {
    final network = Get.find<NetworkStatusService>();
    final sync = Get.find<SyncService>();

    return Obx(() {
      final online = network.isOnline.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        color: online ? const Color(0xFFE6F4EA) : const Color(0xFFFFF2D9),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              online ? Icons.cloud_done : Icons.cloud_off,
              size: 18,
              color: online ? AppTheme.primary : const Color(0xFF9A6700),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                online
                    ? 'Online. New changes sync with the server.'
                    : 'Offline mode. Changes stay local until you reconnect.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (online)
              TextButton(
                onPressed: sync.syncAll,
                child: const Text('Sync now'),
              ),
          ],
        ),
      );
    });
  }
}
