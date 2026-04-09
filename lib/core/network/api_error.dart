import 'package:dio/dio.dart';

String? _extractErrorFromPayload(dynamic payload) {
  if (payload == null) {
    return null;
  }

  if (payload is String) {
    final value = payload.trim();
    return value.isEmpty ? null : value;
  }

  if (payload is Map) {
    for (final key in const ['error', 'message', 'detail']) {
      final value = payload[key];
      final text = _extractErrorFromPayload(value);
      if (text != null) {
        return text;
      }
    }

    return null;
  }

  if (payload is List && payload.isNotEmpty) {
    for (final item in payload) {
      final text = _extractErrorFromPayload(item);
      if (text != null) {
        return text;
      }
    }
  }

  return null;
}

bool _isVerboseDioMessage(String message) {
  final lower = message.toLowerCase();
  return lower.startsWith('dioexception ') ||
      lower.contains('requestoptions.validatestatus') ||
      lower.contains('read more about status codes');
}

String? extractApiErrorMessageOrNull(Object error) {
  if (error is DioException) {
    final fromPayload = _extractErrorFromPayload(error.response?.data);
    if (fromPayload != null) {
      return fromPayload;
    }

    final message = error.message?.trim();
    if (message != null &&
        message.isNotEmpty &&
        !_isVerboseDioMessage(message)) {
      return message;
    }
  }

  return null;
}

String extractApiErrorMessage(
  Object error, {
  String fallback = 'Request failed',
}) {
  return extractApiErrorMessageOrNull(error) ?? fallback;
}
