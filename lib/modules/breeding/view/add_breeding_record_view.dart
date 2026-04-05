import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../cows/models/cow.dart';
import '../models/breeding_record.dart';
import '../repository/breeding_repository.dart';

class AddBreedingRecordView extends StatelessWidget {
  const AddBreedingRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_AddBreedingCtrl());

    return Scaffold(
      appBar: AppBar(title: Text('Breeding • ${ctrl.cow.tagNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Obx(
            () => Column(
              children: [
                FormBuilderDropdown<String>(
                  name: 'eventType',
                  initialValue: AppConstants.breedingService,
                  decoration: const InputDecoration(labelText: 'Event type'),
                  onChanged: (value) =>
                      ctrl.eventType.value = value ?? AppConstants.breedingService,
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.breedingHeat,
                      child: Text('Heat'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.breedingService,
                      child: Text('Service'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.breedingPregnancyCheck,
                      child: Text('Pregnancy check'),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.breedingCalving,
                      child: Text('Calving'),
                    ),
                  ],
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'eventDate',
                  inputType: InputType.date,
                  initialValue: DateTime.now(),
                  decoration: const InputDecoration(labelText: 'Event date'),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'expectedCalvingDate',
                  inputType: InputType.date,
                  decoration:
                      const InputDecoration(labelText: 'Expected calving date'),
                ),
                if (ctrl.eventType.value == AppConstants.breedingCalving) ...[
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'calfTagNumber',
                    decoration: const InputDecoration(labelText: 'Calf tag number'),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderDropdown<String>(
                    name: 'calfBreed',
                    decoration: const InputDecoration(labelText: 'Calf breed'),
                    items: AppConstants.breeds
                        .map(
                          (breed) => DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          ),
                        )
                        .toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                ],
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
      ),
    );
  }
}

class _AddBreedingCtrl extends GetxController {
  final BreedingRepository _repository = BreedingRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;
  final RxString eventType = AppConstants.breedingService.obs;
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
        BreedingRecord(
          cowLocalId: cow.localId,
          eventType: values['eventType'] as String,
          eventDate: fmt.format(values['eventDate'] as DateTime),
          expectedCalvingDate: values['expectedCalvingDate'] != null
              ? fmt.format(values['expectedCalvingDate'] as DateTime)
              : null,
          calfTagNumber: values['calfTagNumber'] as String?,
          calfBreed: values['calfBreed'] as String?,
          calfDateOfBirth: values['eventDate'] != null
              ? fmt.format(values['eventDate'] as DateTime)
              : null,
          notes: values['notes'] as String?,
          createdAt: now,
          updatedAt: now,
        ),
      );

      Get.back(result: true);
      Get.snackbar(
        'Breeding record saved',
        'The record has been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
