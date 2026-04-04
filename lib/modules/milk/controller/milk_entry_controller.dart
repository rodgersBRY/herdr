import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../cows/repository/cow_repository.dart';
import '../../cows/models/cow.dart';
import '../repository/milk_repository.dart';
import '../models/milk_log.dart';

class MilkEntryController extends GetxController {
  final MilkRepository _milkRepo = MilkRepository();
  final CowRepository _cowRepo = CowRepository();

  final RxBool isLoading = false.obs;
  final RxList<Cow> cows = <Cow>[].obs;
  final RxMap<String, MilkLog> logsByCow = <String, MilkLog>{}.obs;
  final RxMap<String, double> morningInputs = <String, double>{}.obs;
  final RxMap<String, double> eveningInputs = <String, double>{}.obs;
  final RxString selectedDate = ''.obs;
  final RxBool isSaving = false.obs;

  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = today;
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      cows.value = await _cowRepo.getAll();
      final logs = await _milkRepo.getForDate(selectedDate.value);
      logsByCow.value = {for (final l in logs) l.cowLocalId: l};
      morningInputs.value = {for (final l in logs) l.cowLocalId: l.morningLitres};
      eveningInputs.value = {for (final l in logs) l.cowLocalId: l.eveningLitres};
    } finally {
      isLoading.value = false;
    }
  }

  void setMorning(String cowId, String val) {
    morningInputs[cowId] = double.tryParse(val) ?? 0;
  }

  void setEvening(String cowId, String val) {
    eveningInputs[cowId] = double.tryParse(val) ?? 0;
  }

  Future<void> saveAll() async {
    isSaving.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      for (final cow in cows) {
        final morning = morningInputs[cow.localId] ?? 0;
        final evening = eveningInputs[cow.localId] ?? 0;
        if (morning == 0 && evening == 0) continue;
        final log = MilkLog(
          localId: '',
          cowLocalId: cow.localId,
          logDate: selectedDate.value,
          morningLitres: morning,
          eveningLitres: evening,
          createdAt: now,
        );
        await _milkRepo.upsert(log);
      }
      await loadData();
      Get.snackbar('Saved', 'Milk logs saved',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isSaving.value = false;
    }
  }

  double get totalToday {
    double total = 0;
    for (final cow in cows) {
      total += (morningInputs[cow.localId] ?? 0) + (eveningInputs[cow.localId] ?? 0);
    }
    return total;
  }
}
