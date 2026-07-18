import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SafeLogInterceptor extends Interceptor {
  static final RegExp _sensitiveKeyPattern = RegExp(
    r'(authorization|token|password|passcode|otp|pin|secret|email|phone|mobile|address|req)$',
    caseSensitive: false,
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _log('API ${options.method} ${options.uri}');
      if (options.queryParameters.isNotEmpty) {
        _log('API QUERY ${_sanitize(options.queryParameters)}');
      }
      if (options.headers.isNotEmpty) {
        _log('API HEADERS ${_sanitize(options.headers)}');
      }
      if (options.data != null) {
        _log('API BODY ${_sanitize(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _log('API ${response.statusCode} ${response.requestOptions.uri}');
      _log('API RESPONSE ${_sanitize(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _log('API ERROR TYPE ${error.type}');
      _log('API ERROR URL ${error.requestOptions.uri}');
      _log('API ERROR STATUS ${error.response?.statusCode}');
      _log('API ERROR BODY ${_sanitize(error.response?.data)}');
      _log('API ERROR MESSAGE ${error.message ?? error.error ?? 'unknown'}');
    }
    handler.next(error);
  }

  dynamic _sanitize(dynamic value, {String? key}) {
    if (key != null && _sensitiveKeyPattern.hasMatch(key)) {
      return '***';
    }

    if (value is FormData) {
      return <String, dynamic>{
        'fields': <String, dynamic>{
          for (final MapEntry<String, String> field in value.fields)
            field.key: _sanitize(field.value, key: field.key),
        },
        'files': <String>[
          for (final MapEntry<String, MultipartFile> file in value.files)
            '${file.key}: ${file.value.filename ?? 'file'}',
        ],
      };
    }

    if (value is Map) {
      return <String, dynamic>{
        for (final MapEntry<dynamic, dynamic> entry in value.entries)
          entry.key.toString():
              _sanitize(entry.value, key: entry.key.toString()),
      };
    }

    if (value is Iterable) {
      final List<dynamic> items = value.take(25).map(_sanitize).toList();
      if (value.length > 25) items.add('...');
      return items;
    }

    final String text = value?.toString() ?? 'null';
    if (text.length > 1500) {
      return '${text.substring(0, 1500)}...';
    }
    return value;
  }

  void _log(Object? value) {
    debugPrint(value?.toString());
  }
}
