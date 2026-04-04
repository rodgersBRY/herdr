import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/milk_entry_controller.dart';
import '../../../config/app_theme.dart';

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
            Obx(() => TextButton(
                  onPressed: ctrl.isSaving.value ? null : ctrl.saveAll,
                  child: ctrl.isSaving.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SAVE ALL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
          ],
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (ctrl.cows.isEmpty) {
            return const Center(child: Text('No cows registered yet', style: TextStyle(color: AppTheme.textSecondary)));
          }
          return Column(
            children: [
              // Date + Total bar
              Container(
                color: AppTheme.primary.withAlpha(20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ctrl.selectedDate.value,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    Obx(() => Text('Total: ${ctrl.totalToday.toStringAsFixed(1)} L',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                  ],
                ),
              ),
              // Header row
              Container(
                color: AppTheme.primary.withAlpha(10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('COW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                    Expanded(flex: 2, child: Center(child: Text('MORNING (L)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)))),
                    SizedBox(width: 8),
                    Expanded(flex: 2, child: Center(child: Text('EVENING (L)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)))),
                  ],
                ),
              ),
              // Cow list
              Expanded(
                child: ListView.separated(
                  itemCount: ctrl.cows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final cow = ctrl.cows[i];
                    return _MilkRow(cow: cow, ctrl: ctrl);
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

class _MilkRow extends StatelessWidget {
  final dynamic cow;
  final MilkEntryController ctrl;
  const _MilkRow({required this.cow, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cow.tag, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (cow.name != null && cow.name!.isNotEmpty)
                  Text(cow.name!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Obx(() => _LitresInput(
                  initialValue: ctrl.morningInputs[cow.localId] ?? 0,
                  onChanged: (v) => ctrl.setMorning(cow.localId, v),
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Obx(() => _LitresInput(
                  initialValue: ctrl.eveningInputs[cow.localId] ?? 0,
                  onChanged: (v) => ctrl.setEvening(cow.localId, v),
                )),
          ),
        ],
      ),
    );
  }
}

class _LitresInput extends StatefulWidget {
  final double initialValue;
  final ValueChanged<String> onChanged;
  const _LitresInput({required this.initialValue, required this.onChanged});

  @override
  State<_LitresInput> createState() => _LitresInputState();
}

class _LitresInputState extends State<_LitresInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue == 0 ? '' : widget.initialValue.toString();
    _ctrl = TextEditingController(text: v);
  }

  @override
  void didUpdateWidget(_LitresInput old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue && !_ctrl.text.isNotEmpty) {
      final v = widget.initialValue == 0 ? '' : widget.initialValue.toString();
      _ctrl.text = v;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      ),
      onChanged: widget.onChanged,
    );
  }
}
