import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import '../../../config/app_theme.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (ctrl) => Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: ctrl.loadStats),
          ],
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
          return RefreshIndicator(
            onRefresh: ctrl.loadStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Herd', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _StatsGrid(children: [
                  _StatCard(label: 'Total Cows', value: '${ctrl.totalCows.value}', icon: Icons.pets, color: AppTheme.primary),
                  _StatCard(label: 'In Milk', value: '${ctrl.activeCows.value}', icon: Icons.water_drop, color: Colors.blue),
                  _StatCard(label: 'Pregnant', value: '${ctrl.pregnantCows.value}', icon: Icons.pregnant_woman, color: Colors.purple),
                ]),
                const SizedBox(height: 20),
                Text('Milk', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _StatsGrid(children: [
                  _StatCard(label: 'Today', value: '${ctrl.todayMilk.value.toStringAsFixed(1)} L', icon: Icons.today, color: AppTheme.primary),
                  _StatCard(label: ctrl.monthLabel, value: '${ctrl.monthlyMilk.value.toStringAsFixed(0)} L', icon: Icons.calendar_month, color: Colors.teal),
                ]),
                const SizedBox(height: 20),
                Text('Finances — ${ctrl.monthLabel}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _StatsGrid(children: [
                  _StatCard(label: 'Income', value: 'KES ${ctrl.monthlyIncome.value.toStringAsFixed(0)}', icon: Icons.trending_up, color: Colors.green),
                  _StatCard(label: 'Expenses', value: 'KES ${ctrl.monthlyExpenses.value.toStringAsFixed(0)}', icon: Icons.trending_down, color: Colors.red),
                  _StatCard(
                    label: 'Profit',
                    value: 'KES ${ctrl.monthlyProfit.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet,
                    color: ctrl.monthlyProfit >= 0 ? Colors.green : Colors.red,
                  ),
                ]),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<Widget> children;
  const _StatsGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: children.length == 2 ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: children,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
