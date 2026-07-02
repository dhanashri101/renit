import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    dio = Dio(BaseOptions(baseUrl: 'https://rentit24.com'));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          print("Token = $token");

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print("Headers = ${options.headers}");

          return handler.next(options);
        },
      ),
    );
  }
}
