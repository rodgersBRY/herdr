import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../controller/add_cow_controller.dart';
import '../../../core/utils/constants.dart';

class AddCowView extends StatelessWidget {
  const AddCowView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AddCowController());
    return Scaffold(
      appBar: AppBar(title: const Text('Add Cow')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'tag',
                decoration: const InputDecoration(labelText: 'Tag / ID *'),
                textCapitalization: TextCapitalization.characters,
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Name (optional)'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              FormBuilderDropdown<String>(
                name: 'gender',
                decoration: const InputDecoration(labelText: 'Gender *'),
                initialValue: AppConstants.genderFemale,
                items: const [
                  DropdownMenuItem(value: AppConstants.genderFemale, child: Text('Female')),
                  DropdownMenuItem(value: AppConstants.genderMale, child: Text('Male')),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderDropdown<String>(
                name: 'breed',
                decoration: const InputDecoration(labelText: 'Breed'),
                items: AppConstants.breeds
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(
                name: 'birth_date',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Birth Date'),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'weight',
                decoration: const InputDecoration(labelText: 'Weight (kg)', suffixText: 'kg'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: FormBuilderValidators.numeric(checkNullOrEmpty: false),
              ),
              const SizedBox(height: 12),
              FormBuilderDropdown<String>(
                name: 'status',
                decoration: const InputDecoration(labelText: 'Status'),
                initialValue: AppConstants.statusActive,
                items: const [
                  DropdownMenuItem(value: AppConstants.statusActive, child: Text('Active')),
                  DropdownMenuItem(value: AppConstants.statusDry, child: Text('Dry')),
                  DropdownMenuItem(value: AppConstants.statusPregnant, child: Text('Pregnant')),
                ],
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: ctrl.isSaving.value ? null : ctrl.save,
                    child: ctrl.isSaving.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Cow'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
