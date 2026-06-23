import 'package:dio/dio.dart';
import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/services/api_services.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.dio.get('/category/all');

      final String rawData = response.data['res'].toString();

      return _parseCategories(rawData);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            e.message ??
            'Failed to load categories',
      );
    }
  }

  List<CategoryModel> _parseCategories(String data) {
    final List<CategoryModel> categories = [];

    final items = data.split('},');

    for (var item in items) {
      final idMatch = RegExp(r'id=(\d+)').firstMatch(item);
      final nameMatch = RegExp(r'name=([^,]+)').firstMatch(item);
      final typeMatch = RegExp(r'type=([^,]+)').firstMatch(item);
      final sortMatch = RegExp(r'sort_order=(\d+)').firstMatch(item);
      final activeMatch =
          RegExp(r'is_active=(true|false)').firstMatch(item);

      categories.add(
        CategoryModel(
          id: int.tryParse(idMatch?.group(1) ?? '0') ?? 0,
          name: nameMatch?.group(1)?.trim() ?? '',
          type: typeMatch?.group(1)?.trim() ?? '',
          sortOrder: int.tryParse(sortMatch?.group(1) ?? '0') ?? 0,
          isActive: (activeMatch?.group(1) ?? 'false') == 'true',
        ),
      );
    }

    return categories;
  }
}