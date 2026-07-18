import 'package:dio/dio.dart';
import 'package:rentit24/core/network/api_endpoints.dart';
import 'package:rentit24/core/network/api_exception.dart';
import 'package:rentit24/core/network/api_response.dart';
import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/services/api_services.dart';

class CategoryService {
  CategoryService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<CategoryModel>> getCategories({
    CancelToken? cancelToken,
  }) async {
    try {
      final Response<dynamic> response = await _apiService.dio.get<dynamic>(
        ApiEndpoints.categories,
        cancelToken: cancelToken,
      );

      final ApiEnvelope envelope = ApiEnvelope.fromDynamic(response.data);
      envelope.requireJsonResult();

      final dynamic result = envelope.result;
      if (result is! List) {
        throw ApiParsingException(
          'Expected category/all to return a list in res, but received ${result.runtimeType}.',
        );
      }

      final List<CategoryModel> categories = <CategoryModel>[];
      for (final dynamic item in result) {
        if (item is! Map) continue;

        try {
          categories.add(
            CategoryModel.fromJson(Map<String, dynamic>.from(item)),
          );
        } on FormatException {
          // Ignore malformed entries while still allowing valid categories.
        }
      }

      if (result.isNotEmpty && categories.isEmpty) {
        throw const ApiParsingException(
          'The category list was present, but none of its entries matched the expected category fields.',
        );
      }

      final Map<String, CategoryModel> unique = <String, CategoryModel>{};
      for (final CategoryModel category in categories) {
        final String key = category.id != null
            ? 'id:${category.id}'
            : 'name:${category.name.toLowerCase()}';
        unique[key] = category;
      }

      final List<CategoryModel> sorted = unique.values.toList()
        ..sort((CategoryModel first, CategoryModel second) {
          final int firstOrder = first.sortOrder ?? 1 << 30;
          final int secondOrder = second.sortOrder ?? 1 << 30;
          final int orderComparison = firstOrder.compareTo(secondOrder);
          return orderComparison != 0
              ? orderComparison
              : first.name.toLowerCase().compareTo(second.name.toLowerCase());
        });

      return sorted;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on ApiException {
      rethrow;
    } on FormatException catch (error) {
      throw ApiParsingException(error.message);
    } catch (error) {
      throw ApiParsingException('Unable to parse categories: $error');
    }
  }
}
