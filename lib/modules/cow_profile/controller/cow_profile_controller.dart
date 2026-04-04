import 'package:get/get.dart';
import '../../cows/models/cow.dart';
import '../../cows/repository/cow_repository.dart';
import '../../milk/models/milk_log.dart';
import '../../milk/repository/milk_repository.dart';
import '../../health/models/health_record.dart';
import '../../health/repository/health_repository.dart';
import '../../breeding/models/breeding_record.dart';
import '../../breeding/repository/breeding_repository.dart';
import '../../expenses/models/expense_log.dart';
import '../../expenses/repository/expense_repository.dart';

class CowProfileController extends GetxController {
  final CowRepository _cowRepo = CowRepository();
  final MilkRepository _milkRepo = MilkRepository();
  final HealthRepository _healthRepo = HealthRepository();
  final BreedingRepository _breedingRepo = BreedingRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();

  late Cow cow;
  final RxInt tabIndex = 0.obs;

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
      final results = await Future.wait([
        _milkRepo.getForCow(cow.localId),
        _healthRepo.getForCow(cow.localId),
        _breedingRepo.getForCow(cow.localId),
        _expenseRepo.getForCow(cow.localId),
        _expenseRepo.getTotalForCow(cow.localId),
      ]);
      milkLogs.value = results[0] as List<MilkLog>;
      healthRecords.value = results[1] as List<HealthRecord>;
      breedingRecords.value = results[2] as List<BreedingRecord>;
      expenses.value = results[3] as List<ExpenseLog>;
      totalExpenses.value = results[4] as double;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCow() async {
    await _cowRepo.delete(cow.localId);
    Get.back(result: 'deleted');
  }
}
