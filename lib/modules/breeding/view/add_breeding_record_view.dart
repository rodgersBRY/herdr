import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../core/ui/app_loading_dots.dart';
import '../../../core/utils/constants.dart';
import '../controller/breeding_record_controller.dart';

class AddBreedingRecordView extends StatelessWidget {
  const AddBreedingRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BreedingRecordController());

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
                  decoration: const InputDecoration(
                    labelText: 'Expected calving date',
                  ),
                ),
                if (ctrl.eventType.value == AppConstants.breedingCalving) ...[
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'calfTagNumber',
                    decoration: const InputDecoration(
                      labelText: 'Calf tag number',
                    ),
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
                            child: Center(
                              child: AppLoadingDots(dotSize: 4.5, gap: 2.5),
                            ),
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
