import 'package:dio/dio.dart';
import 'package:rentit24/core/network/api_config.dart';
import 'package:rentit24/core/network/safe_log_interceptor.dart';
import 'package:rentit24/core/storage/auth_storage.dart';

class ApiService {
  factory ApiService() => _instance;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: const <String, dynamic>{
          'Accept': 'application/json',
          'User-Agent': 'RentIt24-Flutter/1.0',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) async {
          final String? authorizationHeader =
              await _authStorage.readAuthorizationHeader();

          if (authorizationHeader != null &&
              !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = authorizationHeader;
          }

          handler.next(options);
        },
      ),
    );
    dio.interceptors.add(SafeLogInterceptor());
  }

  static final ApiService _instance = ApiService._internal();

  final AuthStorage _authStorage = AuthStorage();
  late final Dio dio;
}
