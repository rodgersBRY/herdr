import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/constants.dart';
import '../../../config/app_theme.dart';
import '../../cows/models/cow.dart';
import '../repository/expense_repository.dart';
import '../models/expense_log.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_AddExpenseCtrl());
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense — ${ctrl.cow.tag}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: ctrl.formKey,
          child: Column(
            children: [
              FormBuilderDropdown<String>(
                name: 'category',
                decoration: const InputDecoration(labelText: 'Category *'),
                initialValue: AppConstants.expenseMedicine,
                items: const [
                  DropdownMenuItem(value: AppConstants.expenseFeed, child: Text('Feed')),
                  DropdownMenuItem(value: AppConstants.expenseMedicine, child: Text('Medicine')),
                  DropdownMenuItem(value: AppConstants.expenseVet, child: Text('Vet')),
                  DropdownMenuItem(value: AppConstants.expenseLabour, child: Text('Labour')),
                  DropdownMenuItem(value: AppConstants.expenseOther, child: Text('Other')),
                ],
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(labelText: 'Description *'),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'amount',
                decoration: const InputDecoration(labelText: 'Amount (KES) *', prefixText: 'KES '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0.1),
                ]),
              ),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(
                name: 'expense_date',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Date *'),
                initialValue: DateTime.now(),
                lastDate: DateTime.now(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed: ctrl.isSaving.value ? null : ctrl.save,
                    child: ctrl.isSaving.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Expense'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddExpenseCtrl extends GetxController {
  final ExpenseRepository _repo = ExpenseRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;
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
      final expense = ExpenseLog(
        localId: '',
        cowLocalId: cow.localId,
        category: v['category'] as String,
        amount: double.parse(v['amount'] as String),
        description: v['description'] as String,
        expenseDate: DateFormat('yyyy-MM-dd').format(v['expense_date'] as DateTime),
        notes: v['notes'] as String?,
        createdAt: now,
      );
      await _repo.insert(expense);
      Get.back(result: true);
      Get.snackbar('Saved', 'Expense added', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.primary, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}
