import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../core/ui/app_loading_dots.dart';
import '../../../core/utils/constants.dart';
import '../controller/health_record_controller.dart';

class AddHealthRecordView extends StatelessWidget {
  const AddHealthRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HealthRecordController());

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
                name: 'drugUsed',
                decoration: const InputDecoration(labelText: 'Drug used'),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'recordDate',
                inputType: InputType.date,
                initialValue: DateTime.now(),
                lastDate: DateTime.now(),
                decoration: const InputDecoration(labelText: 'Record date'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'nextDueDate',
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
    );
  }
}
