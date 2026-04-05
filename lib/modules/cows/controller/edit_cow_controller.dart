import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

import '../../../core/network/network_status_service.dart';
import '../models/cow.dart';
import '../repository/cow_repository.dart';

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
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    final values = formKey.currentState!.value;
    isSaving.value = true;

    try {
      final updated = cow.copyWith(
        breed: values['breed'] as String,
        status: values['status'] as String,
      );

      await _repo.update(updated);
      final online = Get.find<NetworkStatusService>().isOnline.value;

      Get.back(result: true);
      Get.snackbar(
        'Cow updated',
        online
            ? 'Changes were synced.'
            : 'Changes were saved offline and queued for sync.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
