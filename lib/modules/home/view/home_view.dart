import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/home_controller.dart';
import '../../../config/app_theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (ctrl) => Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(ctrl.todayDisplay)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: ctrl.loadAlerts,
            ),
          ],
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: ctrl.loadAlerts,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _MilkTodayCard(litres: ctrl.todayMilk.value),
                if (ctrl.missingMilkLog.isNotEmpty)
                  _AlertSection(
                    title: 'Missing Milk Log',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    items: ctrl.missingMilkLog
                        .map((c) => _AlertItem(
                              title: c.tag,
                              subtitle: c.name ?? '',
                              icon: Icons.pets,
                            ))
                        .toList(),
                  ),
                if (ctrl.calvingAlerts.isNotEmpty)
                  _AlertSection(
                    title: 'Due for Calving',
                    icon: Icons.child_care,
                    color: Colors.orange,
                    items: ctrl.calvingAlerts
                        .map((a) => _AlertItem(
                              title: a['tag'] as String,
                              subtitle: 'Expected: ${a['expected_calving_date'] ?? ''}',
                              icon: Icons.child_care,
                            ))
                        .toList(),
                  ),
                if (ctrl.pregnancyAlerts.isNotEmpty)
                  _AlertSection(
                    title: 'Pregnancy Check Due',
                    icon: Icons.pregnant_woman,
                    color: Colors.purple,
                    items: ctrl.pregnancyAlerts
                        .map((a) => _AlertItem(
                              title: a['tag'] as String,
                              subtitle: 'Due: ${a['pregnancy_check_date'] ?? ''}',
                              icon: Icons.pregnant_woman,
                            ))
                        .toList(),
                  ),
                if (ctrl.healthAlerts.isNotEmpty)
                  _AlertSection(
                    title: 'Health Due',
                    icon: Icons.medical_services,
                    color: Colors.red,
                    items: ctrl.healthAlerts
                        .map((a) => _AlertItem(
                              title: a['tag'] as String,
                              subtitle: '${a['record_type']}: ${a['description']}',
                              icon: Icons.medical_services,
                            ))
                        .toList(),
                  ),
                if (ctrl.missingMilkLog.isEmpty &&
                    ctrl.calvingAlerts.isEmpty &&
                    ctrl.pregnancyAlerts.isEmpty &&
                    ctrl.healthAlerts.isEmpty)
                  const _AllClearCard(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _MilkTodayCard extends StatelessWidget {
  final double litres;
  const _MilkTodayCard({required this.litres});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.water_drop, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s Milk', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  '${litres.toStringAsFixed(1)} L',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> items;

  const _AlertSection({required this.title, required this.icon, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Text('${items.length}', style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),
        ),
        ...items,
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AlertItem({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.accent.withOpacity(0.2),
        child: Text(title.isNotEmpty ? title[0] : '?',
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      dense: true,
    );
  }
}

class _AllClearCard extends StatelessWidget {
  const _AllClearCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppTheme.primary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text('All clear!', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          const Text('No alerts for today', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
