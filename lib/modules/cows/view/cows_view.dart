import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../core/ui/app_loading_dots.dart';
import '../../../routes/app_routes.dart';
import '../controller/cows_controller.dart';
import '../models/cow.dart';

class CowsView extends StatelessWidget {
  const CowsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CowsController>(
      init: CowsController(),
      builder:
          (ctrl) => Scaffold(
            appBar: AppBar(
              title: const Text('Herd'),
              actions: [
                IconButton(
                  onPressed: ctrl.loadCows,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'cows_add_fab',
              onPressed: () async {
                await Get.toNamed(AppRoutes.addCow);
                await ctrl.loadCows();
              },
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F5D3A), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Farm register',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${ctrl.cows.length} cows tracked',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: ctrl.searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search by tag, breed, source or status',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(
                        child: AppLoadingDots(
                          color: AppTheme.primary,
                          dotSize: 10,
                          gap: 6,
                        ),
                      );
                    }

                    if (ctrl.filtered.isEmpty) {
                      return Center(
                        child: Text(
                          ctrl.searchCtrl.text.isEmpty
                              ? 'No cows saved yet.'
                              : 'No cows match that search.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: ctrl.loadCows,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: ctrl.filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder:
                            (_, index) => _CowCard(cow: ctrl.filtered[index]),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
    );
  }
}

class _CowCard extends StatelessWidget {
  final Cow cow;

  const _CowCard({required this.cow});

  Color _statusColor(String status) {
    switch (status) {
      case 'sold':
        return const Color(0xFF8A6A00);
      case 'dead':
        return const Color(0xFF9B1C1C);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(cow.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.toNamed(AppRoutes.cowProfile, arguments: cow),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: statusColor.withValues(alpha: 0.14),
                child: Text(
                  cow.tagNumber.characters.first,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cow.tagNumber,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (cow.isPendingSync)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Pending sync',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${cow.breed} • ${cow.source}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  cow.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
