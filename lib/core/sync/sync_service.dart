import 'package:get/get.dart';

import '../auth/auth_service.dart';
import '../../modules/breeding/repository/breeding_repository.dart';
import '../../modules/cows/repository/cow_repository.dart';
import '../../modules/expenses/repository/expense_repository.dart';
import '../../modules/health/repository/health_repository.dart';
import '../../modules/milk/repository/milk_repository.dart';
import '../../modules/sales/repository/sales_repository.dart';
import '../network/network_status_service.dart';

class SyncService extends GetxService {
  final CowRepository _cowRepository = CowRepository();
  final MilkRepository _milkRepository = MilkRepository();
  final HealthRepository _healthRepository = HealthRepository();
  final BreedingRepository _breedingRepository = BreedingRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final SalesRepository _salesRepository = SalesRepository();
  final AuthService _authService = Get.find<AuthService>();

  Worker? _networkWorker;
  Worker? _authWorker;

  Future<SyncService> init() async {
    final network = Get.find<NetworkStatusService>();

    _networkWorker = ever<bool>(network.isOnline, (online) {
      if (online && _authService.isAuthenticated.value) {
        syncAll();
      }
    });

    _authWorker = ever<bool>(_authService.isAuthenticated, (authenticated) {
      if (authenticated && network.isOnline.value) {
        syncAll();
      }
    });

    if (network.isOnline.value && _authService.isAuthenticated.value) {
      await syncAll();
    }
    return this;
  }

  Future<void> syncAll() async {
    if (!_authService.isAuthenticated.value) {
      return;
    }

    await _cowRepository.syncPending();
    await _milkRepository.syncPending();
    await _healthRepository.syncPending();
    await _breedingRepository.syncPending();
    await _expenseRepository.syncPending();
    await _salesRepository.syncPending();
  }

  @override
  void onClose() {
    _networkWorker?.dispose();
    _authWorker?.dispose();
    super.onClose();
  }
}
