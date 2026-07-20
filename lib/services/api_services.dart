import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rentit24/config/api_config.dart';
import 'package:rentit24/services/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'RentIt24-Flutter/1.0',
        },
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('API ${options.method} ${options.uri}');
            if (options.data != null) debugPrint('API BODY ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('API ${response.statusCode} ${response.requestOptions.uri}');
            debugPrint('API RESPONSE ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('API ERROR ${error.requestOptions.uri}: ${error.message}');
            debugPrint('API ERROR BODY ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;

  late final Dio dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _execute(() => dio.get(path, queryParameters: _clean(queryParameters)));
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _execute(
      () => dio.post(
        path,
        data: data,
        queryParameters: _clean(queryParameters),
        options: options,
      ),
    );
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _execute(
      () => dio.put(path, data: data, queryParameters: _clean(queryParameters)),
    );
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _execute(
      () => dio.delete(path, data: data, queryParameters: _clean(queryParameters)),
    );
  }

  Future<dynamic> _execute(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final statusCode = response.statusCode ?? 0;
      final decoded = _decode(response.data);

      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(
          type: _typeForStatus(statusCode),
          message: _messageFrom(decoded) ?? 'HTTP $statusCode',
          statusCode: statusCode,
          data: decoded,
        );
      }

      if (decoded is Map) {
        final backendCode = _toInt(decoded['rescode']);
        final result = _decode(decoded['res']);
        final requestPath = response.requestOptions.path;
        final isOtpAccepted = backendCode == 101 &&
            (requestPath.endsWith('/auth/getloginOTP') ||
                requestPath.endsWith('/auth/getOTP'));
        if (backendCode != null && backendCode != 100 && !isOtpAccepted) {
          throw ApiException(
            type: backendCode >= 500 ? ApiErrorType.server : ApiErrorType.validation,
            message: _messageFrom(result) ?? 'Backend error $backendCode',
            statusCode: statusCode,
            backendCode: backendCode,
            data: decoded,
          );
        }
        if (decoded.containsKey('res')) return result;
      }

      return decoded;
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException catch (error) {
      throw ApiException(type: ApiErrorType.parsing, message: error.message);
    } catch (error) {
      throw ApiException(type: ApiErrorType.unknown, message: error.toString());
    }
  }

  dynamic _decode(dynamic value) {
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) return null;
      try {
        return jsonDecode(text);
      } catch (_) {
        return text;
      }
    }
    return value;
  }

  Map<String, dynamic>? _clean(Map<String, dynamic>? input) {
    if (input == null) return null;
    return Map<String, dynamic>.fromEntries(
      input.entries.where((entry) => entry.value != null && entry.value.toString().isNotEmpty),
    );
  }

  String? _messageFrom(dynamic data) {
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
    }
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  ApiErrorType _typeForStatus(int status) {
    if (status == 400) return ApiErrorType.badRequest;
    if (status == 401) return ApiErrorType.unauthorized;
    if (status == 403) return ApiErrorType.forbidden;
    if (status == 404) return ApiErrorType.notFound;
    if (status == 409 || status == 422) return ApiErrorType.validation;
    if (status >= 500) return ApiErrorType.server;
    return ApiErrorType.unknown;
  }
}
