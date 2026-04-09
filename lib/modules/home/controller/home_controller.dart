import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../dashboard/repository/dashboard_repository.dart';
import '../models/farm_alerts.dart';
import '../repository/alerts_repository.dart';

class HomeController extends GetxController {
  final AlertsRepository _alertsRepository = AlertsRepository();
  final DashboardRepository _dashboardRepository = DashboardRepository();

  final RxBool isLoading = true.obs;
  final Rx<FarmAlerts> alerts = const FarmAlerts.empty().obs;
  final RxDouble todayMilk = 0.0.obs;

  String get todayDisplay =>
      DateFormat('EEE, dd MMM yyyy').format(DateTime.now());
  String get currentMonth => DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _alertsRepository.getAlerts(),
        _dashboardRepository.getSummary(currentMonth),
      ]);
      alerts.value = results[0] as FarmAlerts;
      todayMilk.value = (results[1] as dynamic).todayTotalMilk as double;
    } finally {
      isLoading.value = false;
    }
  }
}
