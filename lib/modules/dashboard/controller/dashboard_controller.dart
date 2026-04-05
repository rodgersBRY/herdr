import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_summary.dart';
import '../repository/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _dashboardRepository = DashboardRepository();

  final RxBool isLoading = true.obs;
  final Rx<DashboardSummary> summary = const DashboardSummary.empty().obs;

  String get currentMonth => DateFormat('yyyy-MM').format(DateTime.now());
  String get monthLabel => DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      summary.value = await _dashboardRepository.getSummary(currentMonth);
    } finally {
      isLoading.value = false;
    }
  }
}
