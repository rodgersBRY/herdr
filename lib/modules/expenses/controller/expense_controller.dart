import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/app_theme.dart';
import '../../cows/models/cow.dart';
import '../models/expense_log.dart';
import '../repository/expense_repository.dart';

class ExpenseController extends GetxController {
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
    if (!formKey.currentState!.saveAndValidate()) return;

    final values = formKey.currentState!.value;
    isSaving.value = true;

    try {
      final now = DateTime.now().toIso8601String();
      await _repository.insert(
        ExpenseLog(
          cowLocalId: cow.localId,
          category: values['category'] as String,
          amount: double.parse(values['amount'] as String),
          expenseDate: DateFormat('yyyy-MM-dd').format(
            values['expenseDate'] as DateTime,
          ),
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
