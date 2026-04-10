import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../config/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../cows/models/cow.dart';
import '../models/breeding_record.dart';
import '../repository/breeding_repository.dart';

class BreedingRecordController extends GetxController {
  final BreedingRepository _repository = BreedingRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;
  final RxString eventType = AppConstants.breedingService.obs;
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
        BreedingRecord(
          cowLocalId: cow.localId,
          eventType: values['eventType'] as String,
          eventDate: fmt.format(values['eventDate'] as DateTime),
          expectedCalvingDate: values['expectedCalvingDate'] != null
              ? fmt.format(values['expectedCalvingDate'] as DateTime)
              : null,
          calfTagNumber: values['calfTagNumber'] as String?,
          calfBreed: values['calfBreed'] as String?,
          calfDateOfBirth: values['eventDate'] != null
              ? fmt.format(values['eventDate'] as DateTime)
              : null,
          notes: values['notes'] as String?,
          createdAt: now,
          updatedAt: now,
        ),
      );

      Get.back(result: true);
      Get.snackbar(
        'Breeding record saved',
        'The record has been saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
