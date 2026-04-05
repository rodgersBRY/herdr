import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../controller/milk_entry_controller.dart';

class MilkEntryView extends StatelessWidget {
  const MilkEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MilkEntryController>(
      init: MilkEntryController(),
      builder: (ctrl) => Scaffold(
        appBar: AppBar(
          title: const Text('Milk Entry'),
          actions: [
            Obx(
              () => TextButton(
                onPressed: ctrl.isSaving.value ? null : ctrl.saveAll,
                child: ctrl.isSaving.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'SAVE',
                        style: TextStyle(color: AppTheme.primary),
                      ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: ctrl.isSaving.value ? null : ctrl.saveAll,
                icon: ctrl.isSaving.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  ctrl.isSaving.value ? 'Saving milk logs...' : 'Save Milk Logs',
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.cows.isEmpty) {
            return const Center(child: Text('No active cows available.'));
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderTile(
                            label: 'Date',
                            value: ctrl.selectedDate.value,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(ctrl.selectedDate.value),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                await ctrl.changeDate(picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: ctrl.selectedPeriod.value,
                            items: const [
                              DropdownMenuItem(
                                value: 'morning',
                                child: Text('Morning'),
                              ),
                              DropdownMenuItem(
                                value: 'evening',
                                child: Text('Evening'),
                              ),
                            ],
                            decoration: const InputDecoration(labelText: 'Period'),
                            onChanged: (value) {
                              if (value != null) {
                                ctrl.selectedPeriod.value = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recorded today',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${ctrl.totalForDay.toStringAsFixed(1)} L',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: ctrl.cows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final cow = ctrl.cows[index];
                    return _MilkCard(cow: cow, ctrl: ctrl);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _HeaderTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _HeaderTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilkCard extends StatelessWidget {
  final dynamic cow;
  final MilkEntryController ctrl;

  const _MilkCard({required this.cow, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cow.tagNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cow.breed,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: _LitresField(
              initialValue: ctrl.litresInputs[cow.localId] ?? 0,
              onChanged: (value) => ctrl.setLitres(cow.localId, value),
            ),
          ),
        ],
      ),
    );
  }
}

class _LitresField extends StatefulWidget {
  final double initialValue;
  final ValueChanged<String> onChanged;

  const _LitresField({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_LitresField> createState() => _LitresFieldState();
}

class _LitresFieldState extends State<_LitresField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue == 0 ? '' : widget.initialValue.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _LitresField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text =
          widget.initialValue == 0 ? '' : widget.initialValue.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Litres',
        suffixText: 'L',
      ),
      onChanged: widget.onChanged,
    );
  }
}
