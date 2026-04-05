import 'package:get/get.dart';

import '../../breeding/models/breeding_record.dart';
import '../../breeding/repository/breeding_repository.dart';
import '../../cows/models/cow.dart';
import '../../cows/repository/cow_repository.dart';
import '../../expenses/models/expense_log.dart';
import '../../expenses/repository/expense_repository.dart';
import '../../health/models/health_record.dart';
import '../../health/repository/health_repository.dart';
import '../../milk/models/milk_log.dart';
import '../../milk/repository/milk_repository.dart';

class CowProfileController extends GetxController {
  final CowRepository _cowRepository = CowRepository();
  final MilkRepository _milkRepository = MilkRepository();
  final HealthRepository _healthRepository = HealthRepository();
  final BreedingRepository _breedingRepository = BreedingRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  late Cow cow;

  final RxList<MilkLog> milkLogs = <MilkLog>[].obs;
  final RxList<HealthRecord> healthRecords = <HealthRecord>[].obs;
  final RxList<BreedingRecord> breedingRecords = <BreedingRecord>[].obs;
  final RxList<ExpenseLog> expenses = <ExpenseLog>[].obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    cow = Get.arguments as Cow;
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final freshCow = await _cowRepository.getById(cow.localId, refresh: true);
      if (freshCow != null) {
        cow = freshCow;
      }

      final results = await Future.wait([
        _milkRepository.getForCow(cow.localId),
        _healthRepository.getForCow(cow.localId),
        _breedingRepository.getForCow(cow.localId),
        _expenseRepository.getForCow(cow.localId),
        _expenseRepository.getTotalForCow(cow.localId),
      ]);

      milkLogs.assignAll(results[0] as List<MilkLog>);
      healthRecords.assignAll(results[1] as List<HealthRecord>);
      breedingRecords.assignAll(results[2] as List<BreedingRecord>);
      expenses.assignAll(results[3] as List<ExpenseLog>);
      totalExpenses.value = results[4] as double;
      update();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsInactive(String status) async {
    final updated = cow.copyWith(status: status);
    cow = await _cowRepository.update(updated);
    update();
    await loadAll();
  }
}
