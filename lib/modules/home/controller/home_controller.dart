import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../health/repository/health_repository.dart';
import '../../breeding/repository/breeding_repository.dart';
import '../../milk/repository/milk_repository.dart';
import '../../cows/repository/cow_repository.dart';
import '../../cows/models/cow.dart';

class HomeController extends GetxController {
  final HealthRepository _healthRepo = HealthRepository();
  final BreedingRepository _breedingRepo = BreedingRepository();
  final MilkRepository _milkRepo = MilkRepository();
  final CowRepository _cowRepo = CowRepository();

  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> healthAlerts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> pregnancyAlerts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> calvingAlerts = <Map<String, dynamic>>[].obs;
  final RxList<Cow> missingMilkLog = <Cow>[].obs;
  final RxDouble todayMilk = 0.0.obs;

  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get todayDisplay => DateFormat('EEE, dd MMM yyyy').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _healthRepo.getDueAlerts(today),
        _breedingRepo.getDuePregnancyChecks(today),
        _breedingRepo.getDueCalvings(today),
        _milkRepo.getTodayTotal(today),
        _getMissingMilkCows(),
      ]);
      healthAlerts.value = results[0] as List<Map<String, dynamic>>;
      pregnancyAlerts.value = results[1] as List<Map<String, dynamic>>;
      calvingAlerts.value = results[2] as List<Map<String, dynamic>>;
      todayMilk.value = results[3] as double;
      missingMilkLog.value = results[4] as List<Cow>;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Cow>> _getMissingMilkCows() async {
    final missingIds = await _milkRepo.getCowsWithoutLogToday(today);
    if (missingIds.isEmpty) return [];
    final allCows = await _cowRepo.getAll();
    return allCows.where((c) => missingIds.contains(c.localId)).toList();
  }
}
