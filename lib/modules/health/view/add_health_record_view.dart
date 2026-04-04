import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/constants.dart';
import '../../../config/app_theme.dart';
import '../../cows/models/cow.dart';
import '../../health/repository/health_repository.dart';
import '../../health/models/health_record.dart';

class AddHealthRecordView extends StatelessWidget {
  const AddHealthRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_AddHealthCtrl());
    return Scaffold(
      appBar: AppBar(title: Text('Health — ${ctrl.cow.tag}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderDropdown<String>(
                name: 'record_type',
                decoration: const InputDecoration(labelText: 'Type *'),
                initialValue: AppConstants.healthTreatment,
                items: const [
                  DropdownMenuItem(value: AppConstants.healthTreatment, child: Text('Treatment')),
                  DropdownMenuItem(value: AppConstants.healthVaccination, child: Text('Vaccination')),
                  DropdownMenuItem(value: AppConstants.healthDeworming, child: Text('Deworming')),
                  DropdownMenuItem(value: AppConstants.healthOther, child: Text('Other')),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description *'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(
                name: 'record_date',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Date *'),
                initialValue: DateTime.now(),
                lastDate: DateTime.now(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(
                name: 'next_due_date',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Next Due Date (optional)'),
                firstDate: DateTime.now(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'vet_name',
                decoration: const InputDecoration(labelText: 'Vet Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'cost',
                decoration: const InputDecoration(labelText: 'Cost (KES)', prefixText: 'KES '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: FormBuilderValidators.numeric(checkNullOrEmpty: false),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: ctrl.isSaving.value ? null : ctrl.save,
                    child: ctrl.isSaving.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Record'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddHealthCtrl extends GetxController {
  final HealthRepository _repo = HealthRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;
  late Cow cow;

  @override
  void onInit() {
    super.onInit();
    cow = Get.arguments as Cow;
  }

  Future<void> save() async {
    if (!formKey.currentState!.saveAndValidate()) return;
    final v = formKey.currentState!.value;
    isSaving.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      final fmt = DateFormat('yyyy-MM-dd');
      final record = HealthRecord(
        localId: '',
        cowLocalId: cow.localId,
        recordType: v['record_type'] as String,
        description: v['description'] as String,
        vetName: v['vet_name'] as String?,
        cost: v['cost'] != null && (v['cost'] as String).isNotEmpty ? double.tryParse(v['cost'] as String) : null,
        recordDate: fmt.format(v['record_date'] as DateTime),
        nextDueDate: v['next_due_date'] != null ? fmt.format(v['next_due_date'] as DateTime) : null,
        notes: v['notes'] as String?,
        createdAt: now,
      );
      await _repo.insert(record);
      Get.back(result: true);
      Get.snackbar('Saved', 'Health record added', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.primary, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
