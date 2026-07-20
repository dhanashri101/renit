import 'package:rentit24/model/banner_model.dart';
import 'package:rentit24/services/api_services.dart';

class BannerService {
  BannerService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<BannerModel>> getHomeBanners() => _get('/banner/getBanner');

  Future<List<BannerModel>> getSplashBanners() =>
      _get('/banner/getSplashScreenBanner');

  Future<List<BannerModel>> _get(String path) async {
    final data = await _api.get(path);
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.title.isNotEmpty)
        .toList();
  }
}
