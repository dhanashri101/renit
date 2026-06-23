import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://rentit24.com',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
}