import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../repository/cow_repository.dart';
import '../models/cow.dart';

class EditCowController extends GetxController {
  final CowRepository _repo = CowRepository();
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
      final updated = cow.copyWith(
        tag: values['tag'] as String,
        name: values['name'] as String?,
        gender: values['gender'] as String,
        breed: values['breed'] as String?,
        birthDate: values['birth_date'] != null
            ? DateFormat('yyyy-MM-dd').format(values['birth_date'] as DateTime)
            : null,
        weight: values['weight'] != null && (values['weight'] as String).isNotEmpty
            ? double.tryParse(values['weight'] as String)
            : null,
        status: values['status'] as String? ?? cow.status,
        notes: values['notes'] as String?,
        isSynced: 0,
      );
      await _repo.update(updated);
      Get.back(result: true);
      Get.snackbar('Saved', 'Cow updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isSaving.value = false;
    }
  }
}
