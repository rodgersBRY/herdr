import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/app_theme.dart';
import '../../cows/models/cow.dart';
import '../models/health_record.dart';
import '../repository/health_repository.dart';

class HealthRecordController extends GetxController {
  final HealthRepository _repository = HealthRepository();
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
    final fmt = DateFormat('yyyy-MM-dd');
    isSaving.value = true;

    try {
      final now = DateTime.now().toIso8601String();
      await _repository.insert(
        HealthRecord(
          cowLocalId: cow.localId,
          type: values['type'] as String,
          description: values['description'] as String,
          drugUsed: values['drugUsed'] as String?,
          recordDate: fmt.format(values['recordDate'] as DateTime),
          nextDueDate: values['nextDueDate'] != null
              ? fmt.format(values['nextDueDate'] as DateTime)
              : null,
          notes: values['notes'] as String?,
          createdAt: now,
          updatedAt: now,
        ),
      );

      Get.back(result: true);
      Get.snackbar(
        'Health record saved',
        'The record has been queued for sync if needed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
