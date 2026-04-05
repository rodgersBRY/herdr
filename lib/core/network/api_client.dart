import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';

class ApiClient extends GetxService {
  late final Dio dio;

  Future<ApiClient> init() async {
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
        onError: (error, handler) {
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
