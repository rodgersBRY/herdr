import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/network_status_service.dart';
import '../models/cow.dart';
import '../repository/cow_repository.dart';

class AddCowController extends GetxController {
  final CowRepository _repo = CowRepository();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  final RxBool isSaving = false.obs;

  Future<void> save() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    final values = formKey.currentState!.value;
    isSaving.value = true;

    try {
      final now = DateTime.now().toIso8601String();
      final cow = Cow(
        tagNumber: (values['tagNumber'] as String).trim().toUpperCase(),
        breed: values['breed'] as String,
        dateOfBirth: DateFormat(
          'yyyy-MM-dd',
        ).format(values['dateOfBirth'] as DateTime),
        source: values['source'] as String,
        status: values['status'] as String,
        createdAt: now,
        updatedAt: now,
      );

      await _repo.insert(cow);
      final online = Get.find<NetworkStatusService>().isOnline.value;

      Get.back(result: true);
      Get.snackbar(
        'Cow saved',
        online
            ? 'The record was saved and synced.'
            : 'The record was saved offline and will sync when you reconnect.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
