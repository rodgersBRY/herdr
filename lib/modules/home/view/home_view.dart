import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../core/network/network_status_service.dart';
import '../../../core/ui/app_loading_dots.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_scaffold.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder:
          (ctrl) => Scaffold(
            appBar: AppBar(
              title: Text(ctrl.todayDisplay),
              actions: [
                IconButton(
                  onPressed: ctrl.loadAlerts,
                  icon: const Icon(Icons.refresh),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'signOut') {
                      await Get.find<AuthController>().signOut();
                    }
                  },
                  itemBuilder: (_) {
                    final auth = Get.find<AuthController>();
                    final email = auth.userEmail;
                    return [
                      if (email != null && email.isNotEmpty)
                        PopupMenuItem<String>(
                          enabled: false,
                          value: 'email',
                          child: Text(
                            email,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const PopupMenuItem<String>(
                        value: 'signOut',
                        child: Text('Sign out'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.account_circle_outlined),
                ),
              ],
            ),
            body: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                  child: AppLoadingDots(
                    color: AppTheme.primary,
                    dotSize: 10,
                    gap: 6,
                  ),
                );
              }

              final alerts = ctrl.alerts.value;
              final hasAnyAlerts =
                  alerts.healthDue.isNotEmpty ||
                  alerts.calvingDue.isNotEmpty ||
                  alerts.noMilkToday.isNotEmpty ||
                  alerts.recentlyTreated.isNotEmpty;

              return RefreshIndicator(
                onRefresh: ctrl.loadAlerts,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _HeroCard(
                      todayMilk: ctrl.todayMilk.value,
                      alertsCount:
                          alerts.healthDue.length +
                          alerts.calvingDue.length +
                          alerts.noMilkToday.length,
                    ),
                    const SizedBox(height: 16),
                    _QuickActionsCard(
                      missingMilkCount: alerts.noMilkToday.length,
                      onAddCow: () => Get.toNamed(AppRoutes.addCow),
                      onLogMilk:
                          () => Get.find<AppScaffoldController>().changePage(2),
                      onRecordSale: () => Get.toNamed(AppRoutes.addSale),
                      onViewHerd:
                          () => Get.find<AppScaffoldController>().changePage(1),
                    ),
                    const SizedBox(height: 16),
                    _FarmSnapshotCard(alerts: alerts),
                    const SizedBox(height: 20),
                    Text(
                      'Today\'s attention list',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (alerts.noMilkToday.isNotEmpty)
                      _AlertSection(
                        title: 'Missing milk logs',
                        color: Colors.blue,
                        icon: Icons.water_drop,
                        children:
                            alerts.noMilkToday
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
                        children:
                            alerts.healthDue
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
                        children:
                            alerts.calvingDue
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
                        children:
                            alerts.recentlyTreated
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
  final int alertsCount;

  const _HeroCard({required this.todayMilk, required this.alertsCount});

  @override
  Widget build(BuildContext context) {
    final network = Get.find<NetworkStatusService>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102E2E), Color(0xFF185B37), Color(0xFF2F7F52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$alertsCount active alerts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Today\'s milk', style: TextStyle(color: Colors.white70)),
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
            'Your home screen now keeps the most common farm actions one tap away while alerts stay live online and still fall back to local data offline.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final int missingMilkCount;
  final VoidCallback onAddCow;
  final VoidCallback onLogMilk;
  final VoidCallback onRecordSale;
  final VoidCallback onViewHerd;

  const _QuickActionsCard({
    required this.missingMilkCount,
    required this.onAddCow,
    required this.onLogMilk,
    required this.onRecordSale,
    required this.onViewHerd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            missingMilkCount > 0
                ? '$missingMilkCount cows still need milk captured today.'
                : 'Jump straight into the tasks you use most.',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.28,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              _QuickActionTile(
                title: 'Add cow',
                subtitle: 'Register a new animal',
                icon: Icons.add_circle_outline,
                color: const Color(0xFF185B37),
                onTap: onAddCow,
              ),
              _QuickActionTile(
                title: 'Log milk',
                subtitle: 'Capture today\'s litres',
                icon: Icons.water_drop_outlined,
                color: const Color(0xFF1D6FA3),
                onTap: onLogMilk,
              ),
              _QuickActionTile(
                title: 'Record sale',
                subtitle: 'Save milk income fast',
                icon: Icons.sell_outlined,
                color: const Color(0xFF9C5A1A),
                onTap: onRecordSale,
              ),
              _QuickActionTile(
                title: 'View herd',
                subtitle: 'Open cows and profiles',
                icon: Icons.pets_outlined,
                color: const Color(0xFF6A3FA0),
                onTap: onViewHerd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmSnapshotCard extends StatelessWidget {
  final dynamic alerts;

  const _FarmSnapshotCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8E0D1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SnapshotMetric(
              label: 'Health due',
              value: '${alerts.healthDue.length}',
              color: Colors.red,
            ),
          ),
          Expanded(
            child: _SnapshotMetric(
              label: 'Calving due',
              value: '${alerts.calvingDue.length}',
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: _SnapshotMetric(
              label: 'No milk yet',
              value: '${alerts.noMilkToday.length}',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SnapshotMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
          border: Border.all(color: color.withValues(alpha: 0.08)),
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
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${children.length}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
