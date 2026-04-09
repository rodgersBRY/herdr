import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../network/api_error.dart';
import '../network/network_status_service.dart';
import '../utils/constants.dart';

class AuthService extends GetxService {
  static const String _accessTokenKey = 'auth.access_token';
  static const String _refreshTokenKey = 'auth.refresh_token';
  static const String _userIdKey = 'auth.user_id';
  static const String _userEmailKey = 'auth.user_email';
  static const String _userFullNameKey = 'auth.user_full_name';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final RxnString accessToken = RxnString();
  final RxnString refreshToken = RxnString();
  final RxnString userId = RxnString();
  final RxnString userEmail = RxnString();
  final RxnString userFullName = RxnString();
  final RxBool isAuthenticated = false.obs;

  Future<bool>? _refreshInFlight;

  Future<AuthService> init() async {
    accessToken.value = await _storage.read(key: _accessTokenKey);
    refreshToken.value = await _storage.read(key: _refreshTokenKey);
    userId.value = await _storage.read(key: _userIdKey);
    userEmail.value = await _storage.read(key: _userEmailKey);
    userFullName.value = await _storage.read(key: _userFullNameKey);

    isAuthenticated.value = accessToken.value != null;

    return this;
  }

  bool get _isOnline {
    if (!Get.isRegistered<NetworkStatusService>()) {
      return true;
    }

    return Get.find<NetworkStatusService>().isOnline.value;
  }

  Dio _publicDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return <String, dynamic>{};
  }

  String? _extractString(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    return null;
  }

  void _applyUser(Map<String, dynamic> user) {
    final metadata = _asMap(user['user_metadata']);

    userId.value = _extractString(user['id']);
    userEmail.value = _extractString(user['email']);
    userFullName.value = _extractString(metadata['full_name']);
  }

  Future<void> _persistSession() async {
    await Future.wait([
      if (accessToken.value != null)
        _storage.write(key: _accessTokenKey, value: accessToken.value)
      else
        _storage.delete(key: _accessTokenKey),
      if (refreshToken.value != null)
        _storage.write(key: _refreshTokenKey, value: refreshToken.value)
      else
        _storage.delete(key: _refreshTokenKey),
      if (userId.value != null)
        _storage.write(key: _userIdKey, value: userId.value)
      else
        _storage.delete(key: _userIdKey),
      if (userEmail.value != null)
        _storage.write(key: _userEmailKey, value: userEmail.value)
      else
        _storage.delete(key: _userEmailKey),
      if (userFullName.value != null)
        _storage.write(key: _userFullNameKey, value: userFullName.value)
      else
        _storage.delete(key: _userFullNameKey),
    ]);
  }

  Future<void> _applyAuthPayload(
    Map<String, dynamic> payload, {
    required bool requireSession,
  }) async {
    final session = _asMap(payload['session']);
    final user = _asMap(payload['user']);

    final incomingAccessToken = _extractString(session['access_token']);
    final incomingRefreshToken = _extractString(session['refresh_token']);

    if (requireSession &&
        (incomingAccessToken == null || incomingRefreshToken == null)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth'),
        error: 'No active session returned by auth service.',
        message: 'No active session returned by auth service.',
      );
    }

    if (incomingAccessToken != null) {
      accessToken.value = incomingAccessToken;
    }

    if (incomingRefreshToken != null) {
      refreshToken.value = incomingRefreshToken;
    }

    if (user.isNotEmpty) {
      _applyUser(user);
    }

    isAuthenticated.value = accessToken.value != null;
    await _persistSession();
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _publicDio().post(
        '/auth/sign-in',
        data: {'email': email, 'password': password},
      );

      final payload = _asMap(response.data);
      await _applyAuthPayload(payload, requireSession: true);

      if (_isOnline) {
        await fetchCurrentUser();
      }

      return payload;
    } on DioException catch (error) {
      throw error.copyWith(
        message: extractApiErrorMessage(error, fallback: 'Sign-in failed'),
      );
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _publicDio().post(
        '/auth/sign-up',
        data: {
          'email': email,
          'password': password,
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
        },
      );

      final payload = _asMap(response.data);
      await _applyAuthPayload(payload, requireSession: false);

      if (isAuthenticated.value && _isOnline) {
        await fetchCurrentUser();
      }

      return payload;
    } on DioException catch (error) {
      throw error.copyWith(
        message: extractApiErrorMessage(error, fallback: 'Sign-up failed'),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    final token = accessToken.value;
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _publicDio().get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final payload = _asMap(response.data);
      final user = _asMap(payload['user']);
      if (user.isNotEmpty) {
        _applyUser(user);
        await _persistSession();
      }

      return payload;
    } on DioException catch (error) {
      throw error.copyWith(
        message: extractApiErrorMessage(error, fallback: 'Failed to get user'),
      );
    }
  }

  Future<void> restoreSession() async {
    if (accessToken.value == null || accessToken.value!.isEmpty) {
      isAuthenticated.value = false;
      return;
    }

    if (!_isOnline) {
      isAuthenticated.value = true;
      return;
    }

    try {
      await fetchCurrentUser();
      isAuthenticated.value = true;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        final refreshed = await refreshAccessToken();
        if (!refreshed) {
          await signOut();
        }
        return;
      }

      isAuthenticated.value = accessToken.value != null;
    }
  }

  Future<bool> refreshAccessToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    _refreshInFlight = _refreshAccessTokenInternal();
    final result = await _refreshInFlight!;
    _refreshInFlight = null;

    return result;
  }

  Future<bool> _refreshAccessTokenInternal() async {
    final token = refreshToken.value;
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await _publicDio().post(
        '/auth/refresh',
        data: {'refresh_token': token},
      );
      final payload = _asMap(response.data);
      await _applyAuthPayload(payload, requireSession: true);
      try {
        await fetchCurrentUser();
      } on DioException {
        // Ignore profile fetch failures after successful token refresh.
      }

      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> signOut() async {
    accessToken.value = null;
    refreshToken.value = null;
    userId.value = null;
    userEmail.value = null;
    userFullName.value = null;
    isAuthenticated.value = false;

    await _persistSession();
  }
}
