import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../cows/models/cow.dart';
import '../models/health_record.dart';
import '../repository/health_repository.dart';

class AddHealthRecordView extends StatelessWidget {
  const AddHealthRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_AddHealthCtrl());

    return Scaffold(
      appBar: AppBar(title: Text('Health • ${ctrl.cow.tagNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderDropdown<String>(
                name: 'type',
                initialValue: AppConstants.healthTreatment,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.healthTreatment,
                    child: Text('Treatment'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.healthVaccination,
                    child: Text('Vaccination'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.healthDeworming,
                    child: Text('Deworming'),
                  ),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'drug_used',
                decoration: const InputDecoration(labelText: 'Drug used'),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'record_date',
                inputType: InputType.date,
                initialValue: DateTime.now(),
                lastDate: DateTime.now(),
                decoration: const InputDecoration(labelText: 'Record date'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'next_due_date',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Next due date'),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isSaving.value ? null : ctrl.save,
                  child: ctrl.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddHealthCtrl extends GetxController {
  final HealthRepository _repository = HealthRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;
  late Cow cow;

  @override
  void onInit() {
    super.onInit();
    cow = Get.arguments as Cow;
  }

  Future<void> save() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    final values = formKey.currentState!.value;
    final fmt = DateFormat('yyyy-MM-dd');
    isSaving.value = true;

    try {
      final now = DateTime.now().toIso8601String();
      await _repository.insert(
        HealthRecord(
          cowLocalId: cow.localId,
          type: values['type'] as String,
          description: values['description'] as String,
          drugUsed: values['drug_used'] as String?,
          recordDate: fmt.format(values['record_date'] as DateTime),
          nextDueDate: values['next_due_date'] != null
              ? fmt.format(values['next_due_date'] as DateTime)
              : null,
          notes: values['notes'] as String?,
          createdAt: now,
          updatedAt: now,
        ),
      );

      Get.back(result: true);
      Get.snackbar(
        'Health record saved',
        'The record has been queued for sync if needed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
