import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';
import '../core/network/network_status_service.dart';
import '../core/sync/sync_service.dart';
import '../core/ui/app_loading_dots.dart';
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
                const _SyncDock(),
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

class _SyncDock extends StatelessWidget {
  const _SyncDock();

  @override
  Widget build(BuildContext context) {
    final network = Get.find<NetworkStatusService>();
    final sync = Get.find<SyncService>();

    return Obx(() {
      final online = network.isOnline.value;
      final syncing = sync.isSyncing.value;
      final chipText =
          online ? (syncing ? 'Syncing' : 'Online') : 'Offline mode';

      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      online
                          ? const Color(0xFFEAF6EE)
                          : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        online
                            ? AppTheme.primary.withValues(alpha: 0.22)
                            : const Color(0xFFE2B66D),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      online
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      size: 17,
                      color:
                          online ? AppTheme.primary : const Color(0xFF9A6700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      chipText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                    if (online) ...[
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: syncing ? null : sync.syncAll,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                syncing
                                    ? AppTheme.primary.withValues(alpha: 0.65)
                                    : AppTheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child:
                              syncing
                                  ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: Center(
                                      child: AppLoadingDots(
                                        color: Colors.white,
                                        dotSize: 3.4,
                                        gap: 1.8,
                                      ),
                                    ),
                                  )
                                  : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.sync_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Sync now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
