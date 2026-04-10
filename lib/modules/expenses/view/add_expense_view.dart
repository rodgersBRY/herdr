import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../core/ui/app_loading_dots.dart';
import '../../../core/utils/constants.dart';
import '../controller/expense_controller.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ExpenseController());

    return Scaffold(
      appBar: AppBar(title: Text('Expense • ${ctrl.cow.tagNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderDropdown<String>(
                name: 'category',
                initialValue: AppConstants.expenseTreatment,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.expenseTreatment,
                    child: Text('Treatment'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.expenseDrugs,
                    child: Text('Drugs'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.expenseSupplement,
                    child: Text('Supplement'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.expenseOther,
                    child: Text('Other'),
                  ),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'amount',
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'KES ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0.1),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'expenseDate',
                inputType: InputType.date,
                initialValue: DateTime.now(),
                decoration: const InputDecoration(labelText: 'Expense date'),
                validator: FormBuilderValidators.required(),
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
                      : const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
