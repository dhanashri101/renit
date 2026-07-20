import 'package:dio/dio.dart';
import 'package:rentit24/config/api_config.dart';
import 'package:rentit24/services/api_services.dart';

class MediaService {
  MediaService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<String>> uploadFiles(
    List<String> paths, {
    String category = 'user',
    int? userId,
  }) async {
    final uploaded = <String>[];

    // The backend endpoint documents one multipart `file` per request.
    // Uploading sequentially also gives an exact failure for the affected file.
    for (final path in paths) {
      final data = await _api.post(
        '/product/uploadFile',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(
            path,
            filename: path.split(RegExp(r'[/\\]')).last,
          ),
        }),
        queryParameters: {
          'category': category,
          'userId': userId,
        },
        options: Options(contentType: 'multipart/form-data'),
      );
      uploaded.addAll(_extractUrls(data));
    }

    return uploaded;
  }

  List<String> _extractUrls(dynamic data) {
    if (data is List) {
      return data
          .map((item) => ApiConfig.resolveMediaUrl(item.toString()))
          .where((url) => url.isNotEmpty)
          .toList();
    }

    if (data is Map) {
      final files = data['files'] ?? data['urls'] ?? data['fileUrls'];
      if (files is List) {
        return files
            .map((item) => ApiConfig.resolveMediaUrl(item.toString()))
            .where((url) => url.isNotEmpty)
            .toList();
      }
      final single = data['url'] ??
          data['fileUrl'] ??
          data['path'] ??
          data['file_path'] ??
          data['file'];
      if (single != null) {
        final url = ApiConfig.resolveMediaUrl(single.toString());
        return url.isEmpty ? const [] : [url];
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return [ApiConfig.resolveMediaUrl(data)];
    }
    return const [];
  }
}
