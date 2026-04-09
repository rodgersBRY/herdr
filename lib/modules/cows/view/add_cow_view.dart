import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../core/ui/app_loading_dots.dart';
import '../../../core/utils/constants.dart';
import '../controller/add_cow_controller.dart';

class AddCowView extends StatelessWidget {
  const AddCowView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AddCowController());

    return Scaffold(
      appBar: AppBar(title: const Text('Register Cow')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'tagNumber',
                decoration: const InputDecoration(labelText: 'Tag Number'),
                textCapitalization: TextCapitalization.characters,
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'breed',
                decoration: const InputDecoration(labelText: 'Breed'),
                items:
                    AppConstants.breeds
                        .map(
                          (breed) => DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          ),
                        )
                        .toList(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'dateOfBirth',
                inputType: InputType.date,
                lastDate: DateTime.now(),
                initialValue: DateTime.now().subtract(
                  const Duration(days: 365),
                ),
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'source',
                decoration: const InputDecoration(labelText: 'Source'),
                initialValue: AppConstants.sourceBought,
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.sourceBought,
                    child: Text('Bought'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.sourceBorn,
                    child: Text('Born on farm'),
                  ),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'status',
                decoration: const InputDecoration(labelText: 'Status'),
                initialValue: AppConstants.statusActive,
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.statusActive,
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.statusSold,
                    child: Text('Sold'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.statusDead,
                    child: Text('Dead'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isSaving.value ? null : ctrl.save,
                  child:
                      ctrl.isSaving.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: AppLoadingDots(dotSize: 4.5, gap: 2.5),
                            ),
                          )
                          : const Text('Save Cow'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
