import 'package:dio/dio.dart';

enum ApiErrorType {
  networkUnavailable,
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  transformTimeout,
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
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  String get userMessage {
    switch (type) {
      case ApiErrorType.networkUnavailable:
        return 'Unable to connect. Check your internet connection and retry.';

      case ApiErrorType.connectionTimeout:
      case ApiErrorType.sendTimeout:
      case ApiErrorType.receiveTimeout:
        return 'The request timed out. Please retry.';

      case ApiErrorType.transformTimeout:
        return 'The server response took too long to process. Please retry.';

      case ApiErrorType.badRequest:
        return 'The request was not accepted by the server.';

      case ApiErrorType.unauthorized:
        return 'Your session is not authorized. Please sign in again.';

      case ApiErrorType.forbidden:
        return 'The server refused this request. Your account or request may '
            'be missing a required permission or field.';

      case ApiErrorType.notFound:
        return 'The requested information was not found.';

      case ApiErrorType.validation:
        return message;

      case ApiErrorType.server:
        return 'The server could not complete the request. Please retry later.';

      case ApiErrorType.parsing:
        return 'The server returned an unexpected response.';

      case ApiErrorType.contract:
        return message;

      case ApiErrorType.cancelled:
        return 'The request was cancelled.';

      case ApiErrorType.unknown:
        return 'Something went wrong. Please retry.';
    }
  }

  factory ApiException.fromDio(DioException error) {
    final int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          type: ApiErrorType.connectionTimeout,
          message: error.message ?? 'Connection timeout',
          statusCode: statusCode,
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          type: ApiErrorType.sendTimeout,
          message: error.message ?? 'Send timeout',
          statusCode: statusCode,
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          type: ApiErrorType.receiveTimeout,
          message: error.message ?? 'Receive timeout',
          statusCode: statusCode,
        );

      case DioExceptionType.transformTimeout:
        return ApiException(
          type: ApiErrorType.transformTimeout,
          message: error.message ?? 'Response transformation timeout',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(
          type: ApiErrorType.cancelled,
          message: error.message ?? 'Request cancelled',
          statusCode: statusCode,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return ApiException(
          type: ApiErrorType.networkUnavailable,
          message: error.message ?? 'Network connection failed',
          statusCode: statusCode,
        );

      case DioExceptionType.badResponse:
        return _fromStatusCode(
          statusCode,
          error.response?.data,
        );

      case DioExceptionType.unknown:
        return ApiException(
          type: ApiErrorType.unknown,
          message: error.message ??
              error.error?.toString() ??
              'Unknown error',
          statusCode: statusCode,
        );
    }
  }

  static ApiException _fromStatusCode(
    int? statusCode,
    dynamic responseData,
  ) {
    final String? backendMessage = _extractMessage(responseData);
    final String message =
        backendMessage ?? 'HTTP ${statusCode ?? 'unknown'}';

    if (statusCode == 400) {
      return ApiException(
        type: ApiErrorType.badRequest,
        message: message,
        statusCode: statusCode,
      );
    }

    if (statusCode == 401) {
      return ApiException(
        type: ApiErrorType.unauthorized,
        message: message,
        statusCode: statusCode,
      );
    }

    if (statusCode == 403) {
      return ApiException(
        type: ApiErrorType.forbidden,
        message: message,
        statusCode: statusCode,
      );
    }

    if (statusCode == 404) {
      return ApiException(
        type: ApiErrorType.notFound,
        message: message,
        statusCode: statusCode,
      );
    }

    if (statusCode == 409 || statusCode == 422) {
      return ApiException(
        type: ApiErrorType.validation,
        message:
            backendMessage ?? 'Please check the submitted information.',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        type: ApiErrorType.server,
        message: message,
        statusCode: statusCode,
      );
    }

    return ApiException(
      type: ApiErrorType.unknown,
      message: message,
      statusCode: statusCode,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is! Map) {
      return null;
    }

    for (final String key in <String>[
      'message',
      'error',
      'detail',
      'description',
    ]) {
      final dynamic value = data[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'ApiException('
        'type: $type, '
        'statusCode: $statusCode, '
        'message: $message'
        ')';
  }
}

class ApiContractException extends ApiException {
  const ApiContractException(String message)
      : super(
          type: ApiErrorType.contract,
          message: message,
        );
}

class ApiParsingException extends ApiException {
  const ApiParsingException(String message)
      : super(
          type: ApiErrorType.parsing,
          message: message,
        );
}