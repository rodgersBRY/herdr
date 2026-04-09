import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/network/api_error.dart';
import '../../../core/sync/sync_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isSigningIn = false.obs;
  final RxBool isSigningUp = false.obs;
  final RxBool isSigningOut = false.obs;

  String? get userEmail => _authService.userEmail.value;
  String get displayName =>
      _authService.userFullName.value?.trim().isNotEmpty == true
          ? _authService.userFullName.value!.trim()
          : (_authService.userEmail.value ?? 'Farmer');

  Future<void> signIn({required String email, required String password}) async {
    isSigningIn.value = true;

    try {
      await _authService.signIn(email: email, password: password);

      if (Get.isRegistered<SyncService>()) {
        await Get.find<SyncService>().syncAll();
      }

      Get.offAllNamed(AppRoutes.main);
    } on DioException catch (error) {
      final message = extractApiErrorMessage(error, fallback: 'Sign-in failed');

      Get.snackbar(
        'Sign-in failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    isSigningUp.value = true;

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (_authService.isAuthenticated.value) {
        if (Get.isRegistered<SyncService>()) {
          await Get.find<SyncService>().syncAll();
        }

        Get.offAllNamed(AppRoutes.main);

        return;
      }

      Get.offAllNamed(AppRoutes.signIn);

      Get.snackbar(
        'Account created',
        'Sign in to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (error) {
      final message = extractApiErrorMessage(error, fallback: 'Sign-up failed');

      Get.snackbar(
        'Sign-up failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSigningUp.value = false;
    }
  }

  Future<void> signOut() async {
    isSigningOut.value = true;

    try {
      await _authService.signOut();

      Get.offAllNamed(AppRoutes.signIn);
    } finally {
      isSigningOut.value = false;
    }
  }
}
