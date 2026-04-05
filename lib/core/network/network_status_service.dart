import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkStatusService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<NetworkStatusService> init() async {
    final initial = await _connectivity.checkConnectivity();
    _update(initial);
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
    return this;
  }

  String get statusLabel => isOnline.value ? 'Online' : 'Offline';

  void _update(List<ConnectivityResult> results) {
    isOnline.value = results.any((result) => result != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
