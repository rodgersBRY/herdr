import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/utils/app_formatters.dart';
import '../controller/home_controller.dart';

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
              onPressed: ctrl.loadAlerts,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = ctrl.alerts.value;
          final hasAnyAlerts = alerts.healthDue.isNotEmpty ||
              alerts.calvingDue.isNotEmpty ||
              alerts.noMilkToday.isNotEmpty ||
              alerts.recentlyTreated.isNotEmpty;

          return RefreshIndicator(
            onRefresh: ctrl.loadAlerts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HeroCard(todayMilk: ctrl.todayMilk.value),
                const SizedBox(height: 16),
                if (alerts.noMilkToday.isNotEmpty)
                  _AlertSection(
                    title: 'Missing milk logs',
                    color: Colors.blue,
                    icon: Icons.water_drop,
                    children: alerts.noMilkToday
                        .map(
                          (item) => _AlertTile(
                            title: item.tagNumber,
                            subtitle: item.breed,
                          ),
                        )
                        .toList(),
                  ),
                if (alerts.healthDue.isNotEmpty)
                  _AlertSection(
                    title: 'Health follow-ups',
                    color: Colors.red,
                    icon: Icons.medical_services,
                    children: alerts.healthDue
                        .map(
                          (item) => _AlertTile(
                            title: item.tagNumber,
                            subtitle:
                                '${item.description} • ${AppFormatters.prettyDate(item.nextDueDate)}',
                          ),
                        )
                        .toList(),
                  ),
                if (alerts.calvingDue.isNotEmpty)
                  _AlertSection(
                    title: 'Calving due',
                    color: Colors.orange,
                    icon: Icons.event_available,
                    children: alerts.calvingDue
                        .map(
                          (item) => _AlertTile(
                            title: item.tagNumber,
                            subtitle:
                                'Expected ${AppFormatters.prettyDate(item.expectedCalvingDate)}',
                          ),
                        )
                        .toList(),
                  ),
                if (alerts.recentlyTreated.isNotEmpty)
                  _AlertSection(
                    title: 'Recently treated',
                    color: Colors.teal,
                    icon: Icons.healing,
                    children: alerts.recentlyTreated
                        .map(
                          (item) => _AlertTile(
                            title: item.tagNumber,
                            subtitle:
                                '${item.description} • ${AppFormatters.prettyDate(item.recordDate)}',
                          ),
                        )
                        .toList(),
                  ),
                if (!hasAnyAlerts)
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 56,
                          color: AppTheme.primary.withValues(alpha: 0.55),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Everything looks good today.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double todayMilk;

  const _HeroCard({required this.todayMilk});

  @override
  Widget build(BuildContext context) {
    final network = Get.find<NetworkStatusService>();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123B2F), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                network.statusLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Today\'s milk',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            '${todayMilk.toStringAsFixed(1)} L',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Alerts below stay live online and still fall back to local farm data when you are offline.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _AlertSection extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<Widget> children;

  const _AlertSection({
    required this.title,
    required this.color,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.14),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AlertTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
