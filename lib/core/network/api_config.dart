class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://rentit24.com/service/';
  static const String websiteOrigin = 'https://rentit24.com/';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
