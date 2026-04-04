import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/constants.dart';
import '../../../config/app_theme.dart';
import '../../cows/models/cow.dart';
import '../../breeding/repository/breeding_repository.dart';
import '../../breeding/models/breeding_record.dart';

class AddBreedingRecordView extends StatelessWidget {
  const AddBreedingRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_AddBreedingCtrl());
    return Scaffold(
      appBar: AppBar(title: Text('Breeding — ${ctrl.cow.tag}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Obx(() => Column(
                children: [
                  FormBuilderDropdown<String>(
                    name: 'record_type',
                    decoration: const InputDecoration(labelText: 'Type *'),
                    initialValue: AppConstants.breedingService,
                    onChanged: (v) => ctrl.recordType.value = v ?? '',
                    items: const [
                      DropdownMenuItem(value: AppConstants.breedingHeat, child: Text('Heat')),
                      DropdownMenuItem(value: AppConstants.breedingService, child: Text('Service / AI')),
                      DropdownMenuItem(value: AppConstants.breedingPregnancyCheck, child: Text('Pregnancy Check')),
                      DropdownMenuItem(value: AppConstants.breedingCalving, child: Text('Calving')),
                    ],
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 12),
                  FormBuilderDateTimePicker(
                    name: 'service_date',
                    inputType: InputType.date,
                    decoration: const InputDecoration(labelText: 'Date *'),
                    initialValue: DateTime.now(),
                    validator: FormBuilderValidators.required(),
                  ),
                  if (ctrl.recordType.value == AppConstants.breedingService) ...[
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'sire_name',
                      decoration: const InputDecoration(labelText: 'Sire / Bull Name'),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderDropdown<String>(
                      name: 'sire_breed',
                      decoration: const InputDecoration(labelText: 'Sire Breed'),
                      items: AppConstants.breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderDateTimePicker(
                      name: 'pregnancy_check_date',
                      inputType: InputType.date,
                      decoration: const InputDecoration(labelText: 'Pregnancy Check Date'),
                      firstDate: DateTime.now(),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderDateTimePicker(
                      name: 'expected_calving_date',
                      inputType: InputType.date,
                      decoration: const InputDecoration(labelText: 'Expected Calving Date'),
                      firstDate: DateTime.now(),
                    ),
                  ],
                  if (ctrl.recordType.value == AppConstants.breedingPregnancyCheck) ...[
                    const SizedBox(height: 12),
                    FormBuilderDropdown<String>(
                      name: 'pregnancy_result',
                      decoration: const InputDecoration(labelText: 'Result *'),
                      items: const [
                        DropdownMenuItem(value: AppConstants.pregnantYes, child: Text('Pregnant')),
                        DropdownMenuItem(value: AppConstants.pregnantNo, child: Text('Open / Not Pregnant')),
                        DropdownMenuItem(value: AppConstants.pregnantUncertain, child: Text('Uncertain')),
                      ],
                    ),
                  ],
                  if (ctrl.recordType.value == AppConstants.breedingCalving) ...[
                    const SizedBox(height: 12),
                    FormBuilderDropdown<String>(
                      name: 'calf_gender',
                      decoration: const InputDecoration(labelText: 'Calf Gender'),
                      items: const [
                        DropdownMenuItem(value: AppConstants.genderFemale, child: Text('Female')),
                        DropdownMenuItem(value: AppConstants.genderMale, child: Text('Male')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'calf_tag',
                      decoration: const InputDecoration(labelText: 'Calf Tag'),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                  const SizedBox(height: 12),
                  FormBuilderTextField(
                    name: 'notes',
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: ctrl.isSaving.value ? null : ctrl.save,
                    child: ctrl.isSaving.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Record'),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class _AddBreedingCtrl extends GetxController {
  final BreedingRepository _repo = BreedingRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;
  final RxString recordType = AppConstants.breedingService.obs;
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
      String? fmtDate(String key) => v[key] != null ? fmt.format(v[key] as DateTime) : null;

      final record = BreedingRecord(
        localId: '',
        cowLocalId: cow.localId,
        recordType: v['record_type'] as String,
        serviceDate: fmtDate('service_date'),
        sireName: v['sire_name'] as String?,
        sireBreed: v['sire_breed'] as String?,
        pregnancyCheckDate: fmtDate('pregnancy_check_date'),
        pregnancyResult: v['pregnancy_result'] as String?,
        expectedCalvingDate: fmtDate('expected_calving_date'),
        calfGender: v['calf_gender'] as String?,
        calfTag: v['calf_tag'] as String?,
        notes: v['notes'] as String?,
        createdAt: now,
      );
      await _repo.insert(record);
      Get.back(result: true);
      Get.snackbar('Saved', 'Breeding record added', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.primary, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
