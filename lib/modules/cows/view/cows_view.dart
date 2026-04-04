import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/cows_controller.dart';
import '../../../config/app_theme.dart';
import '../../../routes/app_routes.dart';

class CowsView extends StatelessWidget {
  const CowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CowsController>(
      init: CowsController(),
      builder: (ctrl) => Scaffold(
        appBar: AppBar(
          title: const Text('Cows'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Get.toNamed(AppRoutes.addCow);
                ctrl.loadCows();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: ctrl.searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search by tag or name...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pets, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text(
                          ctrl.searchCtrl.text.isEmpty ? 'No cows registered yet' : 'No cows found',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        if (ctrl.searchCtrl.text.isEmpty) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Get.toNamed(AppRoutes.addCow);
                              ctrl.loadCows();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Cow'),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: ctrl.loadCows,
                  child: ListView.separated(
                    itemCount: ctrl.filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) => _CowTile(cow: ctrl.filtered[i], ctrl: ctrl),
                  ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Get.toNamed(AppRoutes.addCow);
            ctrl.loadCows();
          },
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _CowTile extends StatelessWidget {
  final cow;
  final CowsController ctrl;
  const _CowTile({required this.cow, required this.ctrl});

  Color _statusColor(String status) {
    switch (status) {
      case 'pregnant': return Colors.purple;
      case 'dry': return Colors.orange;
      case 'sold': return Colors.grey;
      case 'deceased': return Colors.red;
      default: return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _statusColor(cow.status).withOpacity(0.15),
        child: Text(
          cow.tag.isNotEmpty ? cow.tag[0].toUpperCase() : '?',
          style: TextStyle(color: _statusColor(cow.status), fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(cow.tag, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        [
          if (cow.name != null && cow.name!.isNotEmpty) cow.name!,
          if (cow.breed != null && cow.breed!.isNotEmpty) cow.breed!,
          cow.gender,
        ].join(' · '),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _statusColor(cow.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _statusColor(cow.status).withOpacity(0.3)),
        ),
        child: Text(
          cow.status.toUpperCase(),
          style: TextStyle(
            color: _statusColor(cow.status),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () async {
        await Get.toNamed(AppRoutes.cowProfile, arguments: cow);
        ctrl.loadCows();
      },
    );
  }
}
