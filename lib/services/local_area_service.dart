import 'package:rentit24/model/local_area_model.dart';
import 'package:rentit24/services/api_exception.dart';
import 'package:rentit24/services/api_services.dart';

class LocalAreaService {
  LocalAreaService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<LocalAreaModel>> getAll() async {
    final data = await _api.get('/localarea/all');
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => LocalAreaModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id != 0 && item.areaName.isNotEmpty)
        .toList();
  }

  Future<LocalAreaModel> getById(int id) async {
    final data = await _api.get('/localarea/$id');
    if (data is! Map) {
      throw const ApiException(
        type: ApiErrorType.contract,
        message: 'Local area response is invalid.',
      );
    }
    return LocalAreaModel.fromJson(Map<String, dynamic>.from(data));
  }
}
