class ApiConfig {
  ApiConfig._();

  static const String origin = 'https://rentit24.com';
  static const String baseUrl = '$origin/service';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static String resolveMediaUrl(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return '';

    if (raw.startsWith('http://localhost:11022')) {
      return raw.replaceFirst('http://localhost:11022', baseUrl);
    }
    if (raw.startsWith('https://localhost:11022')) {
      return raw.replaceFirst('https://localhost:11022', baseUrl);
    }
    if (raw.startsWith('http://127.0.0.1:11022')) {
      return raw.replaceFirst('http://127.0.0.1:11022', baseUrl);
    }
    if (raw.startsWith('/service/')) return '$origin$raw';
    if (raw.startsWith('/')) return '$baseUrl$raw';

    return raw;
  }
}
