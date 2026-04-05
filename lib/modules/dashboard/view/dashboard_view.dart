import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../core/utils/app_formatters.dart';
import '../controller/dashboard_controller.dart';

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
            IconButton(
              onPressed: ctrl.loadStats,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = ctrl.summary.value;

          return RefreshIndicator(
            onRefresh: ctrl.loadStats,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MetricHero(
                  monthLabel: ctrl.monthLabel,
                  income: summary.monthlyMilkIncome,
                  expenses: summary.monthlyExpenses,
                  profit: summary.profit,
                ),
                const SizedBox(height: 16),
                _GridSection(
                  title: 'Herd status',
                  children: [
                    _MetricCard(
                      label: 'Active cows',
                      value: '${summary.totalActiveCows}',
                      icon: Icons.pets,
                      color: AppTheme.primary,
                    ),
                    _MetricCard(
                      label: 'Pregnant',
                      value: '${summary.pregnantCows}',
                      icon: Icons.event_available,
                      color: Colors.purple,
                    ),
                    _MetricCard(
                      label: 'In milk',
                      value: '${summary.cowsInMilk}',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _GridSection(
                  title: 'Production',
                  children: [
                    _MetricCard(
                      label: 'Today',
                      value: '${summary.todayTotalMilk.toStringAsFixed(1)} L',
                      icon: Icons.today,
                      color: AppTheme.primary,
                    ),
                    _MetricCard(
                      label: ctrl.monthLabel,
                      value:
                          '${summary.monthlyMilkTotal.toStringAsFixed(1)} L',
                      icon: Icons.calendar_month,
                      color: Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RankingCard(
                  title: 'Top milk output',
                  rows: summary.milkPerCow
                      .where((row) => row.totalLitres > 0)
                      .take(5)
                      .map(
                        (row) => _RankingRow(
                          title: row.tagNumber,
                          subtitle: row.breed,
                          value: '${row.totalLitres.toStringAsFixed(1)} L',
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                _RankingCard(
                  title: 'Highest expenses',
                  rows: summary.expensePerCow
                      .where((row) => row.totalExpenses > 0)
                      .take(5)
                      .map(
                        (row) => _RankingRow(
                          title: row.tagNumber,
                          subtitle: row.breed,
                          value: AppFormatters.money(row.totalExpenses),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _MetricHero extends StatelessWidget {
  final String monthLabel;
  final double income;
  final double expenses;
  final double profit;

  const _MetricHero({
    required this.monthLabel,
    required this.income,
    required this.expenses,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173F35), Color(0xFF245E50), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monthLabel, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            AppFormatters.money(profit),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Profit this month',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Income',
                  value: AppFormatters.money(income),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroStat(
                  label: 'Expenses',
                  value: AppFormatters.money(expenses),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _GridSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: children.length == 2 ? 2 : 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: children,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final String title;
  final List<_RankingRow> rows;

  const _RankingCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text('No records yet.')
          else
            ...rows,
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;

  const _RankingRow({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
