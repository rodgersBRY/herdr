import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/cow_profile_controller.dart';
import '../../../config/app_theme.dart';
import '../../../routes/app_routes.dart';

class CowProfileView extends StatelessWidget {
  const CowProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CowProfileController());
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(ctrl.cow.displayName)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                await Get.toNamed(AppRoutes.editCow, arguments: ctrl.cow);
                ctrl.loadAll();
              } else if (v == 'delete') {
                final confirm = await Get.dialog<bool>(AlertDialog(
                  title: const Text('Delete Cow?'),
                  content: Text('Remove ${ctrl.cow.tag} permanently?'),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ));
                if (confirm == true) ctrl.deleteCow();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Milk'),
                Tab(text: 'Health'),
                Tab(text: 'Breeding'),
                Tab(text: 'Expenses'),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
                return TabBarView(
                  children: [
                    _OverviewTab(ctrl: ctrl),
                    _MilkTab(ctrl: ctrl),
                    _HealthTab(ctrl: ctrl),
                    _BreedingTab(ctrl: ctrl),
                    _ExpensesTab(ctrl: ctrl),
                  ],
                );
              }),
            ),
          ],
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
        _InfoCard(children: [
          _InfoRow('Tag', cow.tag),
          if (cow.name != null) _InfoRow('Name', cow.name!),
          _InfoRow('Gender', cow.gender),
          if (cow.breed != null) _InfoRow('Breed', cow.breed!),
          if (cow.birthDate != null) _InfoRow('Birth Date', cow.birthDate!),
          if (cow.weight != null) _InfoRow('Weight', '${cow.weight} kg'),
          _InfoRow('Status', cow.status.toUpperCase()),
          if (cow.notes != null && cow.notes!.isNotEmpty) _InfoRow('Notes', cow.notes!),
        ]),
        const SizedBox(height: 12),
        _InfoCard(children: [
          _InfoRow('Milk logs', '${ctrl.milkLogs.length}'),
          _InfoRow('Health records', '${ctrl.healthRecords.length}'),
          _InfoRow('Breeding records', '${ctrl.breedingRecords.length}'),
          _InfoRow('Total expenses', 'KES ${ctrl.totalExpenses.value.toStringAsFixed(0)}'),
        ]),
      ],
    );
  }
}

class _MilkTab extends StatelessWidget {
  final CowProfileController ctrl;
  const _MilkTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ctrl.milkLogs.isEmpty
          ? const Center(child: Text('No milk logs yet', style: TextStyle(color: AppTheme.textSecondary)))
          : ListView.separated(
              itemCount: ctrl.milkLogs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final log = ctrl.milkLogs[i];
                return ListTile(
                  title: Text(log.logDate, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('AM: ${log.morningLitres}L  |  PM: ${log.eveningLitres}L'),
                  trailing: Text('${log.totalLitres.toStringAsFixed(1)} L',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
                );
              },
            ),
    );
  }
}

class _HealthTab extends StatelessWidget {
  final CowProfileController ctrl;
  const _HealthTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ctrl.healthRecords.isEmpty
          ? const Center(child: Text('No health records yet', style: TextStyle(color: AppTheme.textSecondary)))
          : ListView.separated(
              itemCount: ctrl.healthRecords.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = ctrl.healthRecords[i];
                return ListTile(
                  leading: const Icon(Icons.medical_services, color: Colors.red),
                  title: Text(r.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${r.recordType.toUpperCase()} · ${r.recordDate}${r.nextDueDate != null ? '\nNext: ${r.nextDueDate}' : ''}'),
                  isThreeLine: r.nextDueDate != null,
                  trailing: r.cost != null ? Text('KES ${r.cost!.toStringAsFixed(0)}') : null,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.toNamed(AppRoutes.addHealthRecord, arguments: ctrl.cow);
          ctrl.loadAll();
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BreedingTab extends StatelessWidget {
  final CowProfileController ctrl;
  const _BreedingTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ctrl.breedingRecords.isEmpty
          ? const Center(child: Text('No breeding records yet', style: TextStyle(color: AppTheme.textSecondary)))
          : ListView.separated(
              itemCount: ctrl.breedingRecords.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = ctrl.breedingRecords[i];
                return ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.purple),
                  title: Text(r.recordType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text([
                    if (r.serviceDate != null) 'Date: ${r.serviceDate}',
                    if (r.sireName != null) 'Sire: ${r.sireName}',
                    if (r.pregnancyResult != null) 'Result: ${r.pregnancyResult}',
                    if (r.expectedCalvingDate != null) 'Calving: ${r.expectedCalvingDate}',
                    if (r.notes != null) r.notes!,
                  ].join('\n')),
                  isThreeLine: true,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.toNamed(AppRoutes.addBreedingRecord, arguments: ctrl.cow);
          ctrl.loadAll();
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final CowProfileController ctrl;
  const _ExpensesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppTheme.primary.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.w600)),
                Obx(() => Text('KES ${ctrl.totalExpenses.value.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16))),
              ],
            ),
          ),
          Expanded(
            child: ctrl.expenses.isEmpty
                ? const Center(child: Text('No expenses yet', style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.separated(
                    itemCount: ctrl.expenses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e = ctrl.expenses[i];
                      return ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.orange),
                        title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${e.category.toUpperCase()} · ${e.expenseDate}'),
                        trailing: Text('KES ${e.amount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.toNamed(AppRoutes.addExpense, arguments: ctrl.cow);
          ctrl.loadAll();
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
