import 'package:dio/dio.dart';

enum ApiErrorType {
  networkUnavailable,
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  parsing,
  contract,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.backendCode,
    this.data,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final int? backendCode;
  final dynamic data;

  String get userMessage {
    switch (type) {
      case ApiErrorType.networkUnavailable:
        return 'Unable to connect. Check your internet connection and retry.';
      case ApiErrorType.connectionTimeout:
      case ApiErrorType.sendTimeout:
      case ApiErrorType.receiveTimeout:
        return 'The request timed out. Please retry.';
      case ApiErrorType.badRequest:
      case ApiErrorType.validation:
        return message.isNotEmpty ? message : 'Please check the entered details.';
      case ApiErrorType.unauthorized:
        return 'Authentication is not available yet on the backend.';
      case ApiErrorType.forbidden:
        return 'The server refused this request.';
      case ApiErrorType.notFound:
        return 'The requested data was not found.';
      case ApiErrorType.server:
        return 'The server could not complete the request. Please retry.';
      case ApiErrorType.parsing:
      case ApiErrorType.contract:
        return 'The server returned an unexpected response.';
      case ApiErrorType.cancelled:
        return 'The request was cancelled.';
      case ApiErrorType.unknown:
        return message.isNotEmpty ? message : 'Something went wrong.';
    }
  }

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final responseData = error.response?.data;
    final message = _extractMessage(responseData) ?? error.message ?? '';

    if (error.type == DioExceptionType.cancel) {
      return ApiException(type: ApiErrorType.cancelled, message: message);
    }
    if (error.type == DioExceptionType.connectionTimeout) {
      return ApiException(type: ApiErrorType.connectionTimeout, message: message);
    }
    if (error.type == DioExceptionType.sendTimeout) {
      return ApiException(type: ApiErrorType.sendTimeout, message: message);
    }
    if (error.type == DioExceptionType.receiveTimeout) {
      return ApiException(type: ApiErrorType.receiveTimeout, message: message);
    }
    if (error.type == DioExceptionType.connectionError) {
      return ApiException(type: ApiErrorType.networkUnavailable, message: message);
    }

    final type = switch (status) {
      400 => ApiErrorType.badRequest,
      401 => ApiErrorType.unauthorized,
      403 => ApiErrorType.forbidden,
      404 => ApiErrorType.notFound,
      409 || 422 => ApiErrorType.validation,
      500 => ApiErrorType.server,
      _ => ApiErrorType.unknown,
    };

    return ApiException(
      type: type,
      message: message,
      statusCode: status,
      data: responseData,
    );
  }
  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final raw = data['message'] ?? data['error'] ?? data['detail'];
      if (raw != null && raw.toString().trim().isNotEmpty) {
        return raw.toString().trim();
      }
      final res = data['res'];
      if (res is Map && res['message'] != null) {
        return res['message'].toString().trim();
      }
    }
    return null;
  }

  @override
  String toString() => 'ApiException($type, $message, status: $statusCode, backend: $backendCode)';
}
