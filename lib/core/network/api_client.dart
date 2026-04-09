import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../auth/auth_service.dart';
import '../utils/constants.dart';

class ApiClient extends GetxService {
  late final Dio dio;

  Future<ApiClient> init() async {
    final authService = Get.find<AuthService>();

    dio = Dio(
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authService.accessToken.value;
          final hasAuthHeader = options.headers.containsKey('Authorization');
          if (!hasAuthHeader && token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final status = error.response?.statusCode;
          final isAuthRoute = request.path.startsWith('/auth/');
          final retried = request.extra['retried'] == true;

          if (status == 401 && !isAuthRoute && !retried) {
            final refreshed = await authService.refreshAccessToken();
            if (refreshed) {
              final token = authService.accessToken.value;
              if (token != null && token.isNotEmpty) {
                final headers = Map<String, dynamic>.from(request.headers);
                headers['Authorization'] = 'Bearer $token';

                final retryOptions = Options(
                  method: request.method,
                  headers: headers,
                  responseType: request.responseType,
                  contentType: request.contentType,
                  followRedirects: request.followRedirects,
                  receiveDataWhenStatusError:
                      request.receiveDataWhenStatusError,
                  validateStatus: request.validateStatus,
                  sendTimeout: request.sendTimeout,
                  receiveTimeout: request.receiveTimeout,
                  extra: Map<String, dynamic>.from(request.extra)
                    ..['retried'] = true,
                );

                try {
                  final retryResponse = await dio.request<dynamic>(
                    request.path,
                    data: request.data,
                    queryParameters: request.queryParameters,
                    options: retryOptions,
                    cancelToken: request.cancelToken,
                    onSendProgress: request.onSendProgress,
                    onReceiveProgress: request.onReceiveProgress,
                  );
                  handler.resolve(retryResponse);
                  return;
                } on DioException catch (retryError) {
                  error = retryError;
                }
              }
            } else {
              await authService.signOut();
              if (Get.currentRoute != AppRoutes.signIn) {
                Get.offAllNamed(AppRoutes.signIn);
              }
            }
          }

          final response = error.response;
          if (response?.data is Map<String, dynamic>) {
            final payload = response!.data as Map<String, dynamic>;
            final message = payload['error'];

            if (message is String && message.isNotEmpty) {
              handler.reject(error.copyWith(message: message));

              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return this;
  }
}
