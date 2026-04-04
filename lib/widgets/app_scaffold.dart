import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_theme.dart';
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
      builder: (ctrl) => Scaffold(
        body: IndexedStack(
          index: ctrl.currentIndex,
          children: const [
            HomeView(),
            CowsView(),
            MilkEntryView(),
            SalesView(),
            DashboardView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: ctrl.currentIndex,
          onTap: ctrl.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: AppTheme.surface,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), activeIcon: Icon(Icons.pets), label: 'Cows'),
            BottomNavigationBarItem(icon: Icon(Icons.water_drop_outlined), activeIcon: Icon(Icons.water_drop), label: 'Milk'),
            BottomNavigationBarItem(icon: Icon(Icons.sell_outlined), activeIcon: Icon(Icons.sell), label: 'Sales'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Dashboard'),
          ],
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
