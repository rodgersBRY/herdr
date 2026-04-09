import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../core/ui/app_loading_dots.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/constants.dart';
import '../controller/edit_cow_controller.dart';

class EditCowView extends StatelessWidget {
  const EditCowView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(EditCowController());
    final cow = ctrl.cow;

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${cow.tagNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: ctrl.formKey,
          initialValue: {'breed': cow.breed, 'status': cow.status},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaticField(label: 'Tag Number', value: cow.tagNumber),
              _StaticField(
                label: 'Date of Birth',
                value: AppFormatters.prettyDate(cow.dateOfBirth),
              ),
              _StaticField(label: 'Source', value: cow.source),
              const SizedBox(height: 20),
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
              FormBuilderDropdown<String>(
                name: 'status',
                decoration: const InputDecoration(labelText: 'Status'),
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
                validator: FormBuilderValidators.required(),
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
                          : const Text('Update Cow'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticField extends StatelessWidget {
  final String label;
  final String value;

  const _StaticField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
