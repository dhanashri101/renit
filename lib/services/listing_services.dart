import 'package:rentit24/model/listing_model.dart';

import 'package:rentit24/services/api_services.dart';

class ListingService {
  final ApiService _apiService = ApiService();

  Future<List<ListingModel>> getFeed() async {
    try {
      final response = await _apiService.dio.get('/listing/feed');

      final List data = response.data;

      return data
          .map((item) => ListingModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load listings: $e');
    }
  }

  Future<ListingModel> getListingById(int id) async {
    try {
      final response = await _apiService.dio.get('/listing/$id');

      return ListingModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load listing: $e');
    }
  }

  Future<void> createListing(ListingModel listing) async {
    try {
      await _apiService.dio.post(
        '/listing/create',
        data: listing.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  Future<void> updateListing(ListingModel listing) async {
    try {
      await _apiService.dio.put(
        '/listing/update',
        data: listing.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  Future<void> deleteListing(int id) async {
    try {
      await _apiService.dio.delete('/listing/delete/$id');
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  Future<List<ListingModel>> getMyListings() async {
    try {
      final response = await _apiService.dio.get('/listing/my');

      final List data = response.data;

      return data
          .map((item) => ListingModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load my listings: $e');
    }
  }
}