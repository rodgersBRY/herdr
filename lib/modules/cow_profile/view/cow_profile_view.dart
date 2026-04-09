import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/constants.dart';
import '../../../routes/app_routes.dart';
import '../controller/cow_profile_controller.dart';

class CowProfileView extends StatelessWidget {
  const CowProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CowProfileController());

    return DefaultTabController(
      length: 5,
      child: GetBuilder<CowProfileController>(
        builder:
            (_) => Scaffold(
              appBar: AppBar(
                title: Text(ctrl.cow.displayName),
                actions: [
                  IconButton(
                    onPressed: ctrl.loadAll,
                    icon: const Icon(Icons.refresh),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Get.toNamed(
                          AppRoutes.editCow,
                          arguments: ctrl.cow,
                        );
                        await ctrl.loadAll();
                      } else if (value == 'sold') {
                        await ctrl.markAsInactive(AppConstants.statusSold);
                      } else if (value == 'dead') {
                        await ctrl.markAsInactive(AppConstants.statusDead);
                      }
                    },
                    itemBuilder:
                        (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit cow')),
                          PopupMenuItem(
                            value: 'sold',
                            child: Text('Mark as sold'),
                          ),
                          PopupMenuItem(
                            value: 'dead',
                            child: Text('Mark as dead'),
                          ),
                        ],
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Milk'),
                    Tab(text: 'Health'),
                    Tab(text: 'Breeding'),
                    Tab(text: 'Expenses'),
                  ],
                ),
              ),
              body: Obx(
                () =>
                    ctrl.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                          children: [
                            _OverviewTab(ctrl: ctrl),
                            _MilkTab(ctrl: ctrl),
                            _HealthTab(ctrl: ctrl),
                            _BreedingTab(ctrl: ctrl),
                            _ExpenseTab(ctrl: ctrl),
                          ],
                        ),
              ),
            ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final CowProfileController ctrl;

  const _OverviewTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cow = ctrl.cow;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0B6E4F), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cow.tagNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${cow.breed} • ${cow.source}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusPill(label: cow.status.toUpperCase()),
                  _StatusPill(
                    label: cow.isPendingSync ? 'PENDING SYNC' : 'SYNCED',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Details',
          children: [
            _InfoRow('Breed', cow.breed),
            _InfoRow(
              'Date of birth',
              AppFormatters.prettyDate(cow.dateOfBirth),
            ),
            _InfoRow('Source', cow.source),
            _InfoRow('Status', cow.status),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Summary',
          children: [
            _InfoRow('Milk logs', '${ctrl.milkLogs.length}'),
            _InfoRow('Health records', '${ctrl.healthRecords.length}'),
            _InfoRow('Breeding records', '${ctrl.breedingRecords.length}'),
            _InfoRow('Expense entries', '${ctrl.expenses.length}'),
            _InfoRow(
              'Total expenses',
              AppFormatters.money(ctrl.totalExpenses.value),
            ),
          ],
        ),
      ],
    );
  }
}

class _MilkTab extends StatelessWidget {
  final CowProfileController ctrl;

  const _MilkTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.milkLogs.isEmpty) {
      return const _EmptyTab(message: 'No milk logs for this cow yet.');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ctrl.milkLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final log = ctrl.milkLogs[index];
        return _TileCard(
          icon: Icons.water_drop,
          color: Colors.blue,
          title: '${log.litres.toStringAsFixed(1)} L',
          subtitle: '${AppFormatters.prettyDate(log.logDate)} • ${log.period}',
        );
      },
    );
  }
}

class _HealthTab extends StatelessWidget {
  final CowProfileController ctrl;

  const _HealthTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.healthRecords.isEmpty) {
      return Stack(
        children: [
          const _EmptyTab(message: 'No health records yet.'),
          _Fab(
            heroTag: 'cow_profile_health_empty_fab',
            onPressed: () async {
              await Get.toNamed(AppRoutes.addHealthRecord, arguments: ctrl.cow);
              await ctrl.loadAll();
            },
          ),
        ],
      );
    }

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.healthRecords.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final record = ctrl.healthRecords[index];
          return _TileCard(
            icon: Icons.medical_services,
            color: Colors.red,
            title: record.description,
            subtitle: [
              record.type,
              AppFormatters.prettyDate(record.recordDate),
              if (record.nextDueDate != null)
                'Next: ${AppFormatters.prettyDate(record.nextDueDate)}',
              if (record.drugUsed != null) record.drugUsed!,
            ].join(' • '),
          );
        },
      ),
      floatingActionButton: _Fab(
        heroTag: 'cow_profile_health_fab',
        onPressed: () async {
          await Get.toNamed(AppRoutes.addHealthRecord, arguments: ctrl.cow);
          await ctrl.loadAll();
        },
      ),
    );
  }
}

class _BreedingTab extends StatelessWidget {
  final CowProfileController ctrl;

  const _BreedingTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.breedingRecords.isEmpty) {
      return Stack(
        children: [
          const _EmptyTab(message: 'No breeding records yet.'),
          _Fab(
            heroTag: 'cow_profile_breeding_empty_fab',
            onPressed: () async {
              await Get.toNamed(
                AppRoutes.addBreedingRecord,
                arguments: ctrl.cow,
              );
              await ctrl.loadAll();
            },
          ),
        ],
      );
    }

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.breedingRecords.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final record = ctrl.breedingRecords[index];
          final details = <String>[
            record.eventType,
            AppFormatters.prettyDate(record.eventDate),
            if (record.expectedCalvingDate != null)
              'Expected: ${AppFormatters.prettyDate(record.expectedCalvingDate)}',
            if (record.calfTagNumber != null) 'Calf: ${record.calfTagNumber}',
            if (record.notes != null) record.notes!,
          ];
          return _TileCard(
            icon: Icons.favorite,
            color: Colors.purple,
            title: record.eventType.replaceAll('_', ' '),
            subtitle: details.join(' • '),
          );
        },
      ),
      floatingActionButton: _Fab(
        heroTag: 'cow_profile_breeding_fab',
        onPressed: () async {
          await Get.toNamed(AppRoutes.addBreedingRecord, arguments: ctrl.cow);
          await ctrl.loadAll();
        },
      ),
    );
  }
}

class _ExpenseTab extends StatelessWidget {
  final CowProfileController ctrl;

  const _ExpenseTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.expenses.isEmpty) {
      return Stack(
        children: [
          const _EmptyTab(message: 'No expenses recorded for this cow.'),
          _Fab(
            heroTag: 'cow_profile_expense_empty_fab',
            onPressed: () async {
              await Get.toNamed(AppRoutes.addExpense, arguments: ctrl.cow);
              await ctrl.loadAll();
            },
          ),
        ],
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total expenses',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Obx(
                  () => Text(
                    AppFormatters.money(ctrl.totalExpenses.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: ctrl.expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final expense = ctrl.expenses[index];
                return _TileCard(
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                  title: AppFormatters.money(expense.amount),
                  subtitle:
                      '${expense.category} • ${AppFormatters.prettyDate(expense.expenseDate)}${expense.notes != null ? ' • ${expense.notes}' : ''}',
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _Fab(
        heroTag: 'cow_profile_expense_fab',
        onPressed: () async {
          await Get.toNamed(AppRoutes.addExpense, arguments: ctrl.cow);
          await ctrl.loadAll();
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TileCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TileCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String message;

  const _EmptyTab({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  final VoidCallback onPressed;
  final String heroTag;

  const _Fab({required this.onPressed, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
