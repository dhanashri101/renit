import 'package:rentit24/model/listing_model.dart';
import 'package:rentit24/services/api_exception.dart';
import 'package:rentit24/services/api_services.dart';
import 'package:rentit24/services/session_service.dart';

class ListingService {
  ListingService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<ListingModel>> getFeed({
    int? areaId,
    int limit = 20,
    int offset = 0,
  }) async {
    final resolvedAreaId = areaId ?? await SessionService.getAreaId();
    final data = await _api.get(
      '/listing/feed',
      queryParameters: {
        'areaId': resolvedAreaId,
        'limit': limit,
        'offset': offset,
      },
    );
    return _parseList(data);
  }

  Future<List<ListingModel>> searchListings({
    String? keyword,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'relevance',
    String? listingType,
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _api.get(
      '/listing/search',
      queryParameters: {
        'keyword': keyword,
        'categoryId': categoryId,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'sortBy': sortBy,
        'listingType': listingType,
        'limit': limit,
        'offset': offset,
      },
    );
    return _parseList(data);
  }

  Future<ListingModel> getListingById(int id) async {
    final data = await _api.get('/listing/$id');
    if (data is! Map) {
      throw const ApiException(
        type: ApiErrorType.contract,
        message: 'Listing detail response is invalid.',
      );
    }
    return ListingModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<int> createListing(ListingModel listing) async {
    final data = await _api.post('/listing/create', data: listing.toCreateJson());
    if (data is Map) {
      final value = data['id'];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  Future<void> updateListing(ListingModel listing) async {
    await _api.put('/listing/update', data: listing.toUpdateJson());
  }

  Future<void> deleteListing(int id) async {
    await _api.delete('/listing/delete/$id');
  }

  Future<List<ListingModel>> getMyListings({
    int? ownerId,
    String? listingType,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final resolvedOwnerId = ownerId ?? await SessionService.getUserId();
    final data = await _api.get(
      '/listing/my',
      queryParameters: {
        'ownerId': resolvedOwnerId,
        'listingType': listingType,
        'status': status,
        'limit': limit,
        'offset': offset,
      },
    );
    return _parseList(data);
  }

  List<ListingModel> _parseList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => ListingModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id != 0 && item.title.isNotEmpty)
        .toList();
  }
}
