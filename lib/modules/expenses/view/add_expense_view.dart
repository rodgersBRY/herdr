import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../cows/models/cow.dart';
import '../models/expense_log.dart';
import '../repository/expense_repository.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_AddExpenseCtrl());

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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0.1),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'expense_date',
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
                          child: CircularProgressIndicator(strokeWidth: 2),
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

class _AddExpenseCtrl extends GetxController {
  final ExpenseRepository _repository = ExpenseRepository();
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
    isSaving.value = true;

    try {
      final now = DateTime.now().toIso8601String();
      await _repository.insert(
        ExpenseLog(
          cowLocalId: cow.localId,
          category: values['category'] as String,
          amount: double.parse(values['amount'] as String),
          expenseDate:
              DateFormat('yyyy-MM-dd').format(values['expense_date'] as DateTime),
          notes: values['notes'] as String?,
          createdAt: now,
          updatedAt: now,
        ),
      );

      Get.back(result: true);
      Get.snackbar(
        'Expense saved',
        'The expense has been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
