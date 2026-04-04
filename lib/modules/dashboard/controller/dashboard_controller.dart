import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../cows/repository/cow_repository.dart';
import '../../milk/repository/milk_repository.dart';
import '../../expenses/repository/expense_repository.dart';
import '../../sales/repository/sales_repository.dart';

class DashboardController extends GetxController {
  final CowRepository _cowRepo = CowRepository();
  final MilkRepository _milkRepo = MilkRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final SalesRepository _salesRepo = SalesRepository();

  final RxBool isLoading = true.obs;
  final RxInt totalCows = 0.obs;
  final RxInt pregnantCows = 0.obs;
  final RxInt activeCows = 0.obs;
  final RxDouble todayMilk = 0.0.obs;
  final RxDouble monthlyMilk = 0.0.obs;
  final RxDouble monthlyIncome = 0.0.obs;
  final RxDouble monthlyExpenses = 0.0.obs;

  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get yearMonth => DateFormat('yyyy-MM').format(DateTime.now());
  String get monthLabel => DateFormat('MMMM yyyy').format(DateTime.now());

  double get monthlyProfit => monthlyIncome.value - monthlyExpenses.value;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      final cows = await _cowRepo.getAll();
      totalCows.value = cows.length;
      pregnantCows.value = cows.where((c) => c.status == 'pregnant').length;
      activeCows.value = cows.where((c) => c.status == 'active' || c.status == 'pregnant').length;

      final results = await Future.wait([
        _milkRepo.getTodayTotal(today),
        _milkRepo.getMonthlyTotal(yearMonth),
        _salesRepo.getMonthlyIncome(yearMonth),
        _expenseRepo.getMonthlyTotal(yearMonth),
      ]);
      todayMilk.value = results[0];
      monthlyMilk.value = results[1];
      monthlyIncome.value = results[2];
      monthlyExpenses.value = results[3];
    } finally {
      isLoading.value = false;
    }
  }
}
