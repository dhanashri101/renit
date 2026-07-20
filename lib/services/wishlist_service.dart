import 'package:rentit24/model/listing_model.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class WishlistService {
  WishlistService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<bool> toggle(int listingId, {int? userId}) async {
    final resolvedUserId = userId ?? await SessionService.getUserId();
    final data = await _api.post(
      '/wishlist/toggle',
      queryParameters: {'userId': resolvedUserId, 'listingId': listingId},
    );
    return data is Map && data['added'] == true;
  }

  Future<List<ListingModel>> getMine({
    int? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    final resolvedUserId = userId ?? await SessionService.getUserId();
    final data = await _api.get(
      '/wishlist/my',
      queryParameters: {
        'userId': resolvedUserId,
        'limit': limit,
        'offset': offset,
      },
    );
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => ListingModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
