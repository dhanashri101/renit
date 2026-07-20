import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/services/api_exception.dart';
import 'package:rentit24/services/api_services.dart';

class CategoryService {
  CategoryService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<CategoryModel>> getCategories() async {
    final data = await _api.get('/category/all');
    if (data is! List) {
      throw const ApiException(
        type: ApiErrorType.contract,
        message: 'Category response is not a list.',
      );
    }

    final categories = data
        .whereType<Map>()
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.name.isNotEmpty && item.isActive)
        .toList();

    // The backend endpoint currently returns both parents and children.
    final parents = categories.where((item) => item.parentId == null).toList();
    parents.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return parents;
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final data = await _api.get('/category/all');
    if (data is! List) return const [];
    final categories = data
        .whereType<Map>()
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.name.isNotEmpty && item.isActive)
        .toList();
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  Future<List<CategoryModel>> getSubcategories(int parentId) async {
    final data = await _api.get('/category/$parentId/subcategories');
    if (data is! List) return const [];
    final categories = data
        .whereType<Map>()
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.name.isNotEmpty)
        .toList();
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  Future<CategoryModel> getCategory(int id) async {
    final data = await _api.get('/category/$id');
    if (data is! Map) {
      throw const ApiException(
        type: ApiErrorType.contract,
        message: 'Category detail response is invalid.',
      );
    }
    return CategoryModel.fromJson(Map<String, dynamic>.from(data));
  }
}
