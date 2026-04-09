import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/constants.dart';
import '../../cows/models/cow.dart';
import '../../cows/repository/cow_repository.dart';
import '../models/milk_log.dart';
import '../repository/milk_repository.dart';

class MilkEntryController extends GetxController {
  final MilkRepository _milkRepository = MilkRepository();
  final CowRepository _cowRepository = CowRepository();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxList<Cow> cows = <Cow>[].obs;
  final RxMap<String, MilkLog> logsByCow = <String, MilkLog>{}.obs;
  final RxMap<String, double> litresInputs = <String, double>{}.obs;
  final RxString selectedDate = ''.obs;
  final RxString selectedPeriod = AppConstants.milkMorning.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      cows.assignAll(
        (await _cowRepository.getAll())
            .where((cow) => cow.status == AppConstants.statusActive)
            .toList(),
      );
      final logs = await _milkRepository.getForDate(
        selectedDate.value,
        period: selectedPeriod.value,
      );
      logsByCow.assignAll({for (final log in logs) log.cowLocalId: log});
      litresInputs.assignAll({
        for (final log in logs) log.cowLocalId: log.litres,
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeDate(DateTime date) async {
    selectedDate.value = DateFormat('yyyy-MM-dd').format(date);
    await loadData();
  }

  Future<void> changePeriod(String period) async {
    selectedPeriod.value = period;
    await loadData();
  }

  void setLitres(String cowId, String value) {
    litresInputs[cowId] = double.tryParse(value) ?? 0;
  }

  Future<void> saveAll() async {
    isSaving.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      for (final cow in cows) {
        final litres = litresInputs[cow.localId] ?? 0;
        if (litres <= 0) {
          continue;
        }

        await _milkRepository.upsert(
          MilkLog(
            cowLocalId: cow.localId,
            logDate: selectedDate.value,
            litres: litres,
            period: selectedPeriod.value,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      await loadData();
      Get.snackbar(
        'Milk saved',
        'Entries for ${selectedDate.value} were saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  double get totalForDay {
    double total = 0;
    for (final value in litresInputs.values) {
      total += value;
    }
    return total;
  }
}
